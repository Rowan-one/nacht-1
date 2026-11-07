local Debris = game:GetService("Debris")
local Workspace = game:GetService("Workspace")
local DebugController = {}

function DebugController:DrawLine(from, to, duration, color)
	local line = Instance.new("Part")
	line.Material = Enum.Material.Neon
	line.Anchored = true
	line.CanCollide = false
	line.CanQuery = false
	line.Transparency = 0.5
	line.Color = color or Color3.new(0,1,0)

	local dir = from - to
	line.Size = Vector3.new(0.03,0.03,dir.Magnitude)
	line.CFrame = CFrame.lookAt(from, to)
	line.CFrame += line.CFrame.LookVector * dir.Magnitude/2
	line.Parent = Workspace

	if duration == nil then return end
	Debris:AddItem(line, duration)
end

function DebugController:OnStart()
end

return DebugController
