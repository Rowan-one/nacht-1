local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage.Packages.Signal)
local HealthService = {
	Died = Signal.new(),
	Damaged = Signal.new(),
}

local DEFAULT_HEALTH = 100

function HealthService:Damage(player, amount)
	print("Healths:",self.Health, "health:",self.Health[player.UserId],"userid:",player.UserId,"player:",player)
	self.Health[player.UserId] -= amount
	print("player health is now",self.Health[player.UserId])

	if self:IsDead(player) then
		print("Player dead")
		self.Died:Fire(player)
		self.Health[player.UserId] = DEFAULT_HEALTH
	end
end

function HealthService:IsDead(player)
	return self.Health[player.UserId] <= 0
end

function HealthService:OnStart()
	self.Health = {}

	local function onPlayerAdded(player)
		self.Health[player.UserId] = DEFAULT_HEALTH
	end

	Players.PlayerAdded:Connect(onPlayerAdded)
	for _, player in Players:GetPlayers() do
		onPlayerAdded(player)
	end

	Players.PlayerRemoving:Connect(function(player)
		self.Health[player.UserId] = nil
	end)
end

return HealthService
