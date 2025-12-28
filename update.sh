#!/bin/bash

# Quick Update Script (for small code changes)
# Fast: Only sync + restart, no rebuild

PUBLIC_IP="51.21.127.4"
KEY_FILE="/home/india/shared/solominds/MERN/server-practic.pem"
PROJECT_PATH="/home/india/shared/solominds/MERN"

echo "🔄 Quick Update (Fast Mode - No Rebuild)..."
echo "📍 Instance IP: $PUBLIC_IP"

# Check key file
if [ ! -f "$KEY_FILE" ]; then
  echo "❌ Key file not found: $KEY_FILE"
  exit 1
fi

chmod 400 $KEY_FILE

# Sync only changed files (fast - rsync)
echo "📦 Syncing changed files..."
if ! rsync -avz --exclude='server-practic.pem' --exclude='node_modules' --exclude='.git' \
  -e "ssh -i $KEY_FILE" \
  $PROJECT_PATH/ ubuntu@$PUBLIC_IP:~/MERN/ 2>&1; then
  echo "❌ Failed to sync files"
  exit 1
fi

# Quick restart (no rebuild)
echo "🔄 Restarting containers (no rebuild)..."
ssh -i $KEY_FILE ubuntu@$PUBLIC_IP << 'ENDSSH'
  cd ~/MERN
  
  # Restart containers (fast - no rebuild)
  docker-compose -f docker/docker-compose.prod.yml restart
  
  # Quick status
  sleep 3
  docker-compose -f docker/docker-compose.prod.yml ps
  
  echo "✅ Quick update complete!"
ENDSSH

echo ""
echo "✅ Update Complete! (~10-15 seconds)"
echo "🌐 Frontend: http://$PUBLIC_IP"
echo "🔌 Backend: http://$PUBLIC_IP:3000"
echo ""

