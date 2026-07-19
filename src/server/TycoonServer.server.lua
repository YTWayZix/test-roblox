-- Serveur principal — YouTuber Tycoon (mécanique dropper/convoyeur/collecteur)
local Players            = game:GetService("Players")
local RunService         = game:GetService("RunService")
local DataStoreService   = game:GetService("DataStoreService")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")

local Config       = require(ReplicatedStorage:WaitForChild("Config"))
local RemoteEvents = require(ReplicatedStorage:WaitForChild("RemoteEvents"))

-- DataStore avec fallback Studio
local PlayerDataStore
local ok, ds = pcall(function()
	return DataStoreService:GetDataStore("YouTuberTycoon_v2")
end)
if ok then PlayerDataStore = ds end

-- Données runtime par joueur
local playerData = {}
-- Référence aux modèles de plot par userId
local plotModels = {}

-- ============================================================
-- DataStore
-- ============================================================
local function defaultData()
	return {
		money       = 0,
		subscribers = 0,
		rebirths    = 0,
		multiplier  = 1,
		buildings   = {},
		milestones  = {},
		plotIndex   = nil,
	}
end

local function loadData(player)
	if not PlayerDataStore then return defaultData() end
	local s, d = pcall(function() return PlayerDataStore:GetAsync(tostring(player.UserId)) end)
	if s and d then
		local def = defaultData()
		for k, v in pairs(def) do
			if d[k] == nil then d[k] = v end
		end
		return d
	end
	return defaultData()
end

local function saveData(player)
	local data = playerData[player.UserId]
	if not data or not PlayerDataStore then return end
	-- plotPos n'est pas sérialisable, on le retire
	local toSave = {}
	for k, v in pairs(data) do
		if k ~= "plotPos" then toSave[k] = v end
	end
	pcall(function() PlayerDataStore:SetAsync(tostring(player.UserId), toSave) end)
end

-- ============================================================
-- Plots
-- ============================================================
local usedPlots = {}

local function assignPlot(player)
	for i, pos in ipairs(Config.PLOT_POSITIONS) do
		if not usedPlots[i] then
			usedPlots[i] = player.UserId
			return i, pos
		end
	end
	return nil, nil
end

local function freePlot(userId)
	for i, uid in pairs(usedPlots) do
		if uid == userId then usedPlots[i] = nil return end
	end
end

-- ============================================================
-- Construction du plot
-- ============================================================
local function makeLabel(parent, text, size, pos, color, font)
	local bb = Instance.new("BillboardGui")
	bb.Size = size or UDim2.new(0, 120, 0, 30)
	bb.StudsOffset = pos or Vector3.new(0, 2, 0)
	bb.AlwaysOnTop = false
	bb.Parent = parent
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, 0, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = text
	lbl.TextColor3 = color or Color3.new(1, 1, 1)
	lbl.TextStrokeTransparency = 0
	lbl.Font = font or Enum.Font.GothamBold
	lbl.TextScaled = true
	lbl.Parent = bb
	return lbl
end

