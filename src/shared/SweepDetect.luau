local Workspace = game:GetService("Workspace")
local SweepDetect = {}

function SweepDetect:Cast(from, target, range, angle)
	local look = from.LookVector	
	local resultant = target.Position - from.Position
	local normalResultant = resultant.Unit
	local distance = resultant.Magnitude

	local dot = look:Dot(normalResultant)
	local radAngle = math.acos(dot)
	local degAngle = math.deg(radAngle)

	local inRange = distance <= range
	local inView = degAngle <= angle

	return inRange and inView
end

return SweepDetect
