#!/bin/bash

# Load AWS configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config.sh"

PUBLIC_IP="$AWS_PUBLIC_IP"
KEY_FILE="$AWS_KEY_FILE"

echo "🚀 Starting Dev Environment..."
echo "📍 Instance IP: $PUBLIC_IP"

check_key_file

ssh -i $KEY_FILE ubuntu@$PUBLIC_IP << 'ENDSSH'
  cd ~/MERN-dev
  
  if [ ! -d "docker" ]; then
    echo "❌ Dev environment not found. Please deploy first: ./aws/deploy-dev.sh"
    exit 1
  fi
  
  echo "🔄 Starting containers..."
      docker-compose -f docker/compose/docker-compose.dev.yml up -d
      
      echo "⏳ Waiting for services to start..."
      sleep 5
      
      echo ""
      echo "📊 Container Status:"
      docker-compose -f docker/compose/docker-compose.dev.yml ps
  
  echo ""
  echo "✅ Dev environment started!"
  echo "🌐 Access:"
  echo "   Frontend: http://51.21.127.4:3001"
  echo "   Backend:  http://51.21.127.4:3000"
ENDSSH

echo ""
echo "✅ Dev environment started successfully!"

