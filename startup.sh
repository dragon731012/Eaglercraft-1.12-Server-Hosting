#!/bin/sh

# Rewrite Eaglercraft listener to use Render's assigned port
sed -i "s/address: .*/address: 0.0.0.0:${PORT}/" bungee/plugins/EaglercraftXBungee/listeners.yml

# Start BungeeCord
java -Xms512M -Xmx512M -jar bungee/bungee.jar
