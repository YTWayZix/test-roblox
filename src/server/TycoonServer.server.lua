-- Script serveur principal du tycoon Youtubeur
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local DataStoreService = game:GetService("DataStoreService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("Config"))
local RemoteEvents = require(ReplicatedStorage:WaitForChild("RemoteEvents"))

-- DataStore désactivé en Studio non publié, on utilise un mock
local PlayerDataStore = nil
local ok, ds = pcall(function()
	return DataStoreService:GetDataStore("YouTuberTycoon_v1")
end)
if ok then PlayerDataStore = ds end

-- Données en mémoire par joueur
local playerData = {}

-- Plots (terrains) disponibles dans le monde
local PLOT_POSITIONS = {
	Vector3.new(0,   0, 0),
	Vector3.new(80,  0, 0),
	Vector3.new(0,   0, 80),
	Vector3.new(80,  0, 80),
	Vector3.new(-80, 0, 0),
	Vector3.new(0,   0, -80),
}
local usedPlots = {}

-- ============================================================
-- DataStore helpers
-- ============================================================
local function defaultData()
	return {
		money       = 0,
		subscribers = 0,
		buildings   = {},   -- set of building ids
		plotIndex   = nil,
		milestones  = {},   -- set of milestone subscriber thresholds
	}
end

local function loadData(player)
	if not PlayerDataStore then return defaultData() end
	local success, data = pcall(function()
		return PlayerDataStore:GetAsync(tostring(player.UserId))
	end)
	if success and data then
		-- merge missing keys
		local def = defaultData()
		for k, v in pairs(def) do
			if data[k] == nil then data[k] = v end
		end
		return data
	end
	return defaultData()
end

local function saveData(player)
	local data = playerData[player.UserId]
	if not data or not PlayerDataStore then return end
	pcall(function()
		PlayerDataStore:SetAsync(tostring(player.UserId), data)
	end)
end

-- ============================================================
-- Plot management
-- ============================================================
local function assignPlot(player)
	for i, pos in ipairs(PLOT_POSITIONS) do
		if not usedPlots[i] then
			usedPlots[i] = player.UserId
			return i, pos
		end
	end
	return nil, nil
end

local function freePlot(userId)
	for i, uid in pairs(usedPlots) do
		if uid == userId then
			usedPlots[i] = nil
			return
		end
	end
end

-- ============================================================
-- World building
-- ============================================================
local function buildBase(plotPos)
	local base = Instance.new("Part")
	base.Size = Vector3.new(60, 1, 60)
	base.Position = plotPos + Vector3.new(0, -0.5, 0)
	base.Anchored = true
	base.Material = Enum.Material.SmoothPlastic
	base.Color = Color3.fromRGB(50, 50, 60)
	base.Name = "PlotBase"
	base.Parent = workspace
	return base
end

local function spawnBuildingModel(buildingCfg, plotPos, index)
	local model = Instance.new("Model")
	model.Name = buildingCfg.id

	local part = Instance.new("Part")
	part.Size = buildingCfg.size
	local col = index - 1
	local row = math.floor(col / 3)
	col = col % 3
	part.Position = plotPos + Vector3.new(-20 + col * 22, buildingCfg.size.Y / 2, -20 + row * 22)
	part.Anchored = true
	part.Material = Enum.Material.SmoothPlastic
	part.Color = buildingCfg.color
	part.Name = "Main"
	part.Parent = model

	-- Label
	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(0, 160, 0, 40)
	billboard.StudsOffset = Vector3.new(0, buildingCfg.size.Y / 2 + 1, 0)
	billboard.AlwaysOnTop = false
	billboard.Parent = part

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = buildingCfg.name
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.Parent = billboard

	model.Parent = workspace
	return model
end

local function buildPurchaseButton(buildingCfg, plotPos, index, player)
	local col = index - 1
	local row = math.floor(col / 3)
	col = col % 3

	local btnPart = Instance.new("Part")
	btnPart.Size = Vector3.new(4, 0.5, 4)
	btnPart.Position = plotPos + Vector3.new(-20 + col * 22, 0.25, -20 + row * 22)
	btnPart.Anchored = true
	btnPart.Material = Enum.Material.Neon
	btnPart.Color = Color3.fromRGB(255, 60, 60)
	btnPart.Name = "BuyButton_" .. buildingCfg.id
	btnPart.Parent = workspace

	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(0, 200, 0, 60)
	billboard.StudsOffset = Vector3.new(0, 2, 0)
	billboard.AlwaysOnTop = false
	billboard.Parent = btnPart

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	frame.BackgroundTransparency = 0.3
	frame.Parent = billboard

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = buildingCfg.name
	nameLabel.TextColor3 = Color3.new(1, 1, 1)
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextScaled = true
	nameLabel.Parent = frame

	local priceLabel = Instance.new("TextLabel")
	priceLabel.Size = UDim2.new(1, 0, 0.5, 0)
	priceLabel.Position = UDim2.new(0, 0, 0.5, 0)
	priceLabel.BackgroundTransparency = 1
	priceLabel.Text = "💰 " .. tostring(buildingCfg.price)
	priceLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
	priceLabel.Font = Enum.Font.Gotham
	priceLabel.TextScaled = true
	priceLabel.Parent = frame

	-- Détection du click via ProximityPrompt
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Acheter"
	prompt.ObjectText = buildingCfg.name .. " · 💰" .. tostring(buildingCfg.price)
	prompt.MaxActivationDistance = 10
	prompt.Parent = btnPart

	prompt.Triggered:Connect(function(triggeringPlayer)
		if triggeringPlayer == player then
			RemoteEvents.PurchaseBuilding:FireServer(buildingCfg.id)
		end
	end)

	return btnPart
end

-- ============================================================
-- Player lifecycle
-- ============================================================
local function setupPlot(player, data)
	local plotIndex, plotPos = assignPlot(player)
	if not plotIndex then
		warn("No available plot for " .. player.Name)
		return
	end
	data.plotIndex = plotIndex
	data.plotPos   = plotPos  -- runtime only, not saved

	buildBase(plotPos)

	-- Reconstruire les bâtiments déjà achetés
	for i, cfg in ipairs(Config.BUILDINGS) do
		if data.buildings[cfg.id] then
			spawnBuildingModel(cfg, plotPos, i)
		else
			buildPurchaseButton(cfg, plotPos, i, player)
		end
	end
end

local function onPlayerAdded(player)
	local data = loadData(player)
	playerData[player.UserId] = data

	player.CharacterAdded:Connect(function()
		setupPlot(player, data)
	end)

	if player.Character then
		setupPlot(player, data)
	end

	RemoteEvents.UpdateStats:FireClient(player, {
		money       = data.money,
		subscribers = data.subscribers,
		buildings   = data.buildings,
	})
end

local function onPlayerRemoving(player)
	saveData(player)
	freePlot(player.UserId)
	playerData[player.UserId] = nil
end

-- ============================================================
-- Purchase logic
-- ============================================================
RemoteEvents.PurchaseBuilding.OnServerEvent:Connect(function(player, buildingId)
	local data = playerData[player.UserId]
	if not data then return end

	-- Trouver la config
	local cfg, index
	for i, c in ipairs(Config.BUILDINGS) do
		if c.id == buildingId then
			cfg = c
			index = i
			break
		end
	end
	if not cfg then return end
	if data.buildings[buildingId] then return end -- déjà acheté

	-- Vérifier le prérequis (bâtiment précédent acheté sauf le 1er)
	if index > 1 then
		local prevCfg = Config.BUILDINGS[index - 1]
		if not data.buildings[prevCfg.id] then
			return
		end
	end

	if data.money < cfg.price then return end

	data.money = data.money - cfg.price
	data.buildings[buildingId] = true
	data.subscribers = data.subscribers + cfg.subscriberBonus

	-- Remplacer le bouton par le modèle 3D
	local plotPos = data.plotPos
	if plotPos then
		-- Supprimer le bouton
		for _, obj in ipairs(workspace:GetChildren()) do
			if obj.Name == "BuyButton_" .. buildingId then
				obj:Destroy()
			end
		end
		spawnBuildingModel(cfg, plotPos, index)
	end

	RemoteEvents.UpdateStats:FireClient(player, {
		money       = data.money,
		subscribers = data.subscribers,
		buildings   = data.buildings,
	})

	RemoteEvents.BuildingPurchased:FireClient(player, cfg)

	-- Vérifier les milestones
	for _, milestone in ipairs(Config.MILESTONES) do
		if data.subscribers >= milestone.subscribers and not data.milestones[milestone.subscribers] then
			data.milestones[milestone.subscribers] = true
			data.money = data.money + milestone.reward
			RemoteEvents.MilestoneReached:FireClient(player, milestone)
			RemoteEvents.UpdateStats:FireClient(player, {
				money       = data.money,
				subscribers = data.subscribers,
				buildings   = data.buildings,
			})
		end
	end
end)

-- ============================================================
-- GetPlayerData RemoteFunction
-- ============================================================
RemoteEvents.GetPlayerData.OnServerInvoke = function(player)
	local data = playerData[player.UserId]
	if not data then return {} end
	return {
		money       = data.money,
		subscribers = data.subscribers,
		buildings   = data.buildings,
	}
end

-- ============================================================
-- Tick passif : génère des revenus automatiquement
-- ============================================================
local tickTimer = 0
RunService.Heartbeat:Connect(function(dt)
	tickTimer = tickTimer + dt
	if tickTimer < Config.TICK_INTERVAL then return end
	tickTimer = 0

	for _, player in ipairs(Players:GetPlayers()) do
		local data = playerData[player.UserId]
		if data then
			local income = 0
			for _, cfg in ipairs(Config.BUILDINGS) do
				if data.buildings[cfg.id] then
					income = income + cfg.incomePerTick
				end
			end
			if income > 0 then
				data.money = data.money + income
				RemoteEvents.UpdateStats:FireClient(player, {
					money       = data.money,
					subscribers = data.subscribers,
					buildings   = data.buildings,
				})
			end
		end
	end
end)

-- ============================================================
-- Save périodique (toutes les 60 secondes)
-- ============================================================
local saveTimer = 0
RunService.Heartbeat:Connect(function(dt)
	saveTimer = saveTimer + dt
	if saveTimer < 60 then return end
	saveTimer = 0
	for _, player in ipairs(Players:GetPlayers()) do
		saveData(player)
	end
end)

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

for _, player in ipairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end
