local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local e = React.createElement

local FRAMES = { `-`, `\\`, `|`, `/` }
local SPEED = 0.25

local function Logo()
	local frame, setFrame = React.useState(1)

	React.useEffect(function()
		local running = true	
		task.spawn(function()
			while running do
				task.wait(SPEED)
				setFrame(function(f)
					return f % #FRAMES + 1
				end)
			end
		end)
		return function()
			running = false
		end
	end, {})

	return e("TextLabel", {
		Text = FRAMES[frame].." eth.os",
		Font = Enum.Font.Code,
		TextSize = 24,
		TextColor3 = Color3.new(1,0,0),
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0, 0),
		Position = UDim2.new(0, 12, 0, 8),
		Size = UDim2.fromOffset(200, 24)
	})
end

return Logo
