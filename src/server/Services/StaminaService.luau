local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Comm = require(ReplicatedStorage.Packages.Comm)
local Comm = require(ReplicatedStorage.Packages.Comm).ServerComm

local StaminaService = {}

local MAX_STAMINA = 100

local REGEN_DELAY = 1
local REGEN_RATE = 25

function StaminaService:_regenerate(dt)
	local now = Workspace:GetServerTimeNow()
	for userId, lastDrain in self.LastDrain do
		local player = Players:GetPlayerByUserId(userId)

		if now - lastDrain > REGEN_DELAY then
			local new = math.clamp(self:Get(player) + REGEN_RATE*dt, 0, MAX_STAMINA)
			self:_set(player, new)
		end
	end
end

function StaminaService:_set(player, amount)
	self.Stamina[player.UserId] = amount

	local rounded = math.round(amount)
	if self.LastSent[player.UserId] == rounded then return end

	self.LastSent[player.UserId] = rounded
	self.StaminaProp:SetFor(player, rounded)
end

function StaminaService:Get(player)
	return self.Stamina[player.UserId]
end

function StaminaService:TrySpend(player, amount)
	local stamina = self:Get(player)
	if stamina == nil then return false end

	local canAfford = stamina >= amount
	if not canAfford then return false end

	local new = self:Get(player) - amount
	self:_set(player, new)
	self.LastDrain[player.UserId] = Workspace:GetServerTimeNow()

	return true
end

function StaminaService:Drain(player, amount)
	local stamina = self:Get(player)
	self:_set(player, math.clamp(stamina - amount, 0, MAX_STAMINA))
	self.LastDrain[player.UserId] = Workspace:GetServerTimeNow()
end

function StaminaService:OnStart()
	self.Stamina = {}
	self.LastDrain = {}
	self.LastSent = {}

	self.Comm = Comm.new(ReplicatedStorage, "StaminaService")
	self.StaminaProp = self.Comm:CreateProperty("Stamina", MAX_STAMINA)

	Players.PlayerAdded:Connect(function(player)
		self.Stamina[player.UserId] = MAX_STAMINA
	end)

	RunService.Heartbeat:Connect(function(dt)
		self:_regenerate(dt)
	end)
end

return StaminaService
