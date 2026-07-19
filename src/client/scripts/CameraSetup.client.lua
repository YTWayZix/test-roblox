-- Script client : caméra légèrement plus haute pour mieux voir le tycoon
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

camera.FieldOfView = 70

-- Rien de plus : on laisse la caméra par défaut de Roblox.
-- Cette frame sert juste d'entrée pour de futures personnalisations.
