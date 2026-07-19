local Config = {}

Config.TICK_INTERVAL   = 0.5   -- secondes entre chaque drop
Config.CONVEYOR_SPEED  = 20    -- studs/s sur le convoyeur
Config.DROP_LIFETIME   = 12    -- secondes avant qu'un drop disparaisse

-- Bâtiments / droppers (déverrouillage séquentiel)
-- dropValue  = argent donné par chaque "vidéo" collectée
-- dropInterval = secondes entre chaque drop
Config.BUILDINGS = {
	{
		id           = "camera_basique",
		name         = "Caméra Basique",
		desc         = "Ta première vidéo. Modeste mais suffisant.",
		price        = 0,
		dropValue    = 1,
		dropInterval = 4,
		color        = Color3.fromRGB(80, 160, 255),
		subscriberBonus = 0,
	},
	{
		id           = "bureau_montage",
		name         = "Bureau de Montage",
		desc         = "Monte tes vidéos plus vite.",
		price        = 150,
		dropValue    = 4,
		dropInterval = 3.5,
		color        = Color3.fromRGB(255, 200, 80),
		subscriberBonus = 10,
	},
	{
		id           = "ring_light",
		name         = "Ring Light Pro",
		desc         = "Belle lumière = plus de vues.",
		price        = 600,
		dropValue    = 10,
		dropInterval = 3,
		color        = Color3.fromRGB(255, 255, 180),
		subscriberBonus = 50,
	},
	{
		id           = "micro_pro",
		name         = "Microphone Pro",
		desc         = "Son cristallin. Les viewers adorent.",
		price        = 1500,
		dropValue    = 28,
		dropInterval = 2.5,
		color        = Color3.fromRGB(200, 200, 200),
		subscriberBonus = 150,
	},
	{
		id           = "studio_chroma",
		name         = "Studio Chroma Key",
		desc         = "Fond vert pro. Tournages épiques.",
		price        = 4000,
		dropValue    = 75,
		dropInterval = 2,
		color        = Color3.fromRGB(0, 200, 80),
		subscriberBonus = 500,
	},
	{
		id           = "camera_4k",
		name         = "Caméra 4K Cinéma",
		desc         = "Qualité cinématographique. Viral assuré.",
		price        = 12000,
		dropValue    = 200,
		dropInterval = 1.8,
		color        = Color3.fromRGB(60, 60, 220),
		subscriberBonus = 2000,
	},
	{
		id           = "pc_montage",
		name         = "PC Montage Ultra",
		desc         = "Rendu 8K en 30 secondes.",
		price        = 35000,
		dropValue    = 550,
		dropInterval = 1.5,
		color        = Color3.fromRGB(180, 60, 255),
		subscriberBonus = 10000,
	},
	{
		id           = "studio_complet",
		name         = "Studio Professionnel",
		desc         = "Un vrai plateau TV. Tu es une star.",
		price        = 120000,
		dropValue    = 1500,
		dropInterval = 1.2,
		color        = Color3.fromRGB(255, 120, 0),
		subscriberBonus = 50000,
	},
	{
		id           = "agence_media",
		name         = "Agence Média",
		desc         = "Plusieurs chaînes. Un empire.",
		price        = 500000,
		dropValue    = 5000,
		dropInterval = 1,
		color        = Color3.fromRGB(255, 215, 0),
		subscriberBonus = 250000,
	},
}

-- Milestones d'abonnés
Config.MILESTONES = {
	{ subscribers = 100,     badge = "Créateur Débutant",  reward = 500 },
	{ subscribers = 1000,    badge = "Bouton Argent",       reward = 3000 },
	{ subscribers = 10000,   badge = "Bouton Or",           reward = 15000 },
	{ subscribers = 100000,  badge = "Bouton Diamant",      reward = 100000 },
	{ subscribers = 1000000, badge = "Bouton Rubis",        reward = 750000 },
}

-- Rebirth : multiplicateur de revenu permanent
Config.REBIRTHS = {
	{ cost = 1000000,  multiplier = 2,  label = "Rebirth x2"  },
	{ cost = 5000000,  multiplier = 4,  label = "Rebirth x4"  },
	{ cost = 25000000, multiplier = 8,  label = "Rebirth x8"  },
	{ cost = 100000000,multiplier = 20, label = "Rebirth x20" },
}

-- Disposition des plots dans le monde
Config.PLOT_POSITIONS = {
	Vector3.new(0,    0, 0),
	Vector3.new(120,  0, 0),
	Vector3.new(240,  0, 0),
	Vector3.new(0,    0, 120),
	Vector3.new(120,  0, 120),
	Vector3.new(240,  0, 120),
}

-- Layout d'un plot (relatif au coin du plot)
Config.PLOT_SIZE        = Vector3.new(80, 1, 100)
Config.CONVEYOR_START_Z = -30   -- Z relatif où le convoyeur commence
Config.CONVEYOR_END_Z   = 30    -- Z relatif où le collecteur est
Config.DROPPER_BASE_Y   = 10    -- hauteur des droppers
Config.BUTTON_AREA_Z    = 40    -- Z relatif de la zone des boutons d'achat

return Config
