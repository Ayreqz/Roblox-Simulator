-- Interface simples criada por código (treino, ataque, compra de espadas e avisos).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Remotes = require(Shared:WaitForChild("Remotes"))
local NumberFormatter = require(Shared:WaitForChild("NumberFormatter"))

local UI = {}

local function makeButton(parent, text, layoutOrder, color)
	local button = Instance.new("TextButton")
	button.Size = UDim2.fromOffset(200, 40)
	button.LayoutOrder = layoutOrder
	button.Text = text
	button.Font = Enum.Font.GothamBold
	button.TextSize = 16
	button.TextColor3 = Color3.new(1, 1, 1)
	button.BackgroundColor3 = color or Color3.fromRGB(40, 40, 40)
	button.Parent = parent

	local corner = Instance.new("UICorner")
	corner.Parent = button

	return button
end

function UI.init()
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

	local trainRemote = Remotes.get("Train")
	local attackRemote = Remotes.get("Attack")
	local buyRemote = Remotes.get("BuyItem")
	local notifyRemote = Remotes.get("Notify")

	local gui = Instance.new("ScreenGui")
	gui.Name = "Hud"
	gui.ResetOnSpawn = false
	gui.Parent = playerGui

	-- Menu lateral
	local menu = Instance.new("Frame")
	menu.AnchorPoint = Vector2.new(0, 0.5)
	menu.Position = UDim2.new(0, 16, 0.5, 0)
	menu.Size = UDim2.fromOffset(200, 0)
	menu.AutomaticSize = Enum.AutomaticSize.Y
	menu.BackgroundTransparency = 1
	menu.Parent = gui

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = menu

	local trainButton = makeButton(menu, "Treinar", 0, Color3.fromRGB(200, 60, 60))
	trainButton.Activated:Connect(function()
		trainRemote:FireServer()
	end)

	local attackButton = makeButton(menu, "Atacar (F)", 1, Color3.fromRGB(60, 100, 200))
	attackButton.Activated:Connect(function()
		attackRemote:FireServer()
	end)

	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then
			return
		end
		if input.KeyCode == Enum.KeyCode.F then
			attackRemote:FireServer()
		end
	end)

	-- Um botão de compra por espada (ordenado por preço)
	local swordNames = {}
	for name in Config.Swords do
		table.insert(swordNames, name)
	end
	table.sort(swordNames, function(a, b)
		return Config.Swords[a].Price < Config.Swords[b].Price
	end)

	for index, name in swordNames do
		local price = NumberFormatter.format(Config.Swords[name].Price)
		local button = makeButton(menu, `Comprar {name} ({price})`, index + 1)
		button.Activated:Connect(function()
			buyRemote:FireServer("Sword", name)
		end)
	end

	-- Aviso temporário
	local notice = Instance.new("TextLabel")
	notice.AnchorPoint = Vector2.new(0.5, 0)
	notice.Position = UDim2.new(0.5, 0, 0, 20)
	notice.Size = UDim2.fromOffset(360, 36)
	notice.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	notice.BackgroundTransparency = 0.2
	notice.TextColor3 = Color3.new(1, 1, 1)
	notice.Font = Enum.Font.GothamMedium
	notice.TextSize = 16
	notice.Visible = false
	notice.Parent = gui

	local noticeCorner = Instance.new("UICorner")
	noticeCorner.Parent = notice

	local noticeId = 0
	notifyRemote.OnClientEvent:Connect(function(message)
		noticeId += 1
		local myId = noticeId
		notice.Text = message
		notice.Visible = true
		task.delay(2.5, function()
			if noticeId == myId then
				notice.Visible = false
			end
		end)
	end)
end

return UI
