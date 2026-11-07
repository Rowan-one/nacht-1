local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)

local Console = require(script.Parent.Console)

local e = React.createElement

local Desktop = function(props)
	local openApp, setOpenApp = React.useState(nil)

	if openApp == "console" then
		return e(Console, { onExit = function() setOpenApp(nil) end })	
	end

	return e("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ZIndex = props.ZIndex,
	}, {
		Layout = e("UIGridLayout", {
			CellSize = UDim2.fromOffset(200, 200),
			CellPadding = UDim2.fromOffset(50, 50),
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),

		TrainingIcon = e("TextButton", {
			Text = "Training",
			BackgroundTransparency = 0.2,
			BackgroundColor3 = Color3.new(0,0,0),
			BorderSizePixel = 0,
			Font = Enum.Font.Code,	
			TextScaled = true,
			TextColor3 = Color3.new(1,0,0),
			ZIndex = props.ZIndex,
			[React.Event.Activated] = function() setOpenApp("console") end,
		}, {
			Stroke = e("UIStroke", {
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
				Thickness = 0.01,
				Color = Color3.new(1,0.0,0)
			})
		}),

		ConsoleIcon = e("TextButton", {
			Text = "Console",
			BackgroundTransparency = 0.2,
			BackgroundColor3 = Color3.new(0,0,0),
			BorderSizePixel = 0,
			Font = Enum.Font.Code,	
			TextScaled = true,
			TextColor3 = Color3.new(1,0,0),
			ZIndex = props.ZIndex,
			[React.Event.Activated] = function() setOpenApp("console") end,
		}, {
			Stroke = e("UIStroke", {
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
				Thickness = 0.01,
				Color = Color3.new(1,0.0,0)
			})
		}),
	})
end

return Desktop
