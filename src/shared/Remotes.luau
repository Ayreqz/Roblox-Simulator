-- Cria (no servidor) e busca (no cliente) os RemoteEvents do jogo.
-- Uso: Remotes.get("Train"):FireServer()

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local REMOTE_NAMES = { "Train", "Attack", "BuyItem", "Notify" }

local Remotes = {}

local folder
if RunService:IsServer() then
	folder = Instance.new("Folder")
	folder.Name = "Remotes"
	for _, name in REMOTE_NAMES do
		local remote = Instance.new("RemoteEvent")
		remote.Name = name
		remote.Parent = folder
	end
	folder.Parent = ReplicatedStorage
else
	folder = ReplicatedStorage:WaitForChild("Remotes")
end

function Remotes.get(name)
	return folder:WaitForChild(name)
end

return Remotes
