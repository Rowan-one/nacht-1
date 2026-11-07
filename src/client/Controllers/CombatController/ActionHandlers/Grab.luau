local StarterPlayer = game:GetService("StarterPlayer")
local ClientAction = require(StarterPlayer.StarterPlayerScripts.Client.Controllers.CombatController.ActionHandlers.ClientAction)

local Grab = {}
Grab.__index = Grab
setmetatable(Grab, ClientAction)

function Grab.new(...)
	local self = ClientAction.new(...)

	return setmetatable(self, Grab)
end

return Grab
