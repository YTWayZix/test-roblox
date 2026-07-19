-- HUD client — YouTuber Tycoon
local Players       = game:GetService("Players")
local TweenService  = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config       = require(ReplicatedStorage:WaitForChild("Config"))
local RemoteEvents = require(ReplicatedStorage:WaitForChild("RemoteEvents"))

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name            = "TycoonHud"
screenGui.ResetOnSpawn    = false
screenGui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
screenGui.IgnoreGuiInset  = true
screenGui.Parent          = playerGui

-- ============================================================
-- Helpers
-- ============================================================
local function fmt(n)
	n = math.floor(n)
	if n >= 1e9 then return string.format("%.1fB", n/1e9)
	elseif n >= 1e6 then return string.format("%.1fM", n/1e6)
	elseif n >= 1e3 then return string.format("%.1fK", n/1e3)
	end
	return tostring(n)
end

local function uiCorner(r, parent)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r)
	c.Parent = parent
end

local function textLabel(props, parent)
	local l = Instance.new("TextLabel")
	for k, v in pairs(props) do l[k] = v end
	l.BackgroundTransparency = 1
	l.Parent = parent
	return l
end

-- ============================================================
-- Barre du haut
-- ============================================================
local topBar = Instance.new("Frame")
topBar.Size              = UDim2.new(0, 520, 0, 58)
topBar.Position          = UDim2.new(0.5, -260, 0, 8)
topBar.BackgroundColor3  = Color3.fromRGB(12, 12, 18)
topBar.BackgroundTransparency = 0.1
topBar.BorderSizePixel   = 0
topBar.Parent            = screenGui
uiCorner(14, topBar)

local sections = {
	{ key = "money",       icon = "💰", color = Color3.fromRGB(255, 215, 0)   },
	{ key = "subscribers", icon = "👥", color = Color3.fromRGB(100, 200, 255) },
	{ key = "multiplier",  icon = "⚡", color = Color3.fromRGB(200, 100, 255) },
	{ key = "rebirths",    icon = "🔄", color = Color3.fromRGB(150, 255, 150) },
}

local statLabels = {}
local w = 1 / #sections
for i, sec in ipairs(sections) do
	local f = Instance.new("Frame")
	f.Size = UDim2.new(w, -2, 1, 0)
	f.Position = UDim2.new((i-1)*w, 1, 0, 0)
	f.BackgroundTransparency = 1
	f.Parent = topBar

	textLabel({ Size=UDim2.new(0,28,1,0), Text=sec.icon, Font=Enum.Font.Gotham, TextScaled=true }, f)
	statLabels[sec.key] = textLabel({
		Size=UDim2.new(1,-32,1,0), Position=UDim2.new(0,30,0,0),
		Text="0", Font=Enum.Font.GothamBold, TextScaled=true,
		TextColor3=sec.color, TextXAlignment=Enum.TextXAlignment.Left,
	}, f)
end

-- ============================================================
-- Panneau latéral bâtiments
-- ============================================================
local panel = Instance.new("Frame")
panel.Size             = UDim2.new(0, 250, 0.72, 0)
panel.Position         = UDim2.new(1, -262, 0.14, 0)
panel.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
panel.BackgroundTransparency = 0.08
panel.BorderSizePixel  = 0
panel.Parent           = screenGui
uiCorner(14, panel)

textLabel({
	Size=UDim2.new(1,0,0,38), Text="🎬 Ton Studio",
	Font=Enum.Font.GothamBold, TextScaled=true,
	TextColor3=Color3.fromRGB(255,60,60),
}, panel)

local scroll = Instance.new("ScrollingFrame")
scroll.Size                = UDim2.new(1,-8,1,-44)
scroll.Position            = UDim2.new(0,4,0,42)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness  = 3
scroll.ScrollBarImageColor3 = Color3.fromRGB(255,60,60)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.CanvasSize          = UDim2.new(0,0,0,0)
scroll.Parent              = panel

