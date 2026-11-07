local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Trove = require(ReplicatedStorage.Packages.Trove)
local ClientAction = {}
ClientAction.__index = ClientAction

local LocalPlayer = Players.LocalPlayer

function ClientAction.new(combatant, ctx)
	local self = {}

	if LocalPlayer then
		self.IsLocal = combatant.Instance == LocalPlayer.Character
	end

	self.Combatant = combatant
	self.Context = ctx
	self.Trove = Trove.new()

	return setmetatable(self, ClientAction)
end

function ClientAction:Destroy()
	self.Trove:Destroy()
end

function ClientAction:OnWindup()
end

function ClientAction:OnActive()
end

function ClientAction:OnRecovery()
end

function ClientAction:OnEnd()
end

return ClientAction
