-- Ponto de entrada do servidor.

local Players = game:GetService("Players")

local Modules = script.Parent.ModuleScripts
local DataModule = require(Modules.DataModule)
local leaderboardModule = require(Modules.leaderboardModule)
local TrainingModule = require(Modules.TrainingModule)
local ShopModule = require(Modules.ShopModule)
local EnemyModule = require(Modules.EnemyModule)
local CombatModule = require(Modules.CombatModule)

local function onPlayerAdded(player)
	local data = DataModule.load(player)
	if not player.Parent then
		DataModule.release(player) -- saiu durante o carregamento
		return
	end
	leaderboardModule.setupLeaderboard(player, data)
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, player in Players:GetPlayers() do
	task.spawn(onPlayerAdded, player)
end

Players.PlayerRemoving:Connect(function(player)
	DataModule.release(player)
end)

game:BindToClose(function()
	for _, player in Players:GetPlayers() do
		DataModule.release(player)
	end
end)

EnemyModule.init()
TrainingModule.init()
CombatModule.init()
ShopModule.init()
DataModule.startAutoSave()