local function buildPlot(player, data)
	local plotPos = data.plotPos
	local model   = Instance.new("Model")
	model.Name    = "Plot_" .. player.UserId
	model.Parent  = workspace

	-- Sol du plot
	local base = Instance.new("Part")
	base.Name     = "Base"
	base.Size     = Config.PLOT_SIZE
	base.CFrame   = CFrame.new(plotPos + Vector3.new(0, -0.5, 0))
	base.Anchored = true
	base.Material = Enum.Material.SmoothPlastic
	base.Color    = Color3.fromRGB(40, 40, 55)
	base.Parent   = model

	-- Panneau nom du joueur
	local namePart = Instance.new("Part")
	namePart.Size     = Vector3.new(14, 4, 0.5)
	namePart.CFrame   = CFrame.new(plotPos + Vector3.new(0, 2, -Config.PLOT_SIZE.Z / 2 + 1))
	namePart.Anchored = true
	namePart.Material = Enum.Material.SmoothPlastic
	namePart.Color    = Color3.fromRGB(20, 20, 30)
	namePart.Parent   = model

	local sg = Instance.new("SurfaceGui")
	sg.Face = Enum.NormalId.Front
	sg.PixelsPerStud = 40
	sg.Parent = namePart
	local nl = Instance.new("TextLabel")
	nl.Size = UDim2.new(1, 0, 1, 0)
	nl.BackgroundTransparency = 1
	nl.Text = "🎬 " .. player.Name
	nl.TextColor3 = Color3.fromRGB(255, 60, 60)
	nl.Font = Enum.Font.GothamBold
	nl.TextScaled = true
	nl.Parent = sg

	-- Convoyeur (plan incliné vers le collecteur)
	local conveyorLength = math.abs(Config.CONVEYOR_END_Z - Config.CONVEYOR_START_Z)
	local conveyor = Instance.new("Part")
	conveyor.Name     = "Conveyor"
	conveyor.Size     = Vector3.new(8, 0.4, conveyorLength)
	conveyor.CFrame   = CFrame.new(plotPos + Vector3.new(0, 0.2,
		(Config.CONVEYOR_START_Z + Config.CONVEYOR_END_Z) / 2))
	conveyor.Anchored = true
	conveyor.Material = Enum.Material.SmoothPlastic
	conveyor.Color    = Color3.fromRGB(60, 60, 70)
	conveyor.Parent   = model

	-- Flèches décoratives sur le convoyeur
	for i = 1, 3 do
		local arrow = Instance.new("Part")
		arrow.Size     = Vector3.new(4, 0.05, 2)
		arrow.CFrame   = CFrame.new(plotPos + Vector3.new(0, 0.43,
			Config.CONVEYOR_START_Z + i * (conveyorLength / 4)))
		arrow.Anchored = true
		arrow.Material = Enum.Material.Neon
		arrow.Color    = Color3.fromRGB(255, 60, 60)
		arrow.CanCollide = false
		arrow.Parent   = model
	end

	-- Collecteur
	local collector = Instance.new("Part")
	collector.Name     = "Collector"
	collector.Size     = Vector3.new(10, 2, 4)
	collector.CFrame   = CFrame.new(plotPos + Vector3.new(0, 1, Config.CONVEYOR_END_Z + 2))
	collector.Anchored = true
	collector.Material = Enum.Material.Neon
	collector.Color    = Color3.fromRGB(255, 215, 0)
	collector.CanCollide = true
	collector.Parent   = model
	makeLabel(collector, "💰 Collecteur", UDim2.new(0, 160, 0, 35), Vector3.new(0, 2, 0))

	-- Détection de collection
	collector.Touched:Connect(function(hit)
		if hit.Name == "Video" and hit:GetAttribute("OwnerId") == player.UserId then
			local val = hit:GetAttribute("Value") or 1
			hit:Destroy()
			local d = playerData[player.UserId]
			if d then
				d.money = d.money + (val * d.multiplier)
				RemoteEvents.UpdateStats:FireClient(player, {
					money = d.money, subscribers = d.subscribers,
					rebirths = d.rebirths, multiplier = d.multiplier,
					buildings = d.buildings,
				})
			end
		end
	end)

	-- Convoyeur : déplace les "vidéos" avec AssemblyLinearVelocity
	RunService.Heartbeat:Connect(function()
		for _, obj in ipairs(model:GetChildren()) do
			if obj.Name == "Video" and obj:GetAttribute("OwnerId") == player.UserId then
				obj.AssemblyLinearVelocity = Vector3.new(0, 0, Config.CONVEYOR_SPEED)
			end
		end
	end)

	plotModels[player.UserId] = model
	return model
end

-- ============================================================
-- Boutons d'achat (walk-in touch)
-- ============================================================
local function createBuyButton(cfg, index, player, data, plotModel)
	local plotPos = data.plotPos
	local col     = (index - 1) % 3
	local row     = math.floor((index - 1) / 3)

	local btn = Instance.new("Part")
	btn.Name      = "BuyBtn_" .. cfg.id
	btn.Size      = Vector3.new(7, 0.4, 5)
	btn.CFrame    = CFrame.new(plotPos + Vector3.new(
		-10 + col * 11,
		0.2,
		Config.BUTTON_AREA_Z - row * 7
	))
	btn.Anchored  = true
	btn.Material  = Enum.Material.Neon
	btn.Color     = Color3.fromRGB(255, 60, 60)
	btn.CanCollide = true
	btn.Parent    = plotModel

	-- Label prix
	local lbl = makeLabel(btn,
		cfg.name .. "\n💰 " .. tostring(cfg.price),
		UDim2.new(0, 180, 0, 50),
		Vector3.new(0, 2.5, 0)
	)
	lbl.TextColor3 = Color3.fromRGB(255, 215, 0)

	-- Touch pour acheter
	local debounce = false
	btn.Touched:Connect(function(hit)
		if debounce then return end
		local char = hit.Parent
		local p    = Players:GetPlayerFromCharacter(char)
		if p ~= player then return end
		debounce = true
		task.delay(0.5, function() debounce = false end)

		local d = playerData[player.UserId]
		if not d then return end
		if d.buildings[cfg.id] then return end
		if index > 1 and not d.buildings[Config.BUILDINGS[index - 1].id] then return end
		if d.money < cfg.price then return end

		d.money = d.money - cfg.price
		d.buildings[cfg.id] = true
		d.subscribers = d.subscribers + cfg.subscriberBonus

		btn:Destroy()
		spawnDropper(cfg, index, player, d, plotModel)

		RemoteEvents.UpdateStats:FireClient(player, {
			money = d.money, subscribers = d.subscribers,
			rebirths = d.rebirths, multiplier = d.multiplier,
			buildings = d.buildings,
		})
		RemoteEvents.BuildingPurchased:FireClient(player, cfg)

		-- Milestones
		for _, ms in ipairs(Config.MILESTONES) do
			if d.subscribers >= ms.subscribers and not d.milestones[ms.subscribers] then
				d.milestones[ms.subscribers] = true
				d.money = d.money + ms.reward
				RemoteEvents.MilestoneReached:FireClient(player, ms)
				RemoteEvents.UpdateStats:FireClient(player, {
					money = d.money, subscribers = d.subscribers,
					rebirths = d.rebirths, multiplier = d.multiplier,
					buildings = d.buildings,
				})
			end
		end
	end)

	return btn
