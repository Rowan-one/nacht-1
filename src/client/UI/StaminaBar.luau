local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local React = require(ReplicatedStorage.Packages.React)

local e = React.createElement

local StaminaBar = function(props)
	local fillRef = React.useRef(nil)
	local fraction = math.clamp(props.stamina / props.max, 0, 1)

	React.useEffect(function()
		local fill = fillRef.current
		if fill == nil then return end

		local tween = TweenService:Create(fill, TweenInfo.new(0.15, Enum.EasingStyle.Quad), { Size = UDim2.fromScale(fraction, 1) })
		tween:Play()
		return function() tween:Cancel() end
	end, { fraction })

	return e("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.7, 0),
		Size = UDim2.fromOffset(200, 10),
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		ClipsDescendants = true,
	}, {
		Fill = e("Frame", {
			ref = fillRef,
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
		}, {
			UICorner = e("UICorner", {})
		}),

		AspectRatio = e("UIAspectRatioConstraint", {
			AspectRatio = 30
		}),
	})
end

return StaminaBar
