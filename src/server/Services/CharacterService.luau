local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Comm = require(ReplicatedStorage.Packages.Comm).ServerComm
local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")
local HealthService = require(script.Parent.HealthService)
local Signal = require(ReplicatedStorage.Packages.Signal)

local CharacterService = {}

function CharacterService:_setupCharacter(character)
	local humanoid = character:FindFirstChildWhichIsA("Humanoid")
	local animator: Animator = humanoid:FindFirstChildWhichIsA("Animator")

	-- clear animations
	-- character:FindFirstChild("Animate"):Destroy()
	-- for _, animation in animator:GetPlayingAnimationTracks() do
	-- 	animation:Stop(0)
	-- end

	-- disable limb collisions
	for i, v in pairs(character:GetChildren()) do
		if v:IsA("BasePart") then
			if v.Name == "HumanoidRootPart" or v.Name == "Torso" then continue end
			v.CollisionGroup = "Limbs"
			v.Massless = true
		end
	end
end

function CharacterService:_resetCharacter(player)
	player:LoadCharacterAsync()
end

function CharacterService:OnStart()
	self.Comm = Comm.new(ReplicatedStorage, "CharacterService")

	PhysicsService:RegisterCollisionGroup("Limbs")
	PhysicsService:CollisionGroupSetCollidable("Limbs", "Default", false)

	HealthService.Died:Connect(function(player)
		self:_resetCharacter(player)
	end)

	self.Comm:BindFunction("SetupCharacter", function(player: Player)
		local character = player.Character
		if character == nil then return end
		self:_setupCharacter(character)
	end)

	self.Comm:BindFunction("ResetCharacter", function(player: Player)
		self:_resetCharacter(player)
	end)
end

return CharacterService
