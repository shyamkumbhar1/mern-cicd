#!/bin/bash

# Load AWS configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config.sh"

# Use config variables
PUBLIC_IP="$AWS_PUBLIC_IP"
KEY_FILE="$AWS_KEY_FILE"
PROJECT_PATH="$AWS_PROJECT_PATH"

echo "🔄 Quick Update (Fast Mode - No Rebuild)..."
echo "📍 Instance IP: $PUBLIC_IP"

# Check key file
check_key_file

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
      docker-compose -f docker/compose/docker-compose.prod.yml restart
      
      # Quick status
      sleep 3
      docker-compose -f docker/compose/docker-compose.prod.yml ps
  
  echo "✅ Quick update complete!"
ENDSSH

echo ""
echo "✅ Update Complete! (~10-15 seconds)"
echo "🌐 Frontend: http://$PUBLIC_IP"
echo "🔌 Backend: http://$PUBLIC_IP:3000"
echo ""

