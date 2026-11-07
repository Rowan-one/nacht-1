local ServerScriptService = game:GetService("ServerScriptService")
local MovementService = require(ServerScriptService.Server.Services.MovementService)
local SoundService = require(ServerScriptService.Server.Services.SoundService)
local ServerAction = require(script.Parent.ServerAction)
local CombatService = require(script.Parent.Parent)

local Parry = {}
Parry.__index = Parry
setmetatable(Parry, ServerAction)

function Parry.new(...)
	local self = ServerAction.new(...)

	return setmetatable(self, Parry)
end

function Parry:OnActive()
	SoundService:PlayAll("Parry", 1)
	self.Combatant:AddEffect("Parry")

	self.Trove:Add(function()
		self.Combatant:RemoveEffect("Parry")
	end)
end

function Parry:OnRecovery()
	self.Combatant:RemoveEffect("Parry")
end

function Parry:OnEnd()
end

return Parry
