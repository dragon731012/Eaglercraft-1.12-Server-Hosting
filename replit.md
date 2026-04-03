# Eaglercraft Minecraft Server

## Overview

A browser-playable Minecraft 1.12.2 server using Eaglercraft. Players connect via a web browser — no Minecraft client needed. Built on a two-layer architecture:

1. **BungeeCord proxy** (Waterfall fork) + EaglercraftXBungee plugin — handles WebSocket connections from the browser and serves the web client on port 5000.
2. **Paper 1.12.2 game server** — runs the actual Minecraft backend on port 25565.

## Architecture

```
Browser → WebSocket → EaglercraftXBungee (port 5000) → BungeeCord → Paper Server (port 25565)
```

## Project Structure

```
run.sh                    # Main startup script
bungee/                   # BungeeCord proxy
  bungee.jar              # BungeeCord/Waterfall executable
  config.yml              # Proxy configuration
  plugins/
    EaglerXBungee-1.3.6.jar          # Eaglercraft bridge plugin
    EaglercraftXBungee/
      listeners.yml       # Web listener config (port 5000)
      settings.yml        # Plugin settings
  web/                    # Static web client files (index.html, game.html, etc.)
server/                   # Paper Minecraft server
  server.jar              # Paper 1.12.2 executable
  server.properties       # Server config (port 25565)
  plugins/                # Bukkit plugins (LuckPerms, Essentials, OneBlock, etc.)
  world/                  # World save data
```

## Key Configuration

- **Web/WebSocket port**: 5000 (configured in `bungee/plugins/EaglercraftXBungee/listeners.yml`)
- **Game server port**: 25565 (configured in `server/server.properties`)
- **BungeeCord TCP port**: 25577 (configured in `bungee/config.yml`)
- **Online mode**: disabled (allows Eaglercraft clients)
- **EULA**: accepted

## Startup

The `run.sh` script:
1. Updates the Eaglercraft listener to port 5000
2. Starts the Paper backend server in the background
3. Waits 15 seconds for the backend to initialize
4. Starts BungeeCord from the `bungee/` directory

## Runtime

- **Java**: GraalVM CE 22.3.1 (OpenJDK 19)
- **Workflow**: "Start application" → `bash run.sh` → port 5000 (webview)
- **Deployment**: VM (always-running)

## Plugins

### BungeeCord plugins
- EaglercraftXBungee 1.3.6 — WebSocket bridge

### Server plugins
- LuckPerms — permissions
- EssentialsX — core commands
- Vault — economy API
- WorldEdit — terrain editing
- HolographicDisplays — floating text
- OneBlock — skyblock game mode
- EconomyShopGUI — in-game shop
- TAB — player tab list
- ClearLag — entity cleanup
- VoidGen — void world generator
- Multiverse-Core — multi-world (note: fails to enable on GraalVM due to ScriptEngine, non-critical)

## Known Issues

- **Multiverse-Core** fails to enable on GraalVM (missing Nashorn ScriptEngine). This is non-critical — worlds still load correctly.
