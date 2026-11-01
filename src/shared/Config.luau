-- Configuração central do jogo. Ajuste os valores aqui sem mexer na lógica.
-- Todos os números abaixo são PLACEHOLDERS para balancear depois.

local Config = {}

Config.Data = {
	StoreName = "SimulatorData_v1",
	AutoSaveSeconds = 60,
	Defaults = {
		Gold = 0,
		Strength = 1,
		Swords = {}, -- espadas compradas
		Fruits = {}, -- frutas compradas
	},
}

Config.Training = {
	Cooldown = 0.25, -- segundos mínimos entre treinos (anti-spam)
	StrengthPerClick = 1,
	BaseGold = 1,
	GoldPerStrength = 0.1, -- ouro extra por ponto de Strength
}

Config.Combat = {
	Cooldown = 0.4, -- segundos entre ataques
	Range = 14, -- distância máxima (studs) até o centro do inimigo
	BaseDamage = 5,
	DamagePerStrength = 1, -- dano = BaseDamage + Strength * DamagePerStrength
}

Config.Enemies = {
	Dummy = {
		MaxHealth = 50,
		Gold = 5,
		Respawn = 3, -- segundos para renascer
		Size = Vector3.new(3, 6, 3),
		Color = Color3.fromRGB(200, 170, 120),
	},
	Brute = {
		MaxHealth = 1000,
		Gold = 120,
		Respawn = 8,
		Size = Vector3.new(5, 9, 5),
		Color = Color3.fromRGB(170, 50, 50),
	},
}

-- Posição X/Z no chão (Y = altura do chão; o módulo soma metade da altura do inimigo).
Config.EnemySpawns = {
	{ Enemy = "Dummy", Position = Vector3.new(20, 0, -12) },
	{ Enemy = "Dummy", Position = Vector3.new(20, 0, 0) },
	{ Enemy = "Dummy", Position = Vector3.new(20, 0, 12) },
	{ Enemy = "Brute", Position = Vector3.new(45, 0, 0) },
}

Config.Islands = {
	StartIsland = { MinStrength = 0 },
	SnowIsland = { MinStrength = 100 },
}

Config.Swords = {
	Katana = { Price = 100, Damage = 10 },
	Cutlass = { Price = 500, Damage = 25 },
	Yoru = { Price = 5000, Damage = 80 },
}

Config.Fruits = {
	Light = { Price = 2000 },
	Fire = { Price = 2500 },
	Wake = { Price = 6000 },
}

return Config
