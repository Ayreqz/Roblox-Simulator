-- Treino: o cliente só PEDE para treinar; o servidor calcula e dá a recompensa.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Remotes = require(Shared:WaitForChild("Remotes"))

local TrainingModule = {}

local lastTrain = {} -- [player] = os.clock() do último treino

function TrainingModule.init()
	Remotes.get("Train").OnServerEvent:Connect(function(player)
		local now = os.clock()
		local last = lastTrain[player]
		if last and now - last < Config.Training.Cooldown then
			return -- rápido demais, ignora
		end
		lastTrain[player] = now

		local stats = player:FindFirstChild("Stats")
		if not stats then
			return
		end

		local settings = Config.Training
		local goldGain = math.floor(settings.BaseGold + stats.Strength.Value * settings.GoldPerStrength)

		stats.Strength.Value += settings.StrengthPerClick
		stats.Gold.Value += goldGain
	end)

	Players.PlayerRemoving:Connect(function(player)
		lastTrain[player] = nil
	end)
end

return TrainingModule
