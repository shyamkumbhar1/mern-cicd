#!/bin/bash

# Load AWS configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config.sh"

# Use config variables
PUBLIC_IP="$AWS_PUBLIC_IP"
KEY_FILE="$AWS_KEY_FILE"

echo "🔧 Fixing Redis cache issue..."
echo ""

# Check key file
check_key_file

echo "📦 Step 1: Checking current backend container..."
ssh -i "$KEY_FILE" -o StrictHostKeyChecking=no ubuntu@$PUBLIC_IP "docker exec mern-backend node -e \"try { require('redis'); console.log('✅ Redis module found'); } catch(e) { console.log('❌ Redis module missing'); }\" 2>&1" 2>&1

echo ""
echo "🔨 Step 2: Rebuilding backend container with Redis dependency..."
ssh -i "$KEY_FILE" -o StrictHostKeyChecking=no ubuntu@$PUBLIC_IP << 'ENDSSH'
  cd ~/MERN-prod
  echo "Stopping backend container..."
  docker-compose -f docker/compose/docker-compose.prod.yml stop backend
  
  echo "Rebuilding backend image..."
  docker-compose -f docker/compose/docker-compose.prod.yml build --no-cache backend
  
  echo "Starting backend container..."
  docker-compose -f docker/compose/docker-compose.prod.yml up -d backend
  
  echo "Waiting for backend to start..."
  sleep 5
ENDSSH

echo ""
echo "✅ Step 3: Verifying Redis connection..."
sleep 3
ssh -i "$KEY_FILE" -o StrictHostKeyChecking=no ubuntu@$PUBLIC_IP "docker logs mern-backend --tail=20 2>&1 | grep -i redis" 2>&1

echo ""
echo "🧪 Step 4: Testing API and cache..."
echo "Making API call to generate cache..."
curl -s http://$PUBLIC_IP:3000/api/items > /dev/null
sleep 2

echo ""
echo "Checking Redis keys..."
ssh -i "$KEY_FILE" -o StrictHostKeyChecking=no ubuntu@$PUBLIC_IP "docker exec mern-redis redis-cli KEYS '*' 2>&1" 2>&1

echo ""
echo "✅ Fix completed!"
echo "🌐 Check RedisInsight: http://$PUBLIC_IP:8001"

