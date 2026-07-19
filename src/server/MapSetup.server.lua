-- Génère la map de base : sol, ciel, lumières, décor
local Lighting = game:GetService("Lighting")

-- ============================================================
-- Lighting / Ambiance
-- ============================================================
Lighting.Ambient        = Color3.fromRGB(80, 80, 100)
Lighting.OutdoorAmbient = Color3.fromRGB(120, 120, 150)
Lighting.Brightness     = 2
Lighting.ClockTime      = 14
Lighting.FogEnd         = 1000

-- Atmosphère douce
local atmosphere = Instance.new("Atmosphere")
atmosphere.Density    = 0.3
atmosphere.Offset     = 0.1
atmosphere.Color      = Color3.fromRGB(180, 200, 255)
atmosphere.Decay      = Color3.fromRGB(100, 120, 180)
atmosphere.Glare      = 0.2
atmosphere.Haze       = 1
atmosphere.Parent     = Lighting

-- Ciel
local sky = Instance.new("Sky")
sky.SkyboxBk = "rbxasset://textures/sky/sky512_bk.tex"
sky.SkyboxDn = "rbxasset://textures/sky/sky512_dn.tex"
sky.SkyboxFt = "rbxasset://textures/sky/sky512_ft.tex"
sky.SkyboxLf = "rbxasset://textures/sky/sky512_lf.tex"
sky.SkyboxRt = "rbxasset://textures/sky/sky512_rt.tex"
sky.SkyboxUp = "rbxasset://textures/sky/sky512_up.tex"
sky.Parent = Lighting

-- ============================================================
-- Sol principal (Baseplate)
-- ============================================================
local baseplate = Instance.new("Part")
baseplate.Name      = "Baseplate"
baseplate.Size      = Vector3.new(1024, 1, 1024)
baseplate.Position  = Vector3.new(0, -1, 0)
baseplate.Anchored  = true
baseplate.Material  = Enum.Material.SmoothPlastic
baseplate.Color     = Color3.fromRGB(35, 35, 45)
baseplate.Parent    = workspace

-- ============================================================
-- Route centrale entre les plots
-- ============================================================
local road = Instance.new("Part")
road.Name     = "Road"
road.Size     = Vector3.new(8, 0.2, 300)
road.Position = Vector3.new(40, 0.1, 40)
road.Anchored = true
road.Material = Enum.Material.SmoothPlastic
road.Color    = Color3.fromRGB(50, 50, 55)
road.Parent   = workspace

-- Lignes blanches sur la route
for i = -5, 5 do
	local line = Instance.new("Part")
	line.Size     = Vector3.new(0.5, 0.21, 4)
	line.Position = Vector3.new(40, 0.1, i * 20)
	line.Anchored = true
	line.Material = Enum.Material.SmoothPlastic
	line.Color    = Color3.fromRGB(255, 255, 255)
	line.Parent   = workspace
end

-- ============================================================
-- Lampadaires décoratifs
-- ============================================================
local function makeLamp(pos)
	local model = Instance.new("Model")
	model.Name = "Lampadaire"

	local pole = Instance.new("Part")
	pole.Size     = Vector3.new(0.4, 8, 0.4)
	pole.Position = pos + Vector3.new(0, 4, 0)
	pole.Anchored = true
	pole.Material = Enum.Material.Metal
	pole.Color    = Color3.fromRGB(80, 80, 90)
	pole.Parent   = model

	local head = Instance.new("Part")
	head.Size     = Vector3.new(1.5, 0.5, 1.5)
	head.Position = pos + Vector3.new(0, 8.2, 0)
	head.Anchored = true
	head.Material = Enum.Material.Neon
	head.Color    = Color3.fromRGB(255, 230, 180)
	head.Parent   = model

	local light = Instance.new("PointLight")
	light.Brightness = 3
	light.Range      = 20
	light.Color      = Color3.fromRGB(255, 230, 180)
	light.Parent     = head

	model.Parent = workspace
end

-- Lampadaires le long de la route
for i = -4, 4 do
	makeLamp(Vector3.new(35, 0, i * 25))
	makeLamp(Vector3.new(45, 0, i * 25))
end

-- ============================================================
-- Panneau "YouTuber Tycoon" à l'entrée
-- ============================================================
local signBase = Instance.new("Part")
signBase.Size     = Vector3.new(20, 1, 2)
signBase.Position = Vector3.new(0, 0.5, -55)
signBase.Anchored = true
signBase.Material = Enum.Material.Metal
signBase.Color    = Color3.fromRGB(40, 40, 50)
signBase.Parent   = workspace

local signBoard = Instance.new("Part")
signBoard.Size     = Vector3.new(20, 6, 0.5)
signBoard.Position = Vector3.new(0, 4, -55)
signBoard.Anchored = true
signBoard.Material = Enum.Material.SmoothPlastic
signBoard.Color    = Color3.fromRGB(20, 20, 30)
signBoard.Parent   = workspace

local signGui = Instance.new("SurfaceGui")
signGui.Face        = Enum.NormalId.Front
signGui.PixelsPerStud = 50
signGui.Parent      = signBoard

local signLabel = Instance.new("TextLabel")
signLabel.Size              = UDim2.new(1, 0, 1, 0)
signLabel.BackgroundTransparency = 1
signLabel.Text              = "🎬 YouTuber Tycoon"
signLabel.TextColor3        = Color3.fromRGB(255, 60, 60)
signLabel.Font              = Enum.Font.GothamBold
signLabel.TextScaled        = true
signLabel.TextStrokeTransparency = 0
signLabel.TextStrokeColor3  = Color3.fromRGB(0, 0, 0)
signLabel.Parent            = signGui

-- ============================================================
-- Spawn point
-- ============================================================
local spawnLocation = workspace:FindFirstChild("SpawnLocation")
if not spawnLocation then
	spawnLocation = Instance.new("SpawnLocation")
	spawnLocation.Size     = Vector3.new(6, 1, 6)
	spawnLocation.Position = Vector3.new(0, 0.5, -40)
	spawnLocation.Anchored = true
	spawnLocation.Material = Enum.Material.Neon
	spawnLocation.Color    = Color3.fromRGB(255, 60, 60)
	spawnLocation.Parent   = workspace
end
