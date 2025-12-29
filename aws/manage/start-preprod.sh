#!/bin/bash

# Load AWS configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config.sh"

PUBLIC_IP="$AWS_PUBLIC_IP"
KEY_FILE="$AWS_KEY_FILE"

echo "🚀 Starting Pre-prod Environment..."
echo "📍 Instance IP: $PUBLIC_IP"

check_key_file

ssh -i $KEY_FILE ubuntu@$PUBLIC_IP << 'ENDSSH'
  cd ~/MERN-preprod
  
  if [ ! -d "docker" ]; then
    echo "❌ Pre-prod environment not found. Please deploy first: ./aws/deploy-preprod.sh"
    exit 1
  fi
  
  echo "🔄 Starting containers..."
      docker-compose -f docker/compose/docker-compose.preprod.yml up -d
      
      echo "⏳ Waiting for services to start..."
      sleep 5
      
      echo ""
      echo "📊 Container Status:"
      docker-compose -f docker/compose/docker-compose.preprod.yml ps
  
  echo ""
  echo "✅ Pre-prod environment started!"
  echo "🌐 Access:"
  echo "   Frontend: http://51.21.127.4:8080"
  echo "   Backend:  http://51.21.127.4:4000"
ENDSSH

echo ""
echo "✅ Pre-prod environment started successfully!"

