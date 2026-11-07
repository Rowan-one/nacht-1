local HttpService = game:GetService("HttpService")
local StarterPlayer = game:GetService("StarterPlayer")
local Workspace = game:GetService("Workspace")
local SweepDetect = require(script.Parent.SweepDetect)
local DebugController = require(StarterPlayer.StarterPlayerScripts.Client.Controllers.DebugController)
local Hitbox = {}
Hitbox.__index = Hitbox

function Hitbox.new(owner, range, angle, offset, parent, duration, callback)
	local self = {}

	self.Id = HttpService:GenerateGUID(false)
	self.Owner = owner
	self.Range = range
	self.Angle = angle
	self.Offset = offset or Vector3.zero
	self.Parent = parent
	self.StartTime = Workspace:GetServerTimeNow()
	self.EndTime = duration and Workspace:GetServerTimeNow() + duration or nil
	self.Callback = callback

	return setmetatable(self, Hitbox)
end

function Hitbox:Visualize()
	-- get parent cframe
	local parentCF = CFrame.new()
	if self.Parent then
		if self.Parent:IsA("Model") then parentCF = self.Parent:GetPivot()
		elseif self.Parent:IsA("BasePart") then parentCF = self.Parent.CFrame end
	end

	local origin = parentCF
		+ parentCF.LookVector * self.Offset.Z
		+ parentCF.RightVector * self.Offset.X
		+ parentCF.UpVector * self.Offset.Y
	
	local a = math.rad(self.Angle)
	local rotations = {
		CFrame.Angles(a, 0, 0),
		CFrame.Angles(-a, 0, 0),
		CFrame.Angles(0, a, 0),
		CFrame.Angles(0, -a, 0),
	}

	DebugController:DrawLine(origin.Position, origin.Position + origin.LookVector * self.Range, 1/30, Color3.new(1,0,0))

	for _, rot in rotations do
		local dir = (origin * rot).LookVector
		DebugController:DrawLine(origin.Position, origin.Position + dir * self.Range, 1/30, Color3.new(1,1,0))
	end
end

function Hitbox:Check()
	-- get parent cframe
	local parentCF = CFrame.new()
	if self.Parent then
		if self.Parent:IsA("Model") then parentCF = self.Parent:GetPivot()
		elseif self.Parent:IsA("BasePart") then parentCF = self.Parent.CFrame end
	end

	local cf = parentCF
		+ parentCF.LookVector * self.Offset.Z
		+ parentCF.RightVector * self.Offset.X
		+ parentCF.UpVector * self.Offset.Y

	self:Visualize()

	-- get search parts
	local parts = Workspace:GetPartBoundsInRadius(cf.Position, self.Range*2)
	local hits = {}

	for i, part in parts do
		local target = part.CFrame
		local hit = SweepDetect:Cast(cf, target, self.Range, self.Angle)

		if hit then
			DebugController:DrawLine(cf.Position, target.Position, 1, Color3.new(0,1,0))
			table.insert(hits, part)
		end
	end

	-- check for Combatants
	for i, hitPart in hits do
		local model = hitPart.Parent
		if model == self.Parent then continue end
		if model:HasTag("Combatant") then
			return hitPart.Parent
		end
	end

	return nil
end

return Hitbox
