local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Comm = require(ReplicatedStorage.Packages.Comm).ClientComm

local CharacterController = {}

local LocalPlayer = Players.LocalPlayer

-- strip character down to bare bones
function CharacterController:Setup(character)
	print("Character:",character)
	local humanoid: Humanoid = character:WaitForChild("Humanoid")	

	humanoid.EvaluateStateMachine = false
	humanoid.WalkSpeed = 0
	humanoid.AutoRotate = false

	-- check health
	humanoid.HealthChanged:Connect(function(health)
		if health == 0 then
			self.ResetCharacter()
		end
	end)

	-- call server
	while self.SetupCharacter == nil do task.wait() end
	self.SetupCharacter()
end

function CharacterController:OnStart()
	-- setup comm
	self.Comm = Comm.new(ReplicatedStorage, false, "CharacterService")
	self.SetupCharacter = self.Comm:GetFunction("SetupCharacter")
	self.ResetCharacter = self.Comm:GetFunction("ResetCharacter")
end

return CharacterController
