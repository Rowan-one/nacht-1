local CollectionService = game:GetService("CollectionService")
local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local MovementRig = require(ReplicatedStorage.Shared.Components.MovementRig)
local CharacterController = require(script.Parent.CharacterController)
local Comm = require(ReplicatedStorage.Packages.Comm).ClientComm

local MovementController = {}

local States = require(script.States)

local LocalPlayer = Players.LocalPlayer

function MovementController:_resolveState()
	local name = "Default"
	if self._sprinting and self._stamina > 0 then
		name = "Sprint"
	end

	if name == self._state then return end

	local newState = States[name]
	if newState == nil then warn("State "..name.." not found."); return end

	self._state = name

	if self._movementRig == nil then return end

	self._movementRig:SetStats(States[name])
end

function MovementController:_setShiftLock(enabled)
	self._shiftLockEnabled = enabled

	self._humanoid.CameraOffset = enabled and Vector3.new(1.75, 0, 0) or Vector3.zero

	if enabled then
		RunService:BindToRenderStep("ShiftLock", Enum.RenderPriority.Camera.Value + 1, function()
			UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter

			local look = Workspace.CurrentCamera.CFrame.LookVector
			local flat = Vector3.new(look.X, 0, look.Z)
			if flat.Magnitude > 0 and self._movementRig then
				self._movementRig:SetOrientation(flat, 1, "shiftlock")
				-- self._root.CFrame = CFrame.lookAlong(self._root.Position, flat)
			end
		end)
	else
		self._movementRig:ClearOrientation("shiftlock")
		RunService:UnbindFromRenderStep("ShiftLock")
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	end
end

function MovementController:AddSpeedMultiplier(id, multiplier, snap)
	if self._movementRig == nil then return end
	self._movementRig:AddSpeedMultiplier(id, multiplier, snap)
end

function MovementController:ClearSpeedMultiplier(id)
	if self._movementRig == nil then return end
	self._movementRig:ClearSpeedMultiplier(id)
end

function MovementController:InitRig(character)
	print("Initializing rig",character)
	CharacterController:Setup(character)

	self._character = character
	self._root = character:WaitForChild("HumanoidRootPart")
	self._humanoid = character:WaitForChild("Humanoid")
	
	-- add movement rig component
	character:SetAttribute("RootPart", self._root)
	character:SetAttribute("RootAttachment", self._root:FindFirstChild("RootAttachment"))
	character:SetAttribute("ControllerUserId", LocalPlayer.UserId)
	CollectionService:AddTag(character, "MovementRig")

	MovementRig:WaitForInstance(character):andThen(function(rig)
		self._movementRig = rig
	end)
end

function MovementController:OnStart()
	self.Comm = Comm.new(ReplicatedStorage, false, "MovementService")
	self._setSprinting = self.Comm:GetSignal("SetSprinting")

	self:_resolveState()
	self._shiftLockEnabled = false
	self._stamina = 100

	-- get controls
	local playerModule = LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")
	playerModule = require(playerModule)
	self._controls = playerModule:GetControls()

	-- setup character
	local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()	
	self:InitRig(character)
	LocalPlayer.CharacterAdded:Connect(function(character)
		self:InitRig(character)
	end)

	--bind signals
	self.Comm:GetSignal("SetSpeedMultiplier"):Connect(function(id, multiplier)
		if self._movementRig == nil then return end
		if multiplier == nil then
			self:ClearSpeedMultiplier(id)
		else
			self:AddSpeedMultiplier(id, multiplier, true)
		end
	end)
	
	-- stop sprint on stamina 0
	local staminaComm = Comm.new(ReplicatedStorage, false, "StaminaService")
	staminaComm:GetProperty("Stamina"):Observe(function(stamina)
		self._stamina = stamina
		if stamina <= 0 then
			self._sprinting = false
			self._setSprinting:Fire(self._sprinting)
		end
	end)

	-- bind jump
	ContextActionService:BindAction("Jump", function(_, state)
		self._movementRig:Jump()
		return Enum.ContextActionResult.Sink
	end, true, Enum.PlayerActions.CharacterJump)	

	-- bind sprint
	ContextActionService:BindAction("Sprint", function(_, state)
		if state == Enum.UserInputState.Begin then
			self._sprinting = true
			self._setSprinting:Fire(self._sprinting)
		elseif state == Enum.UserInputState.End then
			self._sprinting = false
			self._setSprinting:Fire(self._sprinting)
		end
	end, true, Enum.KeyCode.LeftShift)

	-- bind shift lock
	ContextActionService:BindAction("ToggleShiftLock", function(_, state)
		if state == Enum.UserInputState.Begin then
			self:_setShiftLock(not self._shiftLockEnabled)
		end
	end, true, Enum.KeyCode.LeftControl)

	-- bind render stepped
	RunService.Stepped:Connect(function(_, dt)
		self:_resolveState()
		
		local moveVector = self._controls:GetMoveVector()
		local world = Workspace.CurrentCamera.CFrame:VectorToWorldSpace(moveVector)

		if self._movementRig then
			self._movementRig:UpdateMoveVector(world)
		end
	end)

	RunService:BindToRenderStep("MovementRigStep", Enum.RenderPriority.Camera.Value + 2, function(dt)
		if self._movementRig then
			self._movementRig:Step(dt)
			self._movementRig:UpdateOrientation(dt)
		end
	end)
end

return MovementController
