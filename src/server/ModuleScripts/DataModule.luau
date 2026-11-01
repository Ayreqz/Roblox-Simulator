-- Salva e carrega os dados do jogador com DataStore.
-- Gold e Strength vivem em player.Stats (fonte da verdade durante o jogo);
-- o resto (Swords, Fruits) vive na tabela de sessão.

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

local store = DataStoreService:GetDataStore(Config.Data.StoreName)

local DataModule = {}

-- sessions[player] = { data = {...}, canSave = boolean }
local sessions = {}

local function deepCopy(value)
	if type(value) ~= "table" then
		return value
	end
	local copy = {}
	for key, inner in value do
		copy[key] = deepCopy(inner)
	end
	return copy
end

-- Preenche campos que faltam (útil quando você adicionar novos campos depois).
local function reconcile(data, defaults)
	for key, value in defaults do
		if data[key] == nil then
			data[key] = deepCopy(value)
		end
	end
	return data
end

local function keyFor(player)
	return "Player_" .. player.UserId
end

function DataModule.load(player)
	local ok, saved
	for attempt = 1, 3 do
		ok, saved = pcall(store.GetAsync, store, keyFor(player))
		if ok then
			break
		end
		warn(`[DataModule] Falha ao carregar {player.Name} (tentativa {attempt}): {saved}`)
		task.wait(1)
	end

	local session
	if ok then
		if type(saved) ~= "table" then
			saved = {}
		end
		session = { data = reconcile(saved, Config.Data.Defaults), canSave = true }
	else
		-- Não conseguimos ler: usa padrão, mas NÃO salva, para não sobrescrever o progresso real.
		warn(`[DataModule] {player.Name} jogará sem salvar nesta sessão.`)
		session = { data = deepCopy(Config.Data.Defaults), canSave = false }
	end

	sessions[player] = session
	return session.data
end

function DataModule.get(player)
	local session = sessions[player]
	return session and session.data
end

function DataModule.save(player)
	local session = sessions[player]
	if not session or not session.canSave then
		return false
	end

	local stats = player:FindFirstChild("Stats")
	if not stats then
		return false
	end

	local snapshot = {
		Gold = stats.Gold.Value,
		Strength = stats.Strength.Value,
		Swords = session.data.Swords,
		Fruits = session.data.Fruits,
	}

	local ok, err = pcall(store.UpdateAsync, store, keyFor(player), function()
		return snapshot
	end)
	if not ok then
		warn(`[DataModule] Falha ao salvar {player.Name}: {err}`)
	end
	return ok
end

function DataModule.release(player)
	DataModule.save(player)
	sessions[player] = nil
end

function DataModule.startAutoSave()
	task.spawn(function()
		while true do
			task.wait(Config.Data.AutoSaveSeconds)
			for _, player in Players:GetPlayers() do
				task.spawn(DataModule.save, player)
			end
		end
	end)
end

return DataModule
