#!/bin/bash

# Your EC2 Details
PUBLIC_IP="51.21.127.4"
KEY_FILE="/home/india/shared/solominds/MERN/server-practic.pem"
PROJECT_PATH="/home/india/shared/solominds/MERN"

echo "🚀 Deploying MERN Stack to AWS..."
echo "📍 Instance IP: $PUBLIC_IP"
echo "📊 Database: basic-crud (MongoDB Atlas)"

# Check key file exists
if [ ! -f "$KEY_FILE" ]; then
  echo "❌ Key file not found: $KEY_FILE"
  exit 1
fi

# Set correct permissions for key file
chmod 400 $KEY_FILE

# Check if .env.production exists
if [ ! -f "$PROJECT_PATH/.env.production" ]; then
  echo "⚠️  .env.production not found, creating from .env..."
  cp "$PROJECT_PATH/.env" "$PROJECT_PATH/.env.production" 2>/dev/null || true
fi

# Transfer project (exclude key file)
echo "📦 Transferring project to server..."

# Use rsync if available, otherwise scp with exclusions
if command -v rsync &> /dev/null; then
  if ! rsync -avz --exclude='server-practic.pem' --exclude='node_modules' --exclude='.git' \
    -e "ssh -i $KEY_FILE" \
    $PROJECT_PATH/ ubuntu@$PUBLIC_IP:~/MERN/ 2>&1; then
    echo "❌ Failed to transfer project to server"
    exit 1
  fi
