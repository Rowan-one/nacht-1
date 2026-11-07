local ServerScriptService = game:GetService("ServerScriptService")
local CombatService = require(ServerScriptService.Server.Services.CombatService)
local ServerAction = require(ServerScriptService.Server.Services.CombatService.ActionHandlers.ServerAction)
local HitboxService = require(ServerScriptService.Server.Services.HitboxService)

local Grab = {}
Grab.__index = Grab
setmetatable(Grab, ServerAction)

function Grab.new(...)
	local self = ServerAction.new(...)

	return setmetatable(self, Grab)
end

function Grab:_attach()
	print("GRABBED!")
	self.Combatant.Instance.HumanoidRootPart:SetNetworkOwner(nil)
end

function Grab:OnActive()
	local id
	id = HitboxService:Register(self.Combatant, 6, 50, Vector3.new(0,-1,-1), self.Combatant.Instance, self.Context.ActiveWindow, function(hitCombatant)
		local result = CombatService:ResolveHit(self, self.Combatant, hitCombatant)
		if result == "Parried" then
			CombatService:OnParried(self.Combatant)
		end

		self:_attach()
	end)
end

return Grab
