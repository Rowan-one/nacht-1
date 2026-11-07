local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")
local Workspace = game:GetService("Workspace")
local Combatant = require(StarterPlayer.StarterPlayerScripts.Client.Components.Combatant)
local AnimationController = require(script.Parent.AnimationController)
local StaminaController = require(script.Parent.StaminaController)
local CombatMoves = require(ReplicatedStorage.Shared.CombatMoves)
local Comm = require(ReplicatedStorage.Packages.Comm).ClientComm

local CombatController = {}

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

function CombatController:_startAction(combatantModel, actionId, startTime)
	if combatantModel == nil then return end
	local combatant = Combatant:FromInstance(combatantModel)
	if combatant == nil then warn("Model has no combatant component",combatantModel); return end

	combatant:TryAction(actionId, startTime)
end

function CombatController:_request(actionId, startTime)
	local combatant = Combatant:FromInstance(LocalPlayer.Character)
	if combatant == nil then return end
	if self.Active == false then return end
	if combatant:GetCurrentAction() then return end

	local info  = CombatMoves[actionId]
	if info and StaminaController:GetStamina() < (info.staminaCost or 0) then return end

	-- fire server request
	self.RequestAction:Fire(actionId, startTime)

	-- keep local copy on client
	self:_startAction(LocalPlayer.Character, actionId, startTime)
end

function CombatController:_cancel(combatantModel)
	local combatant = Combatant:FromInstance(combatantModel)
	if combatant == nil then warn("Model has no combatant component",combatantModel); return end

	combatant:StopAction()
end

function CombatController:_onCombatActiveChanged(active)
	self.Active = active
	if active then
		AnimationController:PlayIdle("UnarmedIdle")
	else
		AnimationController:StopIdle("UnarmedIdle")
	end
end

function CombatController:OnStart()
	self.Active = false
	self.Actions = {}

	self.Handlers = {}
	for i, handler in script.ActionHandlers:GetChildren() do
		self.Handlers[handler.Name] = require(handler)
	end

	-- comm
	self.Comm = Comm.new(ReplicatedStorage, false, "CombatService")

	self.Comm:GetSignal("CombatActiveChanged"):Connect(function(status) self:_onCombatActiveChanged(status) end)
	self.Comm:GetSignal("Cancel"):Connect(function() self:_cancel(LocalPlayer.Character) end)

	self.Comm:GetSignal("ClientActionStarted"):Connect(function(combatantModel, actionId, startTime) self:_startAction(combatantModel, actionId, startTime) end)
	self.Comm:GetSignal("ClientActionStopped"):Connect(function(combatantModel) self:_cancel(combatantModel) end)

	self.SetCombatEnabled = self.Comm:GetSignal("SetCombatEnabled")
	self.RequestAction = self.Comm:GetSignal("RequestAction")
	self.StopAction = self.Comm:GetSignal("StopAction")

	-- input	
	
	ContextActionService:BindAction("SetCombatEnabled", function(_, state)
		if state == Enum.UserInputState.Begin then
			local enabled = not self.Active
			self.SetCombatEnabled:Fire(enabled)
		end
	end, true, Enum.KeyCode.G)

	Mouse.Button1Down:Connect(function()
		self:_request(CombatMoves.LightAttack.id, Workspace:GetServerTimeNow())
	end)	

	ContextActionService:BindAction("Dash", function(_, state)
		if state == Enum.UserInputState.Begin then
			self:_request(CombatMoves.Dash.id, Workspace:GetServerTimeNow())
		end
	end, true, Enum.KeyCode.E)
	
	ContextActionService:BindAction("Parry", function(_, state)
		if state == Enum.UserInputState.Begin then
			self:_request(CombatMoves.Parry.id, Workspace:GetServerTimeNow())
		end
	end, true, Enum.KeyCode.Q)

	ContextActionService:BindAction("StartBlock", function(_, state)
		if state == Enum.UserInputState.Begin then
			self:_request(CombatMoves.Block.id, Workspace:GetServerTimeNow())
		elseif state == Enum.UserInputState.End then
			self:_cancel(LocalPlayer.Character)
			self.StopAction:Fire()
		end
	end, true, Enum.KeyCode.F)

	ContextActionService:BindAction("Grab", function(_, state)
		if state == Enum.UserInputState.Begin then
			self:_request(CombatMoves.Grab.id, Workspace:GetServerTimeNow())
		end
	end, true, Enum.KeyCode.C)
end

return CombatController
