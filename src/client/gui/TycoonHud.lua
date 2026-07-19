-- GUI principal : HUD du tycoon Youtubeur
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Config"))
local RemoteEvents = require(ReplicatedStorage:WaitForChild("RemoteEvents"))

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ============================================================
-- Création du ScreenGui
-- ============================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TycoonHud"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- ============================================================
-- Barre supérieure : Argent + Abonnés
-- ============================================================
local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(0, 420, 0, 60)
topBar.Position = UDim2.new(0.5, -210, 0, 12)
topBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
topBar.BackgroundTransparency = 0.2
topBar.BorderSizePixel = 0
topBar.Parent = screenGui

local corner1 = Instance.new("UICorner")
corner1.CornerRadius = UDim.new(0, 12)
corner1.Parent = topBar

-- Revenu
local moneyFrame = Instance.new("Frame")
moneyFrame.Size = UDim2.new(0.5, -4, 1, 0)
moneyFrame.BackgroundTransparency = 1
moneyFrame.Parent = topBar

local moneyIcon = Instance.new("TextLabel")
moneyIcon.Size = UDim2.new(0, 36, 1, 0)
moneyIcon.BackgroundTransparency = 1
moneyIcon.Text = "💰"
moneyIcon.TextScaled = true
moneyIcon.Font = Enum.Font.Gotham
moneyIcon.Parent = moneyFrame

local moneyLabel = Instance.new("TextLabel")
moneyLabel.Name = "MoneyLabel"
moneyLabel.Size = UDim2.new(1, -40, 1, 0)
moneyLabel.Position = UDim2.new(0, 40, 0, 0)
moneyLabel.BackgroundTransparency = 1
moneyLabel.Text = "0"
moneyLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
moneyLabel.Font = Enum.Font.GothamBold
moneyLabel.TextScaled = true
moneyLabel.TextXAlignment = Enum.TextXAlignment.Left
moneyLabel.Parent = moneyFrame

-- Abonnés
local subFrame = Instance.new("Frame")
subFrame.Size = UDim2.new(0.5, -4, 1, 0)
subFrame.Position = UDim2.new(0.5, 4, 0, 0)
subFrame.BackgroundTransparency = 1
subFrame.Parent = topBar

local subIcon = Instance.new("TextLabel")
subIcon.Size = UDim2.new(0, 36, 1, 0)
subIcon.BackgroundTransparency = 1
subIcon.Text = "👥"
subIcon.TextScaled = true
subIcon.Font = Enum.Font.Gotham
subIcon.Parent = subFrame

local subLabel = Instance.new("TextLabel")
subLabel.Name = "SubLabel"
subLabel.Size = UDim2.new(1, -40, 1, 0)
subLabel.Position = UDim2.new(0, 40, 0, 0)
subLabel.BackgroundTransparency = 1
subLabel.Text = "0"
subLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
subLabel.Font = Enum.Font.GothamBold
subLabel.TextScaled = true
subLabel.TextXAlignment = Enum.TextXAlignment.Left
subLabel.Parent = subFrame

-- ============================================================
-- Panneau latéral : liste des bâtiments
-- ============================================================
local sidePanel = Instance.new("Frame")
sidePanel.Name = "SidePanel"
sidePanel.Size = UDim2.new(0, 260, 0.7, 0)
sidePanel.Position = UDim2.new(1, -272, 0.15, 0)
sidePanel.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
sidePanel.BackgroundTransparency = 0.1
sidePanel.BorderSizePixel = 0
sidePanel.Parent = screenGui

local sidePanelCorner = Instance.new("UICorner")
sidePanelCorner.CornerRadius = UDim.new(0, 14)
sidePanelCorner.Parent = sidePanel

local panelTitle = Instance.new("TextLabel")
panelTitle.Size = UDim2.new(1, 0, 0, 40)
panelTitle.BackgroundTransparency = 1
panelTitle.Text = "🎬 Ton Studio"
panelTitle.TextColor3 = Color3.fromRGB(255, 60, 60)
panelTitle.Font = Enum.Font.GothamBold
panelTitle.TextScaled = true
panelTitle.Parent = sidePanel

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -8, 1, -48)
scrollFrame.Position = UDim2.new(0, 4, 0, 44)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 4
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 60, 60)
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollFrame.Parent = sidePanel

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 6)
listLayout.Parent = scrollFrame

