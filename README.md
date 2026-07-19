# 🎬 YouTuber Tycoon — Roblox

Un tycoon sur le thème du youtubeur : construis ton studio, gagne des abonnés et deviens une légende d'internet.

## Structure du projet

```
src/
  server/
    TycoonServer.server.lua   — Logique serveur (revenus, achats, DataStore)
  shared/
    Config.lua                — Tous les bâtiments, milestones, paramètres
    RemoteEvents.lua          — Déclaration des RemoteEvents/Functions
  client/
    gui/
      TycoonHud.lua           — HUD (argent, abonnés, liste des bâtiments)
    scripts/
      CameraSetup.client.lua  — Réglages caméra
default.project.json          — Config Rojo
```

## Bâtiments (9 niveaux)

| Nom | Prix | Revenu/s | Abonnés |
|-----|------|----------|---------|
| Caméra Basique | Gratuit | 1 | 0 |
| Bureau de Montage | 100 | 3 | +10 |
| Ring Light Pro | 500 | 8 | +50 |
| Microphone Pro | 1 200 | 20 | +150 |
| Studio Chroma Key | 3 000 | 55 | +500 |
| Caméra 4K Cinema | 8 000 | 140 | +2 000 |
| PC Montage Ultra | 20 000 | 400 | +10 000 |
| Studio Professionnel | 75 000 | 1 200 | +50 000 |
| Agence Média | 300 000 | 5 000 | +250 000 |

## Milestones

| Abonnés | Badge | Bonus |
|---------|-------|-------|
| 100 | Créateur Débutant | 💰 500 |
| 1 000 | Bouton Argent | 💰 2 000 |
| 10 000 | Bouton Or | 💰 10 000 |
| 100 000 | Bouton Diamant | 💰 75 000 |
| 1 000 000 | Bouton Rubis | 💰 500 000 |

## Utilisation avec Rojo

```bash
rojo serve default.project.json
```

Puis connecte le plugin Rojo dans Roblox Studio.

## Fonctionnalités

- Revenus passifs automatiques (1 tick/seconde)
- Sauvegarde DataStore automatique (toutes les 60s + déconnexion)
- Jusqu'à 6 joueurs sur des plots séparés
- Système de milestones avec récompenses
- HUD avec panneau latéral scrollable
- Notifications animées (achat, milestone)
- ProximityPrompts pour acheter les bâtiments en s'approchant
