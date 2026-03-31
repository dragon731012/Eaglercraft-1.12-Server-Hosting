echo "WebSocket server listening at: ws://${RAILWAY_PUBLIC_DOMAIN}:8081"

cd bungee
java -jar bungee.jar &
cd ..
cd server
java -jar server.jar
