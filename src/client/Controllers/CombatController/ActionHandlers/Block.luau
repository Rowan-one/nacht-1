local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local Workspace = game:GetService("Workspace")
local MovementRig = require(ReplicatedStorage.Shared.Components.MovementRig)
local ClientAction = require(StarterPlayer.StarterPlayerScripts.Client.Controllers.CombatController.ActionHandlers.ClientAction)

local Block = {}
Block.__index = Block
setmetatable(Block, ClientAction)

function Block.new(...)
	local self = ClientAction.new(...)

	return setmetatable(self, Block)
end

function Block:OnActive()
	local character = self.Combatant.Instance
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	local movementRig = MovementRig:FromInstance(character)

	if self.IsLocal then
		movementRig:AddSpeedMultiplier("block", 0)
	end

	local effect = Instance.new("Part", Workspace)
	effect.Color = Color3.new(1,1,1)
	effect.Material = Enum.Material.Neon
	effect.CanCollide = false
	effect.Size = Vector3.new(1.5,1.5,0.5)
	effect.CFrame = rootPart.CFrame + rootPart.CFrame.LookVector * 1
	local weld = Instance.new("WeldConstraint", effect)
	weld.Part1 = effect
	weld.Part0 = rootPart

	self.Effect = effect

	self.Trove:Add(function()
		self.Effect:Destroy()
		if self.IsLocal then
			movementRig:ClearSpeedMultiplier("block")
		end
	end)
end

function Block:OnRecovery()
	local character = self.Combatant.Instance
	local movementRig = MovementRig:FromInstance(character)

	self.Effect:Destroy()
	movementRig:ClearSpeedMultiplier("block")
end

return Block