local listPadding = Instance.new("UIPadding")
listPadding.PaddingLeft   = UDim.new(0, 4)
listPadding.PaddingRight  = UDim.new(0, 4)
listPadding.PaddingTop    = UDim.new(0, 4)
listPadding.Parent = scrollFrame

-- Cache des cartes de bâtiment
local buildingCards = {}

local function formatNumber(n)
	if n >= 1e6 then
		return string.format("%.1fM", n / 1e6)
	elseif n >= 1e3 then
		return string.format("%.1fK", n / 1e3)
	end
	return tostring(n)
end

local function createBuildingCard(cfg, index)
	local card = Instance.new("Frame")
	card.Name = cfg.id
	card.Size = UDim2.new(1, 0, 0, 72)
	card.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
	card.BorderSizePixel = 0
	card.Parent = scrollFrame

	local cardCorner = Instance.new("UICorner")
	cardCorner.CornerRadius = UDim.new(0, 8)
	cardCorner.Parent = card

	-- Couleur left-bar
	local colorBar = Instance.new("Frame")
	colorBar.Size = UDim2.new(0, 5, 1, 0)
	colorBar.BackgroundColor3 = cfg.color
	colorBar.BorderSizePixel = 0
	colorBar.Parent = card
	Instance.new("UICorner").CornerRadius = UDim.new(0, 4)
	-- attach corner to colorBar
	local cb2 = Instance.new("UICorner")
	cb2.CornerRadius = UDim.new(0, 4)
	cb2.Parent = colorBar

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, -60, 0, 24)
	nameLabel.Position = UDim2.new(0, 10, 0, 6)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = cfg.name
	nameLabel.TextColor3 = Color3.new(1, 1, 1)
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextScaled = true
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Parent = card

	local incomeLabel = Instance.new("TextLabel")
	incomeLabel.Size = UDim2.new(1, -10, 0, 18)
	incomeLabel.Position = UDim2.new(0, 10, 0, 32)
	incomeLabel.BackgroundTransparency = 1
	incomeLabel.Text = "💰 +" .. tostring(cfg.incomePerTick) .. "/s  👥 +" .. formatNumber(cfg.subscriberBonus)
	incomeLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
	incomeLabel.Font = Enum.Font.Gotham
	incomeLabel.TextScaled = true
	incomeLabel.TextXAlignment = Enum.TextXAlignment.Left
	incomeLabel.Parent = card

	local priceLabel = Instance.new("TextLabel")
	priceLabel.Name = "PriceLabel"
	priceLabel.Size = UDim2.new(1, -10, 0, 18)
	priceLabel.Position = UDim2.new(0, 10, 0, 50)
	priceLabel.BackgroundTransparency = 1
	priceLabel.Text = cfg.price == 0 and "🆓 Gratuit" or ("Prix : 💰 " .. formatNumber(cfg.price))
	priceLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
	priceLabel.Font = Enum.Font.GothamBold
	priceLabel.TextScaled = true
	priceLabel.TextXAlignment = Enum.TextXAlignment.Left
	priceLabel.Parent = card

	-- Icône statut (✅ ou 🔒)
	local statusIcon = Instance.new("TextLabel")
	statusIcon.Name = "StatusIcon"
	statusIcon.Size = UDim2.new(0, 36, 0, 36)
	statusIcon.Position = UDim2.new(1, -44, 0.5, -18)
	statusIcon.BackgroundTransparency = 1
	statusIcon.Text = "🔒"
	statusIcon.TextScaled = true
	statusIcon.Parent = card

	buildingCards[cfg.id] = {
		card       = card,
		statusIcon = statusIcon,
		priceLabel = priceLabel,
	}

	return card
end

for i, cfg in ipairs(Config.BUILDINGS) do
	createBuildingCard(cfg, i)
