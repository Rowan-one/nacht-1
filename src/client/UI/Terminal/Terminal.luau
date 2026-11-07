local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local TerminalScreen = require(StarterPlayer.StarterPlayerScripts.Client.UI.Terminal.TerminalScreen)
local React = require(ReplicatedStorage.Packages.React)

local e = React.createElement

local Terminal = function()
	return e("Frame", {
		Size = UDim2.fromScale(0.8, 0.8),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.new(0.01, 0.01, 0.01),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5)
	}, {
		AspectRatio = e("UIAspectRatioConstraint", { AspectRatio = 1.77 }),
		Screen = e(TerminalScreen),
	})
end

return Terminal
