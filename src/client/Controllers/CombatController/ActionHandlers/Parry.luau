local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local Workspace = game:GetService("Workspace")
local MovementRig = require(ReplicatedStorage.Shared.Components.MovementRig)
local ClientAction = require(StarterPlayer.StarterPlayerScripts.Client.Controllers.CombatController.ActionHandlers.ClientAction)
local MovementController = require(script.Parent.Parent.Parent.MovementController)

local Parry = {}
Parry.__index = Parry
setmetatable(Parry, ClientAction)

function Parry.new(...)
	local self = ClientAction.new(...)

	return setmetatable(self, Parry)
end

function Parry:OnActive()
	print("Parry active on client")
	local character = self.Combatant.Instance
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	local movementRig = MovementRig:FromInstance(character)

	if self.IsLocal then
		movementRig:SetOrientation(rootPart.CFrame.LookVector, 2, "parry")
		MovementController:AddSpeedMultiplier("parry", 0.01, true)
	end

	local effect = Instance.new("Part", Workspace)
	effect.Color = Color3.new(0.5,0,1)
	effect.Material = Enum.Material.Neon
	effect.CanCollide = false
	effect.Size = Vector3.new(1.5,1.5,0.5)
	effect.CFrame = rootPart.CFrame + rootPart.CFrame.LookVector * 1
	local weld = Instance.new("WeldConstraint", effect)
	weld.Part1 = effect
	weld.Part0 = rootPart

	self.Effect = effect
end

function Parry:OnRecovery()
	self.Effect:Destroy()
end

function Parry:OnEnd()
	local character = self.Combatant.Instance
	local movementRig = MovementRig:FromInstance(character)

	if self.IsLocal then
		movementRig:ClearOrientation("parry")
		MovementController:ClearSpeedMultiplier("parry")
	end
end

return Parry
