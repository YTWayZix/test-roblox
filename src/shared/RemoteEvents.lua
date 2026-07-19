-- Déclaration centralisée des RemoteEvents et RemoteFunctions
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteEvents = {}

local function getOrCreate(className, name)
	local existing = ReplicatedStorage:FindFirstChild(name)
	if existing then return existing end
	local obj = Instance.new(className)
	obj.Name = name
	obj.Parent = ReplicatedStorage
	return obj
end

-- Serveur → Client : mise à jour de l'argent/abonnés
RemoteEvents.UpdateStats       = getOrCreate("RemoteEvent", "UpdateStats")

-- Client → Serveur : acheter un bâtiment
RemoteEvents.PurchaseBuilding  = getOrCreate("RemoteEvent", "PurchaseBuilding")

-- Serveur → Client : un bâtiment a été construit
RemoteEvents.BuildingPurchased = getOrCreate("RemoteEvent", "BuildingPurchased")

-- Serveur → Client : milestone atteint
RemoteEvents.MilestoneReached  = getOrCreate("RemoteEvent", "MilestoneReached")

-- Client → Serveur (RF) : demander les données initiales
RemoteEvents.GetPlayerData     = getOrCreate("RemoteFunction", "GetPlayerData")

return RemoteEvents
