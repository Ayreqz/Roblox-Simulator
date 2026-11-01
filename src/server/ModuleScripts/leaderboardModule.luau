-- Stats (NumberValue, fonte da verdade, aguentam números enormes) ficam em player.Stats.
-- A lista de jogadores (leaderstats) mostra o mesmo valor já formatado (1.5K, 2.3M...).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NumberFormatter = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("NumberFormatter"))

local STAT_NAMES = { "Gold", "Strength" }

local leaderboardModule = {}

function leaderboardModule.setupLeaderboard(player, data)
	local stats = Instance.new("Folder")
	stats.Name = "Stats"

	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"

	for _, name in STAT_NAMES do
		local value = Instance.new("NumberValue")
		value.Name = name
		value.Value = data[name]
		value.Parent = stats

		local display = Instance.new("StringValue")
		display.Name = name
		display.Value = NumberFormatter.format(value.Value)
		display.Parent = leaderstats

		value.Changed:Connect(function(newValue)
			display.Value = NumberFormatter.format(newValue)
		end)
	end

	stats.Parent = player
	leaderstats.Parent = player

	return stats
end

return leaderboardModule