local ll = Instance.new("UIListLayout")
ll.Padding = UDim.new(0,5)
ll.Parent  = scroll
local lp = Instance.new("UIPadding")
lp.PaddingLeft=UDim.new(0,4); lp.PaddingRight=UDim.new(0,4); lp.PaddingTop=UDim.new(0,4)
lp.Parent = scroll

local buildingCards = {}
for i, cfg in ipairs(Config.BUILDINGS) do
	local card = Instance.new("Frame")
	card.Name            = cfg.id
	card.Size            = UDim2.new(1,0,0,68)
	card.BackgroundColor3 = Color3.fromRGB(22,22,32)
	card.BorderSizePixel = 0
	card.Parent          = scroll
	uiCorner(8, card)

	local bar = Instance.new("Frame")
	bar.Size=UDim2.new(0,4,1,0); bar.BackgroundColor3=cfg.color; bar.BorderSizePixel=0; bar.Parent=card
	uiCorner(4, bar)

	textLabel({Size=UDim2.new(1,-50,0,22),Position=UDim2.new(0,10,0,5),
		Text=cfg.name,Font=Enum.Font.GothamBold,TextScaled=true,
		TextColor3=Color3.new(1,1,1),TextXAlignment=Enum.TextXAlignment.Left}, card)
	textLabel({Size=UDim2.new(1,-50,0,18),Position=UDim2.new(0,10,0,28),
		Text="💰+"..fmt(cfg.dropValue).."/drop  👥+"..fmt(cfg.subscriberBonus),
		Font=Enum.Font.Gotham,TextScaled=true,
		TextColor3=Color3.fromRGB(170,170,170),TextXAlignment=Enum.TextXAlignment.Left}, card)
	textLabel({Size=UDim2.new(1,-50,0,16),Position=UDim2.new(0,10,0,48),
		Text=cfg.price==0 and "🆓 Gratuit" or "Prix: 💰 "..fmt(cfg.price),
		Font=Enum.Font.GothamBold,TextScaled=true,
		TextColor3=Color3.fromRGB(255,215,0),TextXAlignment=Enum.TextXAlignment.Left}, card)

	local icon = textLabel({Size=UDim2.new(0,32,0,32),Position=UDim2.new(1,-40,0.5,-16),
		Text="🔒",TextScaled=true,Font=Enum.Font.Gotham}, card)
	buildingCards[cfg.id] = { card=card, icon=icon }
end

-- ============================================================
-- Panneau Rebirth (bas gauche)
-- ============================================================
local rebirthPanel = Instance.new("Frame")
rebirthPanel.Size             = UDim2.new(0,230,0,78)
rebirthPanel.Position         = UDim2.new(0,12,1,-90)
rebirthPanel.BackgroundColor3 = Color3.fromRGB(50,0,80)
rebirthPanel.BackgroundTransparency = 0.15
rebirthPanel.BorderSizePixel  = 0
rebirthPanel.Parent           = screenGui
uiCorner(12, rebirthPanel)

textLabel({Size=UDim2.new(1,0,0,30),Text="🔄 Prochain Rebirth",
	Font=Enum.Font.GothamBold,TextScaled=true,TextColor3=Color3.fromRGB(200,150,255)}, rebirthPanel)
local rebirthInfo = textLabel({Size=UDim2.new(1,0,0,30),Position=UDim2.new(0,0,0,34),
	Text="...",Font=Enum.Font.Gotham,TextScaled=true,TextColor3=Color3.fromRGB(220,200,255)}, rebirthPanel)

-- ============================================================
-- Notifications
-- ============================================================
local notifQueue   = {}
local notifRunning = false

