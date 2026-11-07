local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Trove = require(ReplicatedStorage.Packages.Trove)
local ServerAction = {}
ServerAction.__index = ServerAction

function ServerAction.new(combatant, ctx)
	local self = {}

	self.Combatant = combatant
	self.Context = ctx
	self.Trove = Trove.new()

	return setmetatable(self, ServerAction)
end

function ServerAction:Destroy()
	self.Trove:Destroy()
end

function ServerAction:OnWindup()
end

function ServerAction:OnActive()
end

function ServerAction:OnRecovery()
end

function ServerAction:OnEnd()
end

return ServerAction
