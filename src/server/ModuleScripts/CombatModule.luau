-- Combate: o cliente só pede "atacar"; o servidor acha o alvo, valida e calcula o dano.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Remotes = require(Shared:WaitForChild("Remotes"))
local NumberFormatter = require(Shared:WaitForChild("NumberFormatter"))
local EnemyModule = require(script.Parent.EnemyModule)

local CombatModule = {}

local lastAttack = {} -- [player] = os.clock() do último ataque

local function notify(player, message)
	Remotes.get("Notify"):FireClient(player, message)
end

function CombatModule.init()
	Remotes.get("Attack").OnServerEvent:Connect(function(player)
		local now = os.clock()
		local last = lastAttack[player]
		if last and now - last < Config.Combat.Cooldown then
			return
		end
		lastAttack[player] = now

		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local stats = player:FindFirstChild("Stats")
		if not root or not humanoid or humanoid.Health <= 0 or not stats then
			return
		end

		local enemy = EnemyModule.getNearest(root.Position, Config.Combat.Range)
		if not enemy then
			notify(player, "Nenhum inimigo por perto.")
			return
		end

		local damage = Config.Combat.BaseDamage + stats.Strength.Value * Config.Combat.DamagePerStrength
		local killed, def = EnemyModule.damage(enemy, damage)

		if killed and def then
			stats.Gold.Value += def.Gold
			notify(player, `Derrotou {enemy.Name}! +{NumberFormatter.format(def.Gold)} Gold`)
		end
	end)

	Players.PlayerRemoving:Connect(function(player)
		lastAttack[player] = nil
	end)
end

return CombatModule
