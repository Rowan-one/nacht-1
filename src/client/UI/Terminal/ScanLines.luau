local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local React = require(ReplicatedStorage.Packages.React)

local LINE_COUNT = 300
local LINE_GAP = 5

local e = React.createElement

local ScanLines = function(props)
	local lines = {
		Layout = e("UIListLayout", { Padding = UDim.new(0, LINE_GAP)})
	}

	for i = 1, LINE_COUNT do
		lines["Line"..i] = e("Frame", {
			Size = UDim2.new(1, 0, 0, 3),
			BackgroundColor3 = Color3.new(0,0,0),
			BackgroundTransparency = 0.8,
			BorderSizePixel = 0,
			LayoutOrder = i,
		})
	end

	return e("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		ZIndex = props.ZIndex,
		Interactable = false,
	}, {
		Lines = e("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
		}, lines),
	})
end

return ScanLines
