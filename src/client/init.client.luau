local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local Loader = require(ReplicatedStorage.Packages.Loader)
local Controllers = script.Controllers

Loader.SpawnAll(Loader.LoadDescendants(Controllers, Loader.MatchesName("Controller$")), "OnStart")
Loader.LoadDescendants(script.Components)
Loader.LoadDescendants(ReplicatedStorage.Shared.Components)

