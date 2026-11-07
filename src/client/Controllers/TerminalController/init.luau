local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)

local Terminal = require(script.Parent.Parent.UI.Terminal.Terminal)

local TerminalController = {}

function TerminalController:Open()
	self._root:render(React.createElement(Terminal, {
		onClose = function() self:Close() end
	}))

	self._open = true
end

function TerminalController:Close()
	self._root:render(nil)
	self._open = false
end

function TerminalController:MatchQuery(query)
	local lower = string.lower(query)
	local body = Queries[lower]
	return body or "Query does not match any entries."
end

function TerminalController:OnStart()
	local gui = Instance.new("ScreenGui")
	gui.Name = "Terminal"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.Parent = Players.LocalPlayer.PlayerGui
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	self._root = ReactRoblox.createRoot(gui)
	self._open = false

	ContextActionService:BindAction("OpenTerminal", function(_, state)
		if state == Enum.UserInputState.Begin then
			if self._open then
				self:Close()
			else
				self:Open()
			end
		end
	end, true, Enum.KeyCode.T)
end

return TerminalController
