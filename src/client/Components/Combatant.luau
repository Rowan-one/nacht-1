local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local Workspace = game:GetService("Workspace")
local Component = require(ReplicatedStorage.Packages.Component)
local Trove = require(ReplicatedStorage.Packages.Trove)
local ActionContext = require(ReplicatedStorage.Shared.ActionContext)
local ActionRunner = require(ReplicatedStorage.Shared.ActionRunner)
local CombatMoves = require(ReplicatedStorage.Shared.CombatMoves)

local LocalPlayer = Players.LocalPlayer
local ClientScripts = LocalPlayer.PlayerScripts.Client

local Combatant = Component.new({
	Tag = "Combatant",
	Ancestors = { Workspace }
})

function Combatant:Construct()
	self._trove = Trove.new()

	self._currentAction = nil

	self.ActionHandlers = {}
	for i, v in ClientScripts.Controllers.CombatController.ActionHandlers:GetChildren() do
		self.ActionHandlers[v.Name] = require(v)
	end
end

function Combatant:HeartbeatUpdate()
	if self._currentAction then
		self._currentAction:Step(Workspace:GetServerTimeNow())

		if self._currentAction.Stopped then
			self._currentAction = nil
		end
	end
end

function Combatant:TryAction(actionId, startTime)
	local info = nil
	for name, move in CombatMoves do
		if move.id == actionId then info = move; break end
	end
	if info == nil then return false end

	if self.ActionHandlers[actionId] == nil then return false end
	
	print("Starting client action runner")
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

function Combatant:GetCurrentAction()
	return self._currentAction
end

return Combatant
