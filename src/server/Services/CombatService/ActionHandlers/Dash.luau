local ServerScriptService = game:GetService("ServerScriptService")
local ServerAction = require(ServerScriptService.Server.Services.CombatService.ActionHandlers.ServerAction)

local Dash = {}
Dash.__index = Dash
setmetatable(Dash, ServerAction)

function Dash.new(...)
	local self = ServerAction.new(...)

	return setmetatable(self, Dash)
end

return Dash
