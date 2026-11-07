local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")
local CombatService = require(ServerScriptService.Server.Services.CombatService)
local Combatant = require(script.Parent.Combatant)
local Component = require(ReplicatedStorage.Packages.Component)

local TestDummy = Component.new({
	Tag = "TestDummy",
	Ancestors = { Workspace }
})

function TestDummy:Construct()

end

function TestDummy:Start()
	self._combatant = Combatant:FromInstance(self.Instance)

	while task.wait(2) do
		CombatService:ValidateAction(self._combatant, "LightAttack", Workspace:GetServerTimeNow())
	end
end

return TestDummy