end

-- ============================================================
-- Dropper : spawn des "vidéos" à intervalle régulier
-- ============================================================
function spawnDropper(cfg, index, player, data, plotModel)
	local plotPos = data.plotPos
	local col     = (index - 1) % 3
	local row     = math.floor((index - 1) / 3)

	-- Structure du dropper
	local platform = Instance.new("Part")
	platform.Name     = cfg.id
	platform.Size     = Vector3.new(6, 1, 5)
	platform.CFrame   = CFrame.new(plotPos + Vector3.new(
		-10 + col * 11,
		Config.DROPPER_BASE_Y,
		Config.CONVEYOR_START_Z - 5 - row * 6
	))
	platform.Anchored = true
	platform.Material = Enum.Material.SmoothPlastic
	platform.Color    = cfg.color
	platform.Parent   = plotModel

	makeLabel(platform, cfg.name, UDim2.new(0, 150, 0, 30), Vector3.new(0, 2, 0), cfg.color)

	-- Boucle de drop
	task.spawn(function()
		while platform.Parent ~= nil do
			task.wait(cfg.dropInterval)
			if platform.Parent == nil then break end
			local d = playerData[player.UserId]
			if not d then break end

			local video = Instance.new("Part")
			video.Name    = "Video"
			video.Size    = Vector3.new(1.5, 0.8, 2)
			video.Color   = cfg.color
			video.Material = Enum.Material.SmoothPlastic
			video.CFrame  = platform.CFrame * CFrame.new(0, -1.5, 0)
			video:SetAttribute("OwnerId", player.UserId)
			video:SetAttribute("Value", cfg.dropValue)
			video.Parent  = plotModel

			-- Nettoyage automatique si non collecté
			task.delay(Config.DROP_LIFETIME, function()
				if video.Parent then video:Destroy() end
			end)
		end
	end)
end

-- ============================================================
-- Bouton Rebirth (walk-in)
-- ============================================================
local function createRebirthButton(player, data, plotModel)
	local plotPos = data.plotPos

	local btn = Instance.new("Part")
	btn.Name      = "RebirthBtn"
	btn.Size      = Vector3.new(8, 0.4, 5)
	btn.CFrame    = CFrame.new(plotPos + Vector3.new(15, 0.2, Config.BUTTON_AREA_Z))
	btn.Anchored  = true
	btn.Material  = Enum.Material.Neon
	btn.Color     = Color3.fromRGB(150, 0, 255)
	btn.Parent    = plotModel

	local lbl = makeLabel(btn, "🔄 REBIRTH\n💰 1 000 000", UDim2.new(0, 200, 0, 50), Vector3.new(0, 2.5, 0))
	lbl.TextColor3 = Color3.fromRGB(220, 180, 255)

	local debounce = false
	btn.Touched:Connect(function(hit)
		if debounce then return end
		local p = Players:GetPlayerFromCharacter(hit.Parent)
		if p ~= player then return end
		debounce = true
		task.delay(1, function() debounce = false end)

		local d = playerData[player.UserId]
		if not d then return end

		local rebirthCfg = Config.REBIRTHS[d.rebirths + 1]
		if not rebirthCfg then return end
		if d.money < rebirthCfg.cost then return end

		-- Reset
		d.money       = 0
		d.buildings   = {}
		d.subscribers = 0
		d.milestones  = {}
		d.rebirths    = d.rebirths + 1
		d.multiplier  = rebirthCfg.multiplier

		-- Détruire et reconstruire le plot
		if plotModels[player.UserId] then
			plotModels[player.UserId]:Destroy()
		end
		buildAndSetupPlot(player, d)

		RemoteEvents.UpdateStats:FireClient(player, {
			money = d.money, subscribers = d.subscribers,
			rebirths = d.rebirths, multiplier = d.multiplier,
			buildings = d.buildings,
		})
		RemoteEvents.RebirthDone:FireClient(player, rebirthCfg)
	end)
