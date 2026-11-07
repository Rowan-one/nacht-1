local ServerScriptService = game:GetService("ServerScriptService")
local CombatService = require(ServerScriptService.Server.Services.CombatService)
local ServerAction = require(ServerScriptService.Server.Services.CombatService.ActionHandlers.ServerAction)

local Block = {}
Block.__index = Block
setmetatable(Block, ServerAction)

function Block.new(...)
	local self = ServerAction.new(...)

	return setmetatable(self, Block)
end

function Block:OnActive()
	self.Combatant:AddEffect("Blocking")

	self.Trove:Add(function()
		self.Combatant:RemoveEffect("Blocking")
	end)
end

function Block:OnRecovery()
	self.Combatant:RemoveEffect("Blocking")
end

return Block
