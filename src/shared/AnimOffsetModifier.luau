local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Trove = require(ReplicatedStorage.Packages.Trove)

local AnimOffsetModifier = {}

function AnimOffsetModifier.PeakWeight(t, peak)
	local t = math.clamp(t, 0, 1)

	local w
	if t <= peak then
		w = if peak > 0 then t / peak else 1
	else
		w = if peak < 1 then (1 - t) / (1 - peak) else 1
	end

	return w*w*(3-2*w)
end

return AnimOffsetModifier
