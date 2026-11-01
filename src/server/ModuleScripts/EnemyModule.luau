-- Inimigos de treino: criados por código a partir do Config, com vida e respawn.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local NumberFormatter = require(Shared:WaitForChild("NumberFormatter"))

local EnemyModule = {}

-- states[model] = { model, def, name, health, alive, label }
local states = {}
local folder

local function refreshLabel(state)
	state.label.Text = `{state.name}  {NumberFormatter.format(state.health)}/{NumberFormatter.format(state.def.MaxHealth)}`
end

local function createEnemy(spawnInfo)
	local def = Config.Enemies[spawnInfo.Enemy]
	if not def then
		warn(`[EnemyModule] Inimigo desconhecido: {spawnInfo.Enemy}`)
		return
	end

	local model = Instance.new("Model")
	model.Name = spawnInfo.Enemy

	local body = Instance.new("Part")
	body.Name = "Body"
	body.Size = def.Size
	body.Color = def.Color
	body.Material = Enum.Material.SmoothPlastic
	body.Anchored = true
	body.Position = spawnInfo.Position + Vector3.new(0, def.Size.Y / 2, 0)
	body.Parent = model
	model.PrimaryPart = body

	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.fromOffset(200, 30)
	billboard.StudsOffset = Vector3.new(0, def.Size.Y / 2 + 1.5, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = body

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.TextSize = 16
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0
	label.Parent = billboard

	local state = {
		model = model,
		def = def,
		name = spawnInfo.Enemy,
		health = def.MaxHealth,
		alive = true,
		label = label,
	}
	states[model] = state
	refreshLabel(state)

	model.Parent = folder
end

function EnemyModule.init()
	folder = Instance.new("Folder")
	folder.Name = "Enemies"
	folder.Parent = Workspace

	for _, spawnInfo in Config.EnemySpawns do
		createEnemy(spawnInfo)
	end
end

-- Retorna o inimigo vivo mais próximo dentro do alcance (ou nil).
function EnemyModule.getNearest(position, range)
	local nearest, nearestDistance = nil, range
	for model, state in states do
		if state.alive then
			local distance = (model.PrimaryPart.Position - position).Magnitude
			if distance <= nearestDistance then
				nearest, nearestDistance = model, distance
			end
		end
	end
	return nearest
end

-- Aplica dano. Retorna (morreu, definição do inimigo).
function EnemyModule.damage(model, amount)
	local state = states[model]
	if not state or not state.alive then
		return false, nil
	end

	state.health = math.max(0, state.health - amount)

	if state.health <= 0 then
		state.alive = false
		model.Parent = nil -- some do mundo

		task.delay(state.def.Respawn, function()
			state.health = state.def.MaxHealth
			state.alive = true
			refreshLabel(state)
			model.Parent = folder
		end)

		return true, state.def
	end

	refreshLabel(state)
	return false, state.def
end

return EnemyModule