local function showNotif(title, body, color)
	table.insert(notifQueue, {title=title, body=body, color=color})
	if notifRunning then return end
	notifRunning = true
	task.spawn(function()
		while #notifQueue > 0 do
			local n = table.remove(notifQueue, 1)
			local f = Instance.new("Frame")
			f.Size=UDim2.new(0,300,0,74); f.Position=UDim2.new(0.5,-150,1,20)
			f.BackgroundColor3=n.color or Color3.fromRGB(30,30,45)
			f.BorderSizePixel=0; f.Parent=screenGui
			uiCorner(12, f)
			textLabel({Size=UDim2.new(1,-12,0.5,0),Position=UDim2.new(0,8,0,4),
				Text=n.title,Font=Enum.Font.GothamBold,TextScaled=true,
				TextColor3=Color3.new(1,1,1),TextXAlignment=Enum.TextXAlignment.Left}, f)
			textLabel({Size=UDim2.new(1,-12,0.5,0),Position=UDim2.new(0,8,0.5,0),
				Text=n.body,Font=Enum.Font.Gotham,TextScaled=true,
				TextColor3=Color3.fromRGB(210,210,210),TextXAlignment=Enum.TextXAlignment.Left}, f)
			TweenService:Create(f, TweenInfo.new(0.35,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
				{Position=UDim2.new(0.5,-150,1,-86)}):Play()
			task.wait(3.2)
			TweenService:Create(f, TweenInfo.new(0.25), {Position=UDim2.new(0.5,-150,1,20)}):Play()
			task.wait(0.3); f:Destroy(); task.wait(0.15)
		end
		notifRunning = false
	end)
end

-- ============================================================
-- Update HUD
-- ============================================================
local function updateHud(stats)
	if statLabels.money       then statLabels.money.Text       = fmt(stats.money or 0) end
	if statLabels.subscribers then statLabels.subscribers.Text = fmt(stats.subscribers or 0) end
	if statLabels.multiplier  then statLabels.multiplier.Text  = "x"..(stats.multiplier or 1) end
	if statLabels.rebirths    then statLabels.rebirths.Text    = tostring(stats.rebirths or 0) end

	local nextRb = Config.REBIRTHS[(stats.rebirths or 0)+1]
	rebirthInfo.Text = nextRb and (nextRb.label.." · 💰 "..fmt(nextRb.cost)) or "Maximum 🏆"

	for i, cfg in ipairs(Config.BUILDINGS) do
		local cd = buildingCards[cfg.id]
		if cd then
			local owned    = stats.buildings and stats.buildings[cfg.id]
			local unlocked = i==1 or (stats.buildings and stats.buildings[Config.BUILDINGS[i-1].id])
			local afford   = (stats.money or 0) >= cfg.price
			if owned then
				cd.icon.Text = "✅"
				cd.card.BackgroundColor3 = Color3.fromRGB(18,38,22)
			elseif unlocked then
				cd.icon.Text = afford and "🛒" or "💸"
				cd.card.BackgroundColor3 = Color3.fromRGB(22,22,32)
			else
				cd.icon.Text = "🔒"
				cd.card.BackgroundColor3 = Color3.fromRGB(16,16,26)
			end
		end
	end
end

RemoteEvents.UpdateStats.OnClientEvent:Connect(updateHud)

RemoteEvents.BuildingPurchased.OnClientEvent:Connect(function(cfg)
	showNotif("🎉 "..cfg.name, "💰+"..fmt(cfg.dropValue).."/drop  👥+"..fmt(cfg.subscriberBonus),
		Color3.fromRGB(25,100,40))
end)

RemoteEvents.MilestoneReached.OnClientEvent:Connect(function(ms)
	showNotif("🏆 "..ms.badge, fmt(ms.subscribers).." abonnés ! Bonus 💰"..fmt(ms.reward),
		Color3.fromRGB(140,90,0))
end)

RemoteEvents.RebirthDone.OnClientEvent:Connect(function(rb)
	showNotif("🔄 REBIRTH !", rb.label.." · x"..rb.multiplier, Color3.fromRGB(80,0,130))
end)

local init = RemoteEvents.GetPlayerData:InvokeServer()
if init then updateHud(init) end
