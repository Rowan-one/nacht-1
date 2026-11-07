local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Component = require(ReplicatedStorage.Packages.Component)
local DefaultMoveStats = require(ReplicatedStorage.Shared.DefaultMoveStats)

local MovementRig = Component.new({
	Tag = "MovementRig",
	Ancestors = { Workspace }
})

function MovementRig:Construct()
	local userId = self.Instance:GetAttribute("ControllerUserId")
	self.Active = if RunService:IsServer()
		then userId == nil -- if server, only enable if not owned by a player
		else userId == Players.LocalPlayer.UserId -- if client, only enable if owned by local player

	if not self.Active then return end

	self._rootPart = if self.Instance:GetAttribute("RootPart")
		then self.Instance:GetAttribute("RootPart"):Get()
		else self.Instance.PrimaryPart

	if self._rootPart == nil then warn("Movement rig need RootPart attribute"); return end

	if RunService:IsServer() then self._rootPart:SetNetworkOwner(nil) end

	self._rootAttachment = if self.Instance:GetAttribute("RootAttachment")
		then self.Instance:GetAttribute("RootAttachment"):Get()
		else self._rootPart:FindFirstChild("RootAttachment")

	if self._rootAttachment == nil then warn("Movement rig needs either RootAttachment attribute or a RootAttachment child of the root part"); return end


	self._customOrientations = {}
	self._forces = {}
	self._stats = table.clone(DefaultMoveStats)
	self._moveVector = Vector3.zero
	self._yVel = 0
	self._grounded = false
	self._speedMultipliers = {}
	self._maxSlope = if self.Instance:GetAttribute("MaxSlopeAngle") then math.rad(self.Instance:GetAttribute("MaxSlopeAngle")) else math.rad(65)
	self._gravity = self.Instance:GetAttribute("Gravity") or 100
	self._cachedVel = Vector3.xAxis * 0.01

	-- horizontal movement
	local move = Instance.new("LinearVelocity", self._rootPart)
	move.Attachment0 = self._rootAttachment
	move.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
	move.PrimaryTangentAxis = Vector3.xAxis
	move.SecondaryTangentAxis = Vector3.zAxis
	move.MaxForce = math.huge

	-- vertical force
	local float = Instance.new("VectorForce", self._rootPart)
	float.Attachment0 = self._rootAttachment
	float.RelativeTo = Enum.ActuatorRelativeTo.World

	-- align orientation
	local align = Instance.new("AlignOrientation", self._rootPart)
	align.Attachment0 = self._rootAttachment
	align.Mode = Enum.OrientationAlignmentMode.OneAttachment
	align.Responsiveness = 100
	align.MaxTorque = 1e6
	align.MaxAngularVelocity = 30
	align.ReactionTorqueEnabled = false

	self._move = move
	self._float = float
	self._align = align
end

function MovementRig:_applyFriction(vel, dt)
	local speed = vel.Magnitude
	if speed <= 0.02 then return Vector3.zero end
	local drop = speed * self._stats.Friction * dt
	return vel * math.max(speed - drop, 0) / speed
end

local LEAN_SPEED = 4
local MAX_LEAN = 0.08

function MovementRig:_applyOrientation(dir, dt)
	local align: AlignOrientation = self._align

	dir = Vector3.new(dir.X, 0, dir.Z)
	if dir.Magnitude <= 0.02 then dir = self._cachedVel end

	self._yaw = self._yaw or select(2, self._rootPart.CFrame:ToOrientation())
	local targetYaw = math.atan2(-dir.X, -dir.Z)
	local diff = (targetYaw - self._yaw + math.pi) % (2 * math.pi) - math.pi
	local alpha = 1 - math.exp(-self._stats.TurnSpeed * dt)
	self._yaw += diff * alpha

	local yawCF = CFrame.Angles(0, self._yaw, 0)

	local vel = (self._moveVector * Vector3.new(1, 0, 1)) * (self._rootPart.AssemblyLinearVelocity * Vector3.new(1, 0, 1)).Magnitude
	local localVel = yawCF:VectorToObjectSpace(vel)
	local maxSpeed = math.max(self._stats.Speed, 0.01)

	local targetPitch = math.clamp(localVel.Z / maxSpeed, -1, 1) * MAX_LEAN
	local targetRoll = math.clamp(-localVel.X / maxSpeed, -1, 1) * MAX_LEAN

	local a = 1 - math.exp(-LEAN_SPEED * dt)
	self._pitch = (self._pitch or 0) + (targetPitch - (self._pitch or 0)) * a
	self._roll = (self._roll or 0) + (targetRoll - (self._roll or 0)) * a

	align.CFrame = CFrame.new(self._rootPart.Position) * yawCF * CFrame.Angles(self._pitch, 0, self._roll)
