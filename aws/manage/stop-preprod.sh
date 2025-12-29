#!/bin/bash

# Load AWS configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config.sh"

PUBLIC_IP="$AWS_PUBLIC_IP"
KEY_FILE="$AWS_KEY_FILE"

echo "🛑 Stopping Pre-prod Environment..."
echo "📍 Instance IP: $PUBLIC_IP"

check_key_file

ssh -i $KEY_FILE ubuntu@$PUBLIC_IP << 'ENDSSH'
  cd ~/MERN-preprod
  
  if [ ! -d "docker" ]; then
    echo "ℹ️  Pre-prod environment not found (already stopped or not deployed)"
    exit 0
  fi
  
  echo "🛑 Stopping containers..."
      docker-compose -f docker/compose/docker-compose.preprod.yml stop
      
      echo ""
      echo "📊 Container Status:"
      docker-compose -f docker/compose/docker-compose.preprod.yml ps
  
  echo ""
  echo "✅ Pre-prod environment stopped!"
  echo "💡 To start again: ./aws/start-preprod.sh"
ENDSSH

echo ""
echo "✅ Pre-prod environment stopped successfully!"
echo "💰 Cost saved: Resources freed up"

