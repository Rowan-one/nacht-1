local ServerScriptService = game:GetService("ServerScriptService")
local HealthService = require(ServerScriptService.Server.Services.HealthService)
local HitboxService = require(ServerScriptService.Server.Services.HitboxService)
local SoundService = require(ServerScriptService.Server.Services.SoundService)
local StaminaService = require(ServerScriptService.Server.Services.StaminaService)
local ServerAction = require(script.Parent.ServerAction)
local CombatService = require(script.Parent.Parent)

local LightAttack = {}
LightAttack.__index = LightAttack
setmetatable(LightAttack, ServerAction)

function LightAttack.new(...)
	local self = ServerAction.new(...)

	return setmetatable(self, LightAttack)
end

function LightAttack:OnActive()
	HitboxService:Register(self.Combatant, 6, 50, Vector3.new(0,-1,-1), self.Combatant.Instance, self.Context.ActiveWindow, function(hitCombatant)
		print("Hitbox callback called")
		local result = CombatService:ResolveHit(self, self.Combatant, hitCombatant)
		if result == "Hit" then
			CombatService:OnHit(hitCombatant, self.Context.Damage, "Hit")
		elseif result == "Blocked" then
			CombatService:OnBlockedHit(hitCombatant)
		elseif result == "Parried" then
			CombatService:OnParried(self.Combatant)
		end
	end)
end

return LightAttack
