local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Comm = require(ReplicatedStorage.Packages.Comm).ServerComm

local StaminaService = require(script.Parent.StaminaService)

local MovementService = {}

local SPRINT_DRAIN = 6

function MovementService:_drainStamina(dt)
	for userId, isSprinting in self.Sprinting do
		local player = Players:GetPlayerByUserId(userId)
		if isSprinting then
			StaminaService:Drain(player, SPRINT_DRAIN * dt)
		end
	end
end

function MovementService:SetSpeedMultiplier(player, id, multiplier)
	if player == nil then return end
	self._setSpeedMultiplier:Fire(player, id, multiplier)
end

function MovementService:OnStart()
	self.Sprinting = {}

	self.Comm = Comm.new(ReplicatedStorage, "MovementService")

	self._setSpeedMultiplier = self.Comm:CreateSignal("SetSpeedMultiplier")
	self._setSprinting = self.Comm:CreateSignal("SetSprinting")

	self._setSprinting:Connect(function(player, isSprinting)
		self.Sprinting[player.UserId] = isSprinting	
	end)

	RunService.Heartbeat:Connect(function(dt)
		self:_drainStamina(dt)
	end)
end

return MovementService
