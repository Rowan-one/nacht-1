local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")
local MovementService = require(ServerScriptService.Server.Services.MovementService)
local StaminaService = require(ServerScriptService.Server.Services.StaminaService)
local Component = require(ReplicatedStorage.Packages.Component)
local Trove = require(ReplicatedStorage.Packages.Trove)
local ActionContext = require(ReplicatedStorage.Shared.ActionContext)
local ActionRunner = require(ReplicatedStorage.Shared.ActionRunner)
local CombatMoves = require(ReplicatedStorage.Shared.CombatMoves)

local Combatant = Component.new({
	Tag = "Combatant",
	Ancestors = { Workspace }
})

function Combatant:Construct()
	self._trove = Trove.new()
	self._effects = {}
	self._currentAction = nil

	self.Player = Players:GetPlayerFromCharacter(self.Instance) or nil
	self.CombatActive = self.Player == nil
	print("Player added to combatant:",self.Player)

	self.ActionHandlers = {}
	for i, v in pairs(ServerScriptService.Server.Services.CombatService.ActionHandlers:GetChildren()) do
		self.ActionHandlers[v.Name] = require(v)
	end
end

function Combatant:Stop()

end

function Combatant:HeartbeatUpdate(dt)
	if self._currentAction == nil then return end

	self._currentAction:Step(Workspace:GetServerTimeNow())

	local drain = self._currentAction.Context.StaminaDrain
	if drain and self.Player then
		print("draining stamina",drain*dt)
		StaminaService:Drain(self.Player, drain * dt)
		if StaminaService:Get(self.Player) == 0 then
			self:StopAction(self.Player, true)
		end
	end

	if self._currentAction and self._currentAction.Stopped then
		self._currentAction = nil
	end
end

function Combatant:TryAction(actionId, startTime)
	if not self:IsCombatActive() then return false end
	if self._currentAction then return false end
	if table.find(self:GetEffects(), "Stunned") then return false end

	local info = nil
	for name, move in CombatMoves do
		if move.id == actionId then info = move; break end
	end
	if not info then return false end

	if self.Player then
		if not StaminaService:TrySpend(self.Player, info.staminaCost or 0) then return end
	end

	local ctx = ActionContext.new(info, startTime)
	self._currentAction = ActionRunner.new(ctx, self.ActionHandlers[actionId].new(self, ctx))

	return true
end

function Combatant:StopAction()
	local runner = self._currentAction
	if runner == nil then return end
	runner:Stop()
	self._currentAction = nil
end

function Combatant:AddEffect(effect)
	if table.find(self._effects, effect) then return end
	table.insert(self._effects, effect)
end

function Combatant:RemoveEffect(effect)
	print("About to remove effect",effect)
	if not table.find(self._effects, effect) then return end
	print("Removing.")

	for i, v in pairs(self._effects) do
		if v == effect then
			table.remove(self._effects, i)
		end
	end
end

function Combatant:Stun(duration)
	print("STUNNED!")
	self:AddEffect("Stunned")

	MovementService:SetSpeedMultiplier(self.Player, "stun", 0)

	task.delay(duration, function()
		self:RemoveEffect("Stunned")
		MovementService:SetSpeedMultiplier(self.Player, "stun", nil)
	end)
end

function Combatant:SetCombatActive(isActive)
	self.CombatActive = isActive
end

function Combatant:IsCombatActive()
	return self.CombatActive
end

function Combatant:GetEffects()
	return self._effects
end

return Combatant