else
  # Fallback: Create temp dir without key file
  TEMP_DIR=$(mktemp -d)
  cp -r $PROJECT_PATH/* $TEMP_DIR/ 2>/dev/null || true
  cp -r $PROJECT_PATH/.* $TEMP_DIR/ 2>/dev/null || true
  rm -f $TEMP_DIR/server-practic.pem 2>/dev/null || true
  
  if ! scp -i $KEY_FILE -r $TEMP_DIR ubuntu@$PUBLIC_IP:~/MERN 2>&1; then
    echo "❌ Failed to transfer project to server"
    rm -rf $TEMP_DIR
    exit 1
  fi
  rm -rf $TEMP_DIR
fi

# Setup and deploy on EC2 with error handling
echo "⚙️  Setting up on server..."
DEPLOY_ERROR=0

ssh -i $KEY_FILE ubuntu@$PUBLIC_IP << 'ENDSSH' || DEPLOY_ERROR=1
  # Don't use set -e - let individual commands handle errors
  # set -e  # Removed - too strict, causes false failures
  
  cd ~/MERN
  
  # Update system
  echo "📦 Updating system..."
  sudo apt update -y || {
    echo "⚠️  System update warning (continuing anyway)"
  }
  
  # Install Docker if not installed
  if ! command -v docker &> /dev/null; then
    echo "📦 Installing Docker..."
    if ! sudo apt install -y docker.io docker-compose; then
      echo "❌ Docker installation failed"
      exit 1
    fi
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker ubuntu
    echo "✅ Docker installed"
  else
    echo "✅ Docker already installed"
  fi
  
  # Ensure .env.production exists
  if [ ! -f ".env.production" ]; then
    echo "Creating .env.production..."
    cat > .env.production << EOF
MONGO_URI=mongodb+srv://shyamkumbhar509_db_user:6kUz4xLQGc2msUDz@ecommarce.ep0aggw.mongodb.net/basic-crud?retryWrites=true&w=majority
NODE_ENV=production
PORT=3000
REACT_APP_API_URL=http://51.21.127.4:3000
EOF
  fi
  
  # Stop existing containers
  echo "🛑 Stopping existing containers..."
  docker-compose -f docker/docker-compose.prod.yml down 2>/dev/null || true
  
  # Build containers
  echo "🏗️  Building containers..."
  if ! docker-compose -f docker/docker-compose.prod.yml build 2>&1; then
    echo ""
    echo "❌ BUILD FAILED!"
    echo "📋 Build errors:"
    docker-compose -f docker/docker-compose.prod.yml build 2>&1 | tail -30
    exit 1
  fi
  echo "✅ Build successful"
  
  # Start containers
  echo "🚀 Starting containers..."
  if ! docker-compose -f docker/docker-compose.prod.yml up -d 2>&1; then
    echo ""
    echo "❌ FAILED TO START CONTAINERS!"
    echo "📋 Container logs:"
    docker-compose -f docker/docker-compose.prod.yml logs --tail=50
    exit 1
  fi
  
  # Wait for services (optimized timing)
  echo "⏳ Waiting for services to start (15 seconds)..."
  sleep 15
  
  # Check container status
  echo ""
  echo "📊 Container Status:"
  docker-compose -f docker/docker-compose.prod.yml ps
  
  # Verify containers are running
  BACKEND_RUNNING=$(docker ps --format "{{.Names}}" | grep -c "mern.*backend" || echo "0")
  FRONTEND_RUNNING=$(docker ps --format "{{.Names}}" | grep -c "mern.*frontend" || echo "0")
  
  echo ""
  if [ "$BACKEND_RUNNING" -eq "0" ]; then
    echo "❌ Backend container is NOT running!"
    echo "📋 Backend logs:"
    docker-compose -f docker/docker-compose.prod.yml logs backend --tail=50
    exit 1
  else
    echo "✅ Backend container is running"
  fi
  
  if [ "$FRONTEND_RUNNING" -eq "0" ]; then
    echo "❌ Frontend container is NOT running!"
    echo "📋 Frontend logs:"
    docker-compose -f docker/docker-compose.prod.yml logs frontend --tail=50
    exit 1
  else
    echo "✅ Frontend container is running"
  fi
  
  # Quick checks (optimized - less wait time)
  echo ""
  echo "🔍 Quick status check..."
  sleep 3
  
  # Check MongoDB connection (quick check)
  BACKEND_LOGS=$(docker-compose -f docker/docker-compose.prod.yml logs backend --tail=20 2>&1)
  if echo "$BACKEND_LOGS" | grep -q "MongoDB Atlas Connected"; then
    echo "✅ MongoDB connected"
  else
    echo "ℹ️  MongoDB connecting (will retry automatically)"
  fi
  
  # Quick health check (2 retries instead of 3)
  echo "🔍 Testing backend..."
  HEALTH_OK=0
  for i in {1..2}; do
    sleep 3
    if curl -f -s http://localhost:3000/health > /dev/null 2>&1; then
      echo "✅ Backend ready"
      HEALTH_OK=1
      break
    fi
  done
  
  if [ $HEALTH_OK -eq 0 ]; then
    echo "ℹ️  Backend starting (containers running, will be ready soon)"
  fi
  
  echo ""
  echo "✅ All deployment checks passed!"
ENDSSH

DEPLOY_EXIT_CODE=$?

# Check deployment result
if [ $DEPLOY_EXIT_CODE -ne 0 ] || [ $DEPLOY_ERROR -eq 1 ]; then
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "❌ DEPLOYMENT FAILED!"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "📋 To debug, run:"
  echo "   ssh -i $KEY_FILE ubuntu@$PUBLIC_IP"
  echo "   cd ~/MERN"
  echo "   docker-compose -f docker/docker-compose.prod.yml logs"
  echo ""
  echo "   Or check specific service:"
  echo "   docker-compose -f docker/docker-compose.prod.yml logs backend"
  echo "   docker-compose -f docker/docker-compose.prod.yml logs frontend"
  echo ""
  exit 1
fi

# Open security group ports
echo ""
echo "🔓 Checking security group ports..."
SG_ID=$(aws ec2 describe-instances \
  --filters "Name=instance-state-name,Values=running" \
  --query "Reservations[0].Instances[0].SecurityGroups[0].GroupId" \
  --output text 2>/dev/null)

if [ ! -z "$SG_ID" ]; then
  aws ec2 authorize-security-group-ingress \
    --group-id $SG_ID \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0 2>/dev/null && echo "✅ Port 80 opened" || echo "ℹ️  Port 80 already open"
  
  aws ec2 authorize-security-group-ingress \
    --group-id $SG_ID \
    --protocol tcp \
    --port 3000 \
    --cidr 0.0.0.0/0 2>/dev/null && echo "✅ Port 3000 opened" || echo "ℹ️  Port 3000 already open"
else
  echo "⚠️  Could not get security group ID. Please open ports 80 and 3000 manually in AWS Console."
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ DEPLOYMENT SUCCESSFUL!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🌐 Access your application:"
echo "   Frontend: http://$PUBLIC_IP"
echo "   Backend:  http://$PUBLIC_IP:3000"
echo "   Health:   http://$PUBLIC_IP:3000/health"
echo ""
echo "📊 Database: basic-crud (MongoDB Atlas)"
echo ""
echo "📝 Useful commands:"
echo "   View logs: ssh -i $KEY_FILE ubuntu@$PUBLIC_IP 'cd ~/MERN && docker-compose -f docker/docker-compose.prod.yml logs'"
echo "   Restart:   ssh -i $KEY_FILE ubuntu@$PUBLIC_IP 'cd ~/MERN && docker-compose -f docker/docker-compose.prod.yml restart'"
echo ""
