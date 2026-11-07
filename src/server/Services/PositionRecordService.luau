local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local PositionRecordService = {}

function PositionRecordService:_recordPositions()
	for i, player in Players:GetPlayers() do
		local character = player.Character
		if character == nil then continue end

		local rootPart = character:FindFirstChild("HumanoidRootPart")

		local time = Workspace:GetServerTimeNow()
		local cf = rootPart.CFrame


		self.Records[player.UserId] = self.Records[player.UserId] or {}
		table.insert(self.Records[player.UserId], {
			cf = cf,
			time = time,
		})
	end
end

function PositionRecordService:_trimRecords()
	local expiration = Workspace:GetServerTimeNow() - 1
	for _, player in Players:GetPlayers() do
		if self.Records[player.UserId] == nil then continue end

		local i = 1
		while self.Records[player.UserId][i].time < expiration do
			table.remove(self.Records[player.UserId], i)
		end
	end
end

function PositionRecordService:GetCFrameAt(player, t)
	local records = self.Records[player.UserId]
	for i = 1, #records do
		if records[i].time < t and records[i+1].time > t then
			return records[i].cf
		end
	end

	return nil
end

function PositionRecordService:OnStart()
	self.Records = {}

	RunService.Heartbeat:Connect(function()
		self:_recordPositions()
		self:_trimRecords()
	end)
end

return PositionRecordService
