local leaderboardModule = {}

local function setupLeaderboard(player)
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    return leaderstats
end

return leaderbordModule