end

-- ============================================================
-- Setup complet d'un plot
-- ============================================================
function buildAndSetupPlot(player, data)
	local plotModel = buildPlot(player, data)

	-- Boutons d'achat pour les bâtiments non possédés
	-- Droppers pour les bâtiments déjà possédés
	for i, cfg in ipairs(Config.BUILDINGS) do
		if data.buildings[cfg.id] then
			spawnDropper(cfg, i, player, data, plotModel)
		else
			createBuyButton(cfg, i, player, data, plotModel)
		end
	end

	createRebirthButton(player, data, plotModel)
end

-- ============================================================
-- Leaderboard (OrderedDataStore)
-- ============================================================
local LeaderboardStore
local s2, ds2 = pcall(function()
	return DataStoreService:GetOrderedDataStore("Leaderboard_Subscribers")
end)
if s2 then LeaderboardStore = ds2 end

local function updateLeaderboard(player, subscribers)
	if not LeaderboardStore then return end
	pcall(function()
		LeaderboardStore:SetAsync(tostring(player.UserId), subscribers)
	end)
end

-- Leaderstats Roblox (affichés dans le tableau de classement natif)
local function setupLeaderstats(player)
	local ls = Instance.new("Folder")
	ls.Name = "leaderstats"
	ls.Parent = player

	local abonnes = Instance.new("IntValue")
	abonnes.Name = "Abonnés"
	abonnes.Value = 0
	abonnes.Parent = ls

	local revenus = Instance.new("IntValue")
	revenus.Name = "Revenus"
	revenus.Value = 0
	revenus.Parent = ls

	local rb = Instance.new("IntValue")
	rb.Name = "Rebirths"
	rb.Value = 0
	rb.Parent = ls

	return ls
end

-- ============================================================
-- Player lifecycle
-- ============================================================
local function onPlayerAdded(player)
	local data = loadData(player)
	playerData[player.UserId] = data

	local ls = setupLeaderstats(player)

	local function onCharacter()
		local plotIndex, plotPos = assignPlot(player)
		if not plotIndex then warn("No plot for " .. player.Name) return end
		data.plotIndex = plotIndex
		data.plotPos   = plotPos

		-- Nettoyer un éventuel ancien plot
		if plotModels[player.UserId] then
			plotModels[player.UserId]:Destroy()
		end

		buildAndSetupPlot(player, data)

		RemoteEvents.UpdateStats:FireClient(player, {
			money = data.money, subscribers = data.subscribers,
			rebirths = data.rebirths, multiplier = data.multiplier,
			buildings = data.buildings,
		})
	end

	player.CharacterAdded:Connect(onCharacter)
	if player.Character then onCharacter() end

	-- Sync leaderstats toutes les 5 secondes
	task.spawn(function()
		while player.Parent do
			local d = playerData[player.UserId]
			if d then
				if ls:FindFirstChild("Abonnés") then ls.Abonnés.Value = d.subscribers end
				if ls:FindFirstChild("Revenus") then ls.Revenus.Value  = d.money end
				if ls:FindFirstChild("Rebirths") then ls.Rebirths.Value = d.rebirths end
				updateLeaderboard(player, d.subscribers)
			end
			task.wait(5)
		end
	end)
end

local function onPlayerRemoving(player)
	saveData(player)
	freePlot(player.UserId)
	if plotModels[player.UserId] then
		plotModels[player.UserId]:Destroy()
		plotModels[player.UserId] = nil
	end
	playerData[player.UserId] = nil
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)
for _, p in ipairs(Players:GetPlayers()) do onPlayerAdded(p) end

-- ============================================================
-- GetPlayerData
-- ============================================================
RemoteEvents.GetPlayerData.OnServerInvoke = function(player)
	local d = playerData[player.UserId]
	if not d then return {} end
	return { money = d.money, subscribers = d.subscribers,
		rebirths = d.rebirths, multiplier = d.multiplier, buildings = d.buildings }
end

-- ============================================================
-- Save automatique toutes les 60s
-- ============================================================
task.spawn(function()
	while true do
		task.wait(60)
		for _, p in ipairs(Players:GetPlayers()) do saveData(p) end
	end
end)
