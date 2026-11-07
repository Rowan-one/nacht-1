local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local React = require(ReplicatedStorage.Packages.React)

local e = React.createElement

local RollBar = function(props)
	local ref = React.useRef(nil)

	React.useEffect(function()
		local tween = TweenService:Create(
			ref.current,
			TweenInfo.new(props.duration, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1),
			{ Position = UDim2.new(0.5, 0, 1, props.height) }
		)

		local startThread = task.delay(props.delay, function()
			tween:Play()
		end)

		return function()
			task.cancel(startThread)
			tween:Cancel()
		end
	end)

	return e("Frame", {
		ref = ref,
		Size = UDim2.new(1, 0, 0, props.height),
		BackgroundColor3 = Color3.new(0,0,0),
		BackgroundTransparency = 0.7,
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.fromScale(0.5, 0),
		BorderSizePixel = 0,
		ZIndex = props.ZIndex,
	})
end

return RollBar
