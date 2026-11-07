local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Comm = require(ReplicatedStorage.Packages.Comm).ClientComm
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)

local StaminaBar = require(script.Parent.Parent.UI.StaminaBar)

local StaminaController = {}

function StaminaController:GetStamina()
	return self.Stamina
end

function StaminaController:OnStart()
	self.Stamina = 100

	local gui = Instance.new("ScreenGui")
	gui.Name = "Stamina"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.Parent = Players.LocalPlayer.PlayerGui
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	self._root = ReactRoblox.createRoot(gui)
	self._root:render(React.createElement(StaminaBar, { stamina = 100, max = 100 }))

	local comm = Comm.new(ReplicatedStorage, false, "StaminaService")
	comm:GetProperty("Stamina"):Observe(function(stamina)
		self.Stamina = stamina
		self._root:render(React.createElement(StaminaBar, { stamina = stamina, max = 100 }))
	end)
end

return StaminaController
