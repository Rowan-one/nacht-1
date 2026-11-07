local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CombatState = require(ReplicatedStorage.Shared.CombatState)

local ActionRunner = {}
ActionRunner.__index = ActionRunner

local PHASES = { "Windup", "Active", "Recovery", "End" }
local PHASE_TO_ID = {
	Windup = 1,
	Active = 2,
	Recovery = 3,
	End = 4
}

function ActionRunner.new(context, handler)
	local self = {}

	self.Context = context
	self.Handler = handler
	self.Phase = nil

	return setmetatable(self, ActionRunner)
end

function ActionRunner:Step(now)
	local phase = CombatState.derivePhase(self.Context, now) or "End"
	if phase == self.Phase then return end

	local fromId = PHASE_TO_ID[self.Phase] or 0
	for id = fromId + 1, PHASE_TO_ID[phase] do
		self.Phase = PHASES[id]
		self.Handler["On" .. self.Phase](self.Handler)
	end

	if phase == "End" then
		self:Stop()
	end
end

function ActionRunner:Stop()
	if self.Stopped then return end
	self.Stopped = true
	self.Handler:Destroy()
end

return ActionRunner
