#!/bin/sh

# Set port to 5000 for Replit
sed -i "s/address: 0.0.0.0:[0-9]*/address: 0.0.0.0:5000/" bungee/plugins/EaglercraftXBungee/listeners.yml

# Start log cleanup in the background
nohup bash "$(dirname "$0")/cleanup.sh" > /dev/null 2>&1 &

# Ensure we run from the script's root folder
cd "$(dirname "$0")"

# Start the Minecraft backend server in the background from the server directory
cd server
java -Dterminal.jline=false -Dterminal.ansi=true -Xms4M -Xmx2G -jar server.jar nogui &
cd ..

# Start BungeeCord proxy from its own directory (serves web client on port 5000)
cd bungee
java -Xms512M -Xmx512M -jar bungee.jar
