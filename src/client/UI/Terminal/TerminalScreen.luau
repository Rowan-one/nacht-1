local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)

local e = React.createElement

local Logo = require(script.Parent.Logo)
local Desktop = require(script.Parent.Desktop)
local ScanLines = require(script.Parent.ScanLines)
local RollBar = require(script.Parent.RollBar)

local function TerminalScreen(props)
	return e(
		"Frame",
		{
			Size = UDim2.new(1, -150, 1, -150),
			BackgroundColor3 = Color3.new(0.05,0,0),
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			ClipsDescendants = true,
		},
		{
			ScanLines = e(ScanLines, { ZIndex = 2}),
			RollBar = e(RollBar, { duration = 5, height = 200, delay = 0, ZIndex = 0}),
			Logo = e(Logo),
			Desktop = e(Desktop, { ZIndex = 1 }),

			Stroke = e("UIStroke", {
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
				Thickness = 0.001,
				Color = Color3.new(1,0.0,0)
			}),
		}
	)
end

return TerminalScreen
