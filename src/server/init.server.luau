local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Loader = require(ReplicatedStorage.Packages.Loader)
local Services = ServerScriptService.Server.Services

Loader.SpawnAll(Loader.LoadDescendants(Services, Loader.MatchesName("Service$")), "OnStart")
Loader.LoadDescendants(script.Components)
Loader.LoadDescendants(ReplicatedStorage.Shared.Components)

