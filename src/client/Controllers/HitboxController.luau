local Debris = game:GetService("Debris")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Hitbox = require(ReplicatedStorage.Shared.Hitbox)
local SweepDetect = require(ReplicatedStorage.Shared.SweepDetect)
local DebugController = require(script.Parent.DebugController)
local Comm = require(ReplicatedStorage.Packages.Comm).ClientComm

local HitboxController = {}

local LocalPlayer = Players.LocalPlayer

function HitboxController:_visualize()
	for i, hitbox in pairs(self.Active) do
	end
end

function HitboxController:_checkActive()
	-- detect collisions for all hitboxes
	for id, hitbox in self.Active do
		-- unregister if expired
		if hitbox.EndTime then
			local t = hitbox.EndTime - Workspace:GetServerTimeNow()
			if t <= 0 then
				self:_remove(id)
				continue
			end
		end

		local hitModel = hitbox:Check()

		if hitModel then
			self:_remove(hitbox.Id)
			local valid = self.ValidateHit(id, hitModel)	
			print("Valid?:",valid)
		end
	end
end

function HitboxController:_add(hitbox)
	self.Active[hitbox.Id] = hitbox
end

function HitboxController:_remove(id)
	self.Active[id] = nil
end

function HitboxController:OnStart()
	self.Active = {}

	self.Comm = Comm.new(ReplicatedStorage, false, "HitboxService")

	self.ValidateHit = self.Comm:GetFunction("ValidateHit")

	self.Comm:GetSignal("Registered"):Connect(function(hitbox)
		self:_add(setmetatable(hitbox, Hitbox))
	end)

	self.Comm:GetSignal("Removed"):Connect(function(hitbox)
		self:_remove(hitbox)
	end)

	RunService.RenderStepped:Connect(function()
		self:_checkActive()
	end)
end

return HitboxController
