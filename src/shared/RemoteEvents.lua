local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function getOrCreate(className, name)
	local existing = ReplicatedStorage:FindFirstChild(name)
	if existing then return existing end
	local obj = Instance.new(className)
	obj.Name = name
	obj.Parent = ReplicatedStorage
	return obj
end

local RE = {}
RE.UpdateStats        = getOrCreate("RemoteEvent",    "UpdateStats")
RE.BuildingPurchased  = getOrCreate("RemoteEvent",    "BuildingPurchased")
RE.MilestoneReached   = getOrCreate("RemoteEvent",    "MilestoneReached")
RE.RebirthDone        = getOrCreate("RemoteEvent",    "RebirthDone")
RE.GetPlayerData      = getOrCreate("RemoteFunction", "GetPlayerData")
return RE
