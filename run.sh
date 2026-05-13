#!/bin/sh

# Set port to 5000 for Replit
sed -i "s/address: 0.0.0.0:[0-9]*/address: 0.0.0.0:5000/" bungee/plugins/EaglercraftXBungee/listeners.yml

# Start log cleanup in the background
nohup bash "$(dirname "$0")/cleanup.sh" > /dev/null 2>&1 &

# Patch VoidGen generator strings in worlds.yml before Paper reads it
cd server
perl patch_worlds.pl

# Start the Minecraft backend server in the background
java -Xms512M -Xmx1G -jar server.jar nogui &
cd ..

# Wait for backend server to start
echo "Waiting for Minecraft backend server to start..."
sleep 15
echo "Starting BungeeCord proxy..."

# Start BungeeCord proxy from its own directory (serves web client on port 5000)
cd bungee
java -Xms512M -Xmx512M -jar bungee.jar