end

function MovementRig:_springDamper(error, stiffness, vel, damping)
	return error * stiffness - vel * damping
end

function MovementRig:AddSpeedMultiplier(id, mult, snap)
	self._speedMultipliers[id] = mult
	if snap then
		self._snapToSpeed = true
	end
end

function MovementRig:ClearSpeedMultiplier(id)
	self._speedMultipliers[id] = nil
end

function MovementRig:GetSpeedMultiplier()
	local mult = 1
	for id, m in self._speedMultipliers do
		mult *= m
	end

	return mult
end

function MovementRig:Jump()
	if self._grounded then
		self._jumpCooldown = 0.2
		self._yVel = self._stats.JumpPower
	end
end

function MovementRig:Step(dt)
	if not self.Active then return end

	local move: LinearVelocity = self._move
	if not move then warn("Movement rig has no move force"); return end	

	-- ground check
	local params = RaycastParams.new()
	params.FilterDescendantsInstances = { self._rootPart.Parent }
	params.RespectCanCollide = true

	local hit = Workspace:Raycast(self._rootPart.CFrame.Position, Vector3.new(0, -(self._stats.Hover + 1.5), 0), params)

	self._jumpCooldown = math.max((self._jumpCooldown or 0) - dt, 0)

	self._grounded = hit ~= nil and hit.Normal:Angle(Vector3.yAxis) < self._maxSlope and self._jumpCooldown <= 0
	if self._grounded then
		local err = self._stats.Hover - (self._rootPart.CFrame.Position.Y - hit.Position.Y)
		local vel = self._rootPart.AssemblyLinearVelocity.Y
		local a = self:_springDamper(err, 200, vel, 15)
		self._yVel += a * dt
	else
		self._yVel -= self._gravity * dt
	end

	-- horizontal movement
	local speed = self._stats.Speed * self:GetSpeedMultiplier()
	local moveVector = self._moveVector
	moveVector *= Vector3.new(1, 0, 1)
	if moveVector ~= Vector3.zero then
		moveVector = moveVector.Unit
	end

	local moveVel = self:_applyFriction(self._rootPart.AssemblyLinearVelocity * Vector3.new(1,0,1), dt)

	if self._snapToSpeed then
		self._snapToSpeed = false
		if moveVel.Magnitude > speed then
			moveVel = if speed > 0 then moveVel.Unit * speed else Vector3.zero
		end
	end

	local wishDir = moveVector
	local currentSpeed = moveVel:Dot(wishDir)
	local addSpeed = math.clamp(speed - currentSpeed, 0, self._stats.Accel * speed * dt)

	local flat = moveVel + addSpeed * wishDir
	local finalMove = Vector3.new(flat.X, self._yVel, flat.Z)

	-- apply forces
	local totalForce = Vector3.zero
	local now = Workspace:GetServerTimeNow()
	for i, force in self._forces do
		if now >= force.EndTime then
			table.remove(self._forces, i)
			continue
		end
	
		if force.Override then
			finalMove *= Vector3.new(0, 1, 0)
		end

		totalForce += force.Force
	end

	move.VectorVelocity = finalMove + totalForce

	if finalMove.Magnitude > 0.02 then
		self._cachedVel = finalMove
	end
end

function MovementRig:UpdateOrientation(dt)
	if not self.Active then return end

	local dir
	if next(self._customOrientations) == nil then
		local cf: CFrame = self._rootPart.CFrame
		local x,y,z = cf:ToOrientation()
		local current = Vector3.new(x, y, z)
		dir = self._cachedVel
	else 
		local highest = 0
		for id, entry in self._customOrientations do
			if entry.priority > highest then
				highest = entry.priority	
				dir = entry.value
			end
		end
	end

	self:_applyOrientation(dir, dt)
end

function MovementRig:UpdateMoveVector(vec)
	self._moveVector = vec
end

function MovementRig:GetMoveVector()
	return self._moveVector
end

function MovementRig:AddForce(dir, override, duration)
	table.insert(self._forces, {
		Force = dir,
		Override = override,
		EndTime = Workspace:GetServerTimeNow() + duration,
	})
end

function MovementRig:SetOrientation(orientation, priority, id)
	self._customOrientations[id] = {value = orientation, priority = priority}
end

function MovementRig:ClearOrientation(id)
	self._customOrientations[id] = nil
end

function MovementRig:SetStats(stats)
	for statName, value in pairs(stats) do
		if self._stats[statName] == nil then continue end
		self._stats[statName] = value
	end
end

function MovementRig:GetStats()
	return self._stats
end

function MovementRig:GetVelocity()
	return self._cachedVel
end

return MovementRig