end

-- ============================================================
-- Notification de bâtiment acheté
-- ============================================================
local function showNotification(title, body, color)
	local notif = Instance.new("Frame")
	notif.Size = UDim2.new(0, 320, 0, 80)
	notif.Position = UDim2.new(0.5, -160, 1, 20)
	notif.BackgroundColor3 = color or Color3.fromRGB(40, 40, 50)
	notif.BorderSizePixel = 0
	notif.Parent = screenGui

	local nc = Instance.new("UICorner")
	nc.CornerRadius = UDim.new(0, 12)
	nc.Parent = notif

	local t = Instance.new("TextLabel")
	t.Size = UDim2.new(1, -10, 0.5, 0)
	t.Position = UDim2.new(0, 10, 0, 4)
	t.BackgroundTransparency = 1
	t.Text = title
	t.TextColor3 = Color3.new(1, 1, 1)
	t.Font = Enum.Font.GothamBold
	t.TextScaled = true
	t.TextXAlignment = Enum.TextXAlignment.Left
	t.Parent = notif

	local b = Instance.new("TextLabel")
	b.Size = UDim2.new(1, -10, 0.5, 0)
	b.Position = UDim2.new(0, 10, 0.5, 0)
	b.BackgroundTransparency = 1
	b.Text = body
	b.TextColor3 = Color3.fromRGB(220, 220, 220)
	b.Font = Enum.Font.Gotham
	b.TextScaled = true
	b.TextXAlignment = Enum.TextXAlignment.Left
	b.Parent = notif

	-- Slide in
	TweenService:Create(notif, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.new(0.5, -160, 1, -100)
	}):Play()

	task.delay(3.5, function()
		TweenService:Create(notif, TweenInfo.new(0.3), {
			Position = UDim2.new(0.5, -160, 1, 20),
			BackgroundTransparency = 1,
		}):Play()
		task.delay(0.4, function() notif:Destroy() end)
	end)
end

-- ============================================================
-- Mise à jour du HUD
-- ============================================================
local function updateHud(stats)
	moneyLabel.Text = formatNumber(stats.money or 0)
	subLabel.Text   = formatNumber(stats.subscribers or 0)

	for i, cfg in ipairs(Config.BUILDINGS) do
		local cardData = buildingCards[cfg.id]
		if cardData then
			local owned = stats.buildings and stats.buildings[cfg.id]
			if owned then
				cardData.statusIcon.Text = "✅"
				cardData.card.BackgroundColor3 = Color3.fromRGB(20, 40, 25)
			else
				-- Vérifier si le prérequis est rempli
				local canBuy = true
				if i > 1 then
					local prev = Config.BUILDINGS[i - 1]
					canBuy = stats.buildings and stats.buildings[prev.id]
				end
				if canBuy then
					local canAfford = (stats.money or 0) >= cfg.price
					cardData.statusIcon.Text = canAfford and "🛒" or "💸"
					cardData.card.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
				else
					cardData.statusIcon.Text = "🔒"
					cardData.card.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
				end
			end
		end
	end
end

-- ============================================================
-- Événements distants
-- ============================================================
RemoteEvents.UpdateStats.OnClientEvent:Connect(updateHud)

RemoteEvents.BuildingPurchased.OnClientEvent:Connect(function(cfg)
	showNotification(
		"🎉 " .. cfg.name .. " acheté !",
		"+" .. formatNumber(cfg.subscriberBonus) .. " abonnés · +" .. cfg.incomePerTick .. "/s",
		Color3.fromRGB(30, 120, 50)
	)
end)

RemoteEvents.MilestoneReached.OnClientEvent:Connect(function(milestone)
	showNotification(
		"🏆 " .. milestone.badge,
		formatNumber(milestone.subscribers) .. " abonnés ! Bonus : 💰 " .. formatNumber(milestone.reward),
		Color3.fromRGB(180, 120, 0)
	)
end)

-- Récupérer les données initiales
local initData = RemoteEvents.GetPlayerData:InvokeServer()
if initData then
	updateHud(initData)
end
