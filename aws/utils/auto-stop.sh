#!/bin/bash

# Auto-stop script for cron jobs
# Stops dev and pre-prod environments at specified times
# Usage: Add to crontab for automatic cost saving

# Load AWS configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config.sh"

PUBLIC_IP="$AWS_PUBLIC_IP"
KEY_FILE="$AWS_KEY_FILE"

echo "🛑 Auto-stopping Dev and Pre-prod environments..."
echo "📍 Instance IP: $PUBLIC_IP"
echo "⏰ Time: $(date)"

check_key_file

ssh -i $KEY_FILE ubuntu@$PUBLIC_IP << 'ENDSSH'
  # Stop Dev
  if [ -d "~/MERN-dev" ]; then
    cd ~/MERN-dev
    docker-compose -f docker/compose/docker-compose.dev.yml stop 2>/dev/null
    echo "✅ Dev environment stopped"
  fi
  
  # Stop Pre-prod
  if [ -d "~/MERN-preprod" ]; then
    cd ~/MERN-preprod
    docker-compose -f docker/compose/docker-compose.preprod.yml stop 2>/dev/null
    echo "✅ Pre-prod environment stopped"
  fi
  
  echo ""
  echo "💰 Resources freed up - Cost saved!"
ENDSSH

echo ""
echo "✅ Auto-stop completed!"

