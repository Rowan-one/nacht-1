local StarterPlayer = game:GetService("StarterPlayer")
local AnimationController = require(script.Parent.Parent.Parent.AnimationController)
local ClientAction = require(StarterPlayer.StarterPlayerScripts.Client.Controllers.CombatController.ActionHandlers.ClientAction)

local LightAttack = {}
LightAttack.__index = LightAttack
setmetatable(LightAttack, ClientAction)

function LightAttack.new(...)
	local self = ClientAction.new(...)

	return setmetatable(self, LightAttack)
end

function LightAttack:OnWindup()
	if self.IsLocal then
		print("Light attack active on client")
		AnimationController:PlayAction("LightPunch", 0.0)
	end

	self.Trove:Add(function()
		print("Trove destroyed")
		if self.IsLocal then
			print("Cancelling anim")
			AnimationController:CancelAction("LightPunch", 0.0)
		end
	end)
end

function LightAttack:OnEnd()
	if self.IsLocal then
		AnimationController:CancelAction("LightPunch", 0.0)
	end
end

return LightAttack
