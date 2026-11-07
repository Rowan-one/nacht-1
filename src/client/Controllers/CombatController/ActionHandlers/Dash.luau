local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local MovementRig = require(ReplicatedStorage.Shared.Components.MovementRig)
local ClientAction = require(StarterPlayer.StarterPlayerScripts.Client.Controllers.CombatController.ActionHandlers.ClientAction)

local AnimationController = require(script.Parent.Parent.Parent.AnimationController)

local Dash = {}
Dash.__index = Dash
setmetatable(Dash, ClientAction)

function Dash.new(...)
	local self = ClientAction.new(...)

	return setmetatable(self, Dash)
end

function Dash:OnActive()
	print("Dashing")
	local character = self.Combatant.Instance
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	local movementRig = MovementRig:FromInstance(character)

	if self.IsLocal then
		local dir = rootPart.AssemblyLinearVelocity.Unit
		movementRig:SetOrientation(dir, 10, "dash")
		movementRig:AddForce(dir * 35, true, 0.4)

		AnimationController:PlayAction("Dash", 0.1)

	end
	self.Trove:Add(function()
		if self.IsLocal then
			movementRig:ClearOrientation("dash")
		end
	end)
end

function Dash:OnRecovery()
	local character = self.Combatant.Instance
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	local movementRig = MovementRig:FromInstance(character)

	if self.IsLocal then
		movementRig:ClearOrientation("dash")
	end
end

return Dash
