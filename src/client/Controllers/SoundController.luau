local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Comm = require(ReplicatedStorage.Packages.Comm).ClientComm

local SoundController = {}

local SOUNDS_FOLDER = ReplicatedStorage.Assets.Sounds

function SoundController:Play(soundName, volume)
	local sound = SOUNDS_FOLDER:FindFirstChild(soundName)
	if sound == nil then warn("Sound "..soundName.." not found"); return end
	if not sound:IsA("Sound") then warn("Sound instance for "..soundName.." is not a sound object"); return end

	local clone = sound:Clone()
	clone.Volume = volume or 0.5
	clone.Parent = Workspace.CurrentCamera
	clone:Play()
end

function SoundController:OnStart()
	self.Comm = Comm.new(ReplicatedStorage, false, "SoundService")
	self.PlaySignal = self.Comm:GetSignal("PlaySignal")

	self.PlaySignal:Connect(function(soundName, volume)
		self:Play(soundName, volume)
	end)
end

return SoundController
