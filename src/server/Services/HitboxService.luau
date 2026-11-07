local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")
local Combatant = require(ServerScriptService.Server.Components.Combatant)
local DebugService = require(script.Parent.DebugService)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Hitbox = require(ReplicatedStorage.Shared.Hitbox)
local Comm = require(ReplicatedStorage.Packages.Comm).ServerComm

local HitboxService = {
	HitPlayer = Signal.new()
}

function HitboxService:_visualize(origin, hitbox)
	local a = math.rad(hitbox.Angle)
	local rotations = {
		CFrame.Angles(a, 0, 0),
		CFrame.Angles(-a, 0, 0),
		CFrame.Angles(0, a, 0),
		CFrame.Angles(0, -a, 0),
	}

	DebugService:DrawLine(origin.Position, origin.Position + origin.LookVector * hitbox.Range, 1/30, Color3.new(1,1,0))

	for _, rot in rotations do
		local dir = (origin * rot).LookVector
		DebugService:DrawLine(origin.Position, origin.Position + dir * hitbox.Range, 1/30, Color3.new(1,1,0))
	end
end

function HitboxService:_checkActive(dt)
	-- detect collisions for all hitboxes
	for id, hitbox in self.ServerActive do
		-- unregister if expired
		if hitbox.EndTime then
			local t = hitbox.EndTime - Workspace:GetServerTimeNow()
			if t <= 0 then
				self:UnRegister(nil, id)
				continue
			end
		end

		local hitModel = hitbox:Check()

		if hitModel then
			hitbox.Callback(Combatant:FromInstance(hitModel))
			self:UnRegister(nil, id)
			break
		end
	end
end

function HitboxService:_validateHit(attacker, id, victim)
	local hitbox = self.ClientActive[id]
	print("Validating. hitbox:",hitbox)
	if hitbox == nil or hitbox.Owner ~= attacker then return false end
	if victim == nil or victim == attacker then return false end

	local valid = true
	
	if not valid then return false end

	hitbox.Callback(victim)
	self.ClientActive[id] = nil

	return true
end

function HitboxService:Register(owner, range, angle, offset, parent, duration, callback)
	local hitbox = Hitbox.new(owner, range, angle, offset, parent, duration, callback)

	if owner.Player then
		self.ClientActive[hitbox.Id] = hitbox
		self.Registered:Fire(owner.Player, {
			Id = hitbox.Id,
			Range = hitbox.Range,
			Angle = hitbox.Angle,
			Offset = hitbox.Offset,
			Parent = hitbox.Parent,
			EndTime = hitbox.EndTime,
		})
	else
		self.ServerActive[hitbox.Id] = hitbox
	end

	return hitbox.Id
end

function HitboxService:UnRegister(owner, id)
	if owner then
		self.Removed:Fire(owner, self.ClientActive[id])
	else
		self.ServerActive[id] = nil
	end
end

function HitboxService:OnStart()
	self.ServerActive = {}
	self.ClientActive = {}

	self.Comm = Comm.new(ReplicatedStorage, "HitboxService")
	self.Registered = self.Comm:CreateSignal("Registered")
	self.Removed = self.Comm:CreateSignal("Removed")

	self.ValidateHit = self.Comm:BindFunction("ValidateHit", function(player, id, victimModel)
		local character = player.Character
		local attacker = Combatant:FromInstance(character)
		local victim = Combatant:FromInstance(victimModel)
		return self:_validateHit(attacker, id, victim)
	end)

	RunService.Heartbeat:Connect(function(dt)
		self:_checkActive(dt)
	end)
end

return HitboxService
