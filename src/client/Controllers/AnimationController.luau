local CaptureService = game:GetService("CaptureService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Animations = require(ReplicatedStorage.Shared.Animations)
local MovementRig = require(ReplicatedStorage.Shared.Components.MovementRig)
local AnimOffsetModifier = require(ReplicatedStorage.Shared.AnimOffsetModifier)

local AnimationController = {}

local Offsets = require(ReplicatedStorage.Shared.AnimationOffsets)
local MOVEMENT = { "Idle", "Walk", "Sprint" }

local WALK_THRESHOLD = 11
local SPRINT_THRESHOLD = 24

local LocalPlayer = Players.LocalPlayer

function AnimationController:_loadAnimations()
	local character = self._character
	if character == nil then warn("Character not found, can't load animations"); return end

	local humanoid = character:WaitForChild("Humanoid")
	local animator: Animator = humanoid:FindFirstChild("Animator")

	for name, id in Animations do
		local anim = Instance.new("Animation")
		anim.AnimationId = "rbxassetid://"..tostring(id)
	
		self._tracks[name] = animator:LoadAnimation(anim)
		print("Loaded animation "..name)
	end
end

function AnimationController:_startMovement()
	for _, name in MOVEMENT do
		local track: AnimationTrack = self._tracks[name]
		track.Priority = Enum.AnimationPriority.Idle
		track.Looped = true
		track:Play(0, 0.001)
	end
end

function AnimationController:_update()
	if not self._tracks then return end

	for _, name in MOVEMENT do
		local track = self._tracks[name]
		if not track.IsPlaying then
				track.Looped = true
				track:Play(0, 0.001)
		end
	end

	local speed = (self:GetVelocity() * Vector3.new(1, 0, 1)).Magnitude

	local idle, walk, sprint = 0, 0, 0
	if speed > WALK_THRESHOLD then
		local t = math.clamp((speed - WALK_THRESHOLD) / (SPRINT_THRESHOLD - WALK_THRESHOLD), 0, 1)
		idle, walk, sprint = 0, 1-t, t
	end

	self._tracks.Idle:AdjustWeight(idle, 0.2)
	self._tracks.Walk:AdjustWeight(walk, 0.2)
	self._tracks.Sprint:AdjustWeight(sprint, 0.2)
end

function AnimationController:_applyOffsets()
	for animName, joints in Offsets	do
		local track: AnimationTrack = self._tracks[animName]

		local w = track and track.IsPlaying and track.WeightCurrent or 0
		if w <= 0 then continue end

		local progress = track.TimePosition / track.Length

		for jointName, data in joints do
			local motor = self._motors[jointName]
			if motor == nil then continue end
			
			local offset = data.Offset
			local curve = 1
			if data.Peak then
				curve = AnimOffsetModifier.PeakWeight(progress, data.Peak)
			end

			motor.Transform = motor.Transform * CFrame.identity:Lerp(offset, w*curve)
		end
	end
end

function AnimationController:GetVelocity()
	if self._movementRig == nil then return Vector3.zero end

	return self._movementRig:GetVelocity()
end

function AnimationController:PlayIdle(animName, duration, fadeTime, priority)
	local track: AnimationTrack = self._tracks[animName]
	if not track then return nil end

	track.Priority = Enum.AnimationPriority.Movement
	track.Looped = true

	track:Play(fadeTime)

	if duration then
		task.delay(duration, function()
			track:Stop()
		end)
	end

	return track
end

function AnimationController:StopIdle(animName, fadeTime)
	local track: AnimationTrack = self._tracks[animName]

	track:Stop(fadeTime)
end

function AnimationController:PlayAction(animName, fadeTime)
	local track: AnimationTrack = self._tracks[animName]
	if not track then return nil end

	track.Priority = Enum.AnimationPriority.Action
	track.Looped = false

	track:Play(fadeTime)

	return track
end

function AnimationController:CancelAction(animName, fadeTime)
	local track = self._tracks[animName]
	if not track or not track.IsPlaying then return nil end

	track:Stop(fadeTime)

	return track
end

function AnimationController:OnStart()
	self._tracks = {}

	local function setup(character)
		self._character = character	

		MovementRig:WaitForInstance(character, 5):andThen(function(rig)
			self._movementRig = rig	
		end)
		self:_loadAnimations()
		self:_startMovement()

		task.wait(1)
		self._motors = {}
		for _, m in character:GetDescendants() do
			if m:IsA("Motor6D") then self._motors[m.Name] = m end
		end
		print("Motors:",self._motors)
	end

	setup(LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait())

	LocalPlayer.CharacterAdded:Connect(function(character)
		setup(character)
	end)

	RunService.RenderStepped:Connect(function(dt)
		self:_update()
	end)

	RunService.PreSimulation:Connect(function()
		self:_applyOffsets()
	end)
end

return AnimationController
