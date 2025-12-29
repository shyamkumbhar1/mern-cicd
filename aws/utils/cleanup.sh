#!/bin/bash

# Docker Cleanup Script - Removes unused images, containers, volumes
# Saves disk space and reduces costs

# Load AWS configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config.sh"

PUBLIC_IP="$AWS_PUBLIC_IP"
KEY_FILE="$AWS_KEY_FILE"

echo "🧹 Docker Cleanup Script"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📍 Instance IP: $PUBLIC_IP"
echo ""

check_key_file

# Ask for confirmation
read -p "⚠️  This will remove unused Docker resources. Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "❌ Cleanup cancelled"
  exit 1
fi

ssh -i $KEY_FILE ubuntu@$PUBLIC_IP << 'ENDSSH'
  echo ""
  echo "📊 Current Disk Usage:"
  df -h / | tail -1
  
  echo ""
  echo "📦 Docker Disk Usage:"
  docker system df
  
  echo ""
  echo "🧹 Cleaning up unused resources..."
  
  # Remove stopped containers
  echo "   Removing stopped containers..."
  docker container prune -f
  
  # Remove unused images
  echo "   Removing unused images..."
  docker image prune -a -f
  
  # Remove unused volumes
  echo "   Removing unused volumes..."
  docker volume prune -f
  
  # Remove unused networks
  echo "   Removing unused networks..."
  docker network prune -f
  
  # Full system cleanup (optional - more aggressive)
  echo ""
  read -p "   Perform full system cleanup? (removes all unused data) (y/N): " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "   Performing full cleanup..."
    docker system prune -a --volumes -f
  fi
  
  echo ""
  echo "📊 Disk Usage After Cleanup:"
  df -h / | tail -1
  
  echo ""
  echo "📦 Docker Disk Usage After Cleanup:"
  docker system df
  
  echo ""
  echo "✅ Cleanup complete!"
ENDSSH

echo ""
echo "✅ Cleanup completed successfully!"
echo "💰 Disk space freed up"

