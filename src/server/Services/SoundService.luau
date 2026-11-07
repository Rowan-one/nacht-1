local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Comm = require(ReplicatedStorage.Packages.Comm).ServerComm

local SoundService = {}

function SoundService:PlayAll(soundName, volume)
	self.PlaySignal:FireAll(soundName, volume)
end

function SoundService:Play(player, soundName, volume)
	self.PlaySignal:Fire(player, soundName, volume)
end

function SoundService:OnStart()
	self.Comm = Comm.new(ReplicatedStorage, "SoundService")
	self.PlaySignal = self.Comm:CreateSignal("PlaySignal")
end

return SoundService
