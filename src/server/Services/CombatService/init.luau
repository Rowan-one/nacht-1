local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Combatant = require(ServerScriptService.Server.Components.Combatant)
local HealthService = require(script.Parent.HealthService)
local StaminaService = require(script.Parent.StaminaService)
local SoundService = require(script.Parent.SoundService)
local Comm = require(ReplicatedStorage.Packages.Comm).ServerComm

local CombatService = {}

function CombatService:_stopAction(combatant, notifyOwner)
	if combatant == nil then return end

	combatant:StopAction()

	if notifyOwner and combatant.Player then
		self.Cancel:Fire(combatant.Player)
	end
	
	for i, otherPlayer in Players:GetPlayers() do
		if otherPlayer == combatant.Player then continue end
		self.ClientActionStopped:Fire(otherPlayer, combatant.Instance)
	end
end

function CombatService:ValidateAction(combatant, actionId, startTime)
	local success = combatant:TryAction(actionId, startTime)
	if not success then 
		if combatant.Player then self.Cancel:Fire(combatant.Player); end
		return
	end

	for i, otherPlayer in Players:GetPlayers() do
		if otherPlayer == combatant.Player then continue end
	
		self.ClientActionStarted:Fire(otherPlayer, combatant.Instance, actionId, startTime)
	end
end

function CombatService:ResolveHit(action, attacker, victim)
	local effects = victim:GetEffects()

	if table.find(effects, "Parry") then return "Parried" end
	if table.find(effects, "Blocking") then return "Blocked" end

	return "Hit"
end

function CombatService:OnHit(victim, damage, hitSound)
	SoundService:PlayAll(hitSound, 1)

	if victim.Player == nil then return end
	HealthService:Damage(victim.Player, damage)
end

function CombatService:OnParried(attacker)
	SoundService:PlayAll("ParrySuccess", 1)
	attacker:Stun(2)
end

function CombatService:OnBlockedHit(victim)
	SoundService:PlayAll("BlockedPunch", 1)

	if victim.Player == nil then return end
	StaminaService:Drain(victim.Player, 10)
	if StaminaService:Get(victim.Player) <= 0 then
		self:_stopAction(victim, true)
		victim:Stun(1)
	end
end

function CombatService:IsCombatEnabled(player)
	return self:GetCombatant(player):IsCombatActive()
end

function CombatService:GetCombatant(player)
	local character = player.Character
	if character == nil then return nil end

	return Combatant:FromInstance(character)
end

function CombatService:GetActionHandler(id)
	return self.Actions[id]
end

function CombatService:OnStart()
	self.Comm = Comm.new(ReplicatedStorage, "CombatService")

	self.SetCombatEnabled = self.Comm:CreateSignal("SetCombatEnabled") -- called from client
	self.CombatActiveChanged = self.Comm:CreateSignal("CombatActiveChanged") -- server reply

	self.ClientActionStarted = self.Comm:CreateSignal("ClientActionStarted")
	self.ClientActionStopped = self.Comm:CreateSignal("ClientActionStopped")

	self.ActionRequested = self.Comm:CreateSignal("RequestAction")
	self.ActionStopRequested = self.Comm:CreateSignal("StopAction")
	self.Cancel = self.Comm:CreateSignal("Cancel")

	-- Connect client signals
	self.ActionRequested:Connect(function(player, actionId, startTime)
		local character = player.Character
		local combatant = Combatant:FromInstance(character)
		self:ValidateAction(combatant, actionId, startTime)
	end)

	self.ActionStopRequested:Connect(function(player)
		local character = player.Character
		local combatant = Combatant:FromInstance(character)
		self:_stopAction(combatant)
	end)

	self.SetCombatEnabled:Connect(function(player, enabled)
		local character = player.Character
		local combatant = Combatant:FromInstance(character)
		combatant:SetCombatActive(enabled)
		self.CombatActiveChanged:Fire(player, enabled)
	end)

	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function(character)
			CollectionService:AddTag(character, "Combatant")
		end)
	end)
end

return CombatService
