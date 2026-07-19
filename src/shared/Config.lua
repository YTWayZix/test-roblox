-- Configuration centrale du tycoon
local Config = {}

-- Devises
Config.CURRENCY_NAME = "Abonnés"
Config.CURRENCY_ICON = "👥"
Config.MONEY_NAME = "Revenu"

-- Intervalle de gain passif (en secondes)
Config.TICK_INTERVAL = 1

-- Données des bâtiments du tycoon (dans l'ordre de déverrouillage)
Config.BUILDINGS = {
	{
		id = "camera_basique",
		name = "Caméra Basique",
		description = "Une petite caméra pour démarrer ta chaîne.",
		price = 0,
		incomePerTick = 1,
		subscriberBonus = 0,
		color = Color3.fromRGB(80, 160, 255),
		size = Vector3.new(4, 4, 4),
	},
	{
		id = "bureau_montage",
		name = "Bureau de Montage",
		description = "Monte tes vidéos plus vite. +50% de revenus.",
		price = 100,
		incomePerTick = 3,
		subscriberBonus = 10,
		color = Color3.fromRGB(255, 200, 80),
		size = Vector3.new(6, 4, 6),
	},
	{
		id = "ring_light",
		name = "Ring Light Pro",
		description = "Une belle lumière pour tes thumbnails.",
		price = 500,
		incomePerTick = 8,
		subscriberBonus = 50,
		color = Color3.fromRGB(255, 255, 200),
		size = Vector3.new(3, 6, 3),
	},
	{
		id = "micro_pro",
		name = "Microphone Pro",
		description = "Un son cristallin. Les viewers adorent.",
		price = 1200,
		incomePerTick = 20,
		subscriberBonus = 150,
		color = Color3.fromRGB(200, 200, 200),
		size = Vector3.new(2, 5, 2),
	},
	{
		id = "studio_chroma",
		name = "Studio Chroma Key",
		description = "Fond vert professionnel. Tournages épiques.",
		price = 3000,
		incomePerTick = 55,
		subscriberBonus = 500,
		color = Color3.fromRGB(0, 200, 80),
		size = Vector3.new(10, 6, 8),
	},
	{
		id = "camera_4k",
		name = "Caméra 4K Cinema",
		description = "Qualité cinématographique. Viral assuré.",
		price = 8000,
		incomePerTick = 140,
		subscriberBonus = 2000,
		color = Color3.fromRGB(60, 60, 180),
		size = Vector3.new(5, 5, 5),
	},
	{
		id = "pc_montage",
		name = "PC Montage Ultra",
		description = "Rendu 8K en 30 secondes. Le rêve.",
		price = 20000,
		incomePerTick = 400,
		subscriberBonus = 10000,
		color = Color3.fromRGB(180, 60, 255),
		size = Vector3.new(6, 5, 4),
	},
	{
		id = "studio_complet",
		name = "Studio Professionnel",
		description = "Un vrai plateau TV. Tu es une star.",
		price = 75000,
		incomePerTick = 1200,
		subscriberBonus = 50000,
		color = Color3.fromRGB(255, 120, 0),
		size = Vector3.new(16, 8, 14),
	},
	{
		id = "agence_media",
		name = "Agence Média",
		description = "Plusieurs chaînes, un empire. Légende.",
		price = 300000,
		incomePerTick = 5000,
		subscriberBonus = 250000,
		color = Color3.fromRGB(255, 215, 0),
		size = Vector3.new(20, 10, 18),
	},
}

-- Paliers d'abonnés (milestones)
Config.MILESTONES = {
	{ subscribers = 100,     badge = "Créateur Débutant",   reward = 500 },
	{ subscribers = 1000,    badge = "Bouton Argent",        reward = 2000 },
	{ subscribers = 10000,   badge = "Bouton Or",            reward = 10000 },
	{ subscribers = 100000,  badge = "Bouton Diamant",       reward = 75000 },
	{ subscribers = 1000000, badge = "Bouton Rubis",         reward = 500000 },
}

-- Couleurs UI
Config.UI = {
	PRIMARY   = Color3.fromRGB(255, 60, 60),   -- rouge YouTube
	SECONDARY = Color3.fromRGB(30, 30, 30),
	ACCENT    = Color3.fromRGB(255, 200, 0),
	TEXT      = Color3.fromRGB(255, 255, 255),
	BG        = Color3.fromRGB(15, 15, 15),
}

return Config
