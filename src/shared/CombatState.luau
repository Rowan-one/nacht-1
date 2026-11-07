local CombatState = {}

function CombatState.derivePhase(context, now)
	local t = now - context.StartTime
	if t < context.Windup then return "Windup" end
	if t < context.Windup + context.ActiveWindow then return "Active" end
	if t < context.Windup + context.ActiveWindow + context.Recovery then return "Recovery" end
	return nil
end

return CombatState
