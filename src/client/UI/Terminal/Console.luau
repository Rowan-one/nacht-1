local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)

local Queries = require(script.Parent.Queries)

local e = React.createElement

local Console = function()
	local lines, setLines = React.useState({ "> use `help` for more information" })

	local lineLabels = {
		UIListLayout = e("UIListLayout", {
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	}

	for i, line in ipairs(lines) do
		lineLabels["Line"..i] = e("TextLabel", {
			Text = line,
			Size = UDim2.new(1, 0, 0, 24),
			BackgroundTransparency = 1,
			TextColor3 = Color3.new(1, 0, 0),
			Font = Enum.Font.Code,
			TextSize = 24,
			TextXAlignment = Enum.TextXAlignment.Left,
			LayoutOrder = i,
			TextWrapped = true,
			AutomaticSize = Enum.AutomaticSize.Y,
		})
	end

	local input = e("TextBox", {
		Text = "",
		PlaceholderText = "type here...",
		ClearTextOnFocus = false,
		Size = UDim2.fromScale(1, 0.1),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0,
		BackgroundTransparency = 0.5,
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.fromScale(0.5, 1),
		TextColor3 = Color3.new(1, 0, 0),
		TextSize = 45,

		[React.Event.FocusLost] = function(rbx, enterPressed)
			if not enterPressed then return end

			local input = rbx.Text:match("^%s*(.-)%s*$")
			rbx.Text = ""

			if input == "" then return end

			local split = {}
			for word in input:gmatch("%S+") do
				table.insert(split, word)
			end

			local command = split[1]

			local args = table.clone(split)
			table.remove(args, 1)

			local result = Queries:Execute(command, args or {})

			setLines(function(current)
				local new = table.clone(current)
				table.insert(new, "> (input) "..input)
				table.insert(new, "> "..result)
				return new
			end)

			task.defer(function()
				rbx:CaptureFocus()
			end)
		end
	}, {
		Arrow = e("TextLabel", {
			AnchorPoint = Vector2.new(0, 0.5),
			Size = UDim2.new(0, 100, 0.7, 0),
			Position = UDim2.fromScale(0, 0.5),
			Text = "command >",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			TextColor3 = Color3.new(1, 0, 0),
			Font = Enum.Font.Code,
			TextScaled = true,
		}),
	})

	return e("Frame", {
		ClipsDescendants = true,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(1, -100, 1, -100),
		BackgroundTransparency = 1,
	}, {
		Stroke = e("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = Color3.new(0.3, 0, 0)
		}),
		Input = input,
		Lines = e("Frame", {
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(0.5, 0),
			Size = UDim2.fromScale(1, 0.8),
			BorderSizePixel = 0,
			BackgroundTransparency = 0.5,
			BackgroundColor3 = Color3.new(0, 0 ,0),
		}, lineLabels)
	})
end

return Console
