local Workspace = game:GetService("Workspace")
local ActionContext = {}
ActionContext.__index = ActionContext

function ActionContext.new(info, startTime)
	local self = {}

	self.StartTime = startTime
	self.ActionId = info.id
	self.Windup = info.windup or 0
	self.ActiveWindow = info.activeWindow or math.huge
	self.Recovery = info.recovery or 0
	self.Damage = info.damage or nil
	self.StaminaDrain = info.staminaDrain or nil
	self.EndTime = Workspace:GetServerTimeNow() + self.Windup + self.ActiveWindow + self.Recovery

	return setmetatable(self, ActionContext)
end

return ActionContext
