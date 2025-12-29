#!/bin/bash

# Load AWS configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config.sh"

PUBLIC_IP="$AWS_PUBLIC_IP"
KEY_FILE="$AWS_KEY_FILE"

echo "🛑 Stopping Dev Environment..."
echo "📍 Instance IP: $PUBLIC_IP"

check_key_file

ssh -i $KEY_FILE ubuntu@$PUBLIC_IP << 'ENDSSH'
  cd ~/MERN-dev
  
  if [ ! -d "docker" ]; then
    echo "ℹ️  Dev environment not found (already stopped or not deployed)"
    exit 0
  fi
  
  echo "🛑 Stopping containers..."
      docker-compose -f docker/compose/docker-compose.dev.yml stop
      
      echo ""
      echo "📊 Container Status:"
      docker-compose -f docker/compose/docker-compose.dev.yml ps
  
  echo ""
  echo "✅ Dev environment stopped!"
  echo "💡 To start again: ./aws/start-dev.sh"
ENDSSH

echo ""
echo "✅ Dev environment stopped successfully!"
echo "💰 Cost saved: Resources freed up"

