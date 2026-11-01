-- Loja: valida tudo no servidor (preço, item existente, já possui?).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Remotes = require(Shared:WaitForChild("Remotes"))
local NumberFormatter = require(Shared:WaitForChild("NumberFormatter"))
local DataModule = require(script.Parent.DataModule)

local ShopModule = {}

-- categoria -> { catálogo do Config, campo onde guardamos o que o jogador possui }
local CATEGORIES = {
	Sword = { catalog = Config.Swords, ownedKey = "Swords" },
	Fruit = { catalog = Config.Fruits, ownedKey = "Fruits" },
}

local function notify(player, message)
	Remotes.get("Notify"):FireClient(player, message)
end

function ShopModule.init()
	Remotes.get("BuyItem").OnServerEvent:Connect(function(player, category, itemName)
		if type(category) ~= "string" or type(itemName) ~= "string" then
			return
		end

		local categoryInfo = CATEGORIES[category]
		local item = categoryInfo and categoryInfo.catalog[itemName]
		if not item then
			return
		end

		local data = DataModule.get(player)
		local stats = player:FindFirstChild("Stats")
		if not data or not stats then
			return
		end

		local owned = data[categoryInfo.ownedKey]
		if table.find(owned, itemName) then
			notify(player, `Você já possui {itemName}!`)
			return
		end

		if stats.Gold.Value < item.Price then
			notify(player, `Gold insuficiente para {itemName} ({NumberFormatter.format(item.Price)}).`)
			return
		end

		stats.Gold.Value -= item.Price
		table.insert(owned, itemName)
		notify(player, `Você comprou {itemName}!`)
	end)
end

return ShopModule
