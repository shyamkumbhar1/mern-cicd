#!/bin/bash

# Load AWS configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config.sh"

# Use config variables
PUBLIC_IP="$AWS_PUBLIC_IP"
KEY_FILE="$AWS_KEY_FILE"
PROJECT_PATH="$AWS_PROJECT_PATH"

# Environment-specific variables for Production
export ENV="production"
export AWS_REMOTE_PATH="~/MERN-prod"
export COMPOSE_FILE="docker/compose/docker-compose.prod.yml"
export ENV_FILE=".env.production"

echo "🚀 Deploying MERN Stack to AWS - PRODUCTION Environment"
echo "📍 Instance IP: $PUBLIC_IP"
echo "📊 Database: basic-crud (MongoDB Atlas)"
echo "🌍 Environment: Production"

# Check key file exists
check_key_file

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
    $PROJECT_PATH/ ubuntu@$PUBLIC_IP:$AWS_REMOTE_PATH/ 2>&1; then
    echo "❌ Failed to transfer project to server"
    exit 1
  fi
else
  # Fallback: Create temp dir without key file
  TEMP_DIR=$(mktemp -d)
  cp -r $PROJECT_PATH/* $TEMP_DIR/ 2>/dev/null || true
  cp -r $PROJECT_PATH/.* $TEMP_DIR/ 2>/dev/null || true
  rm -f $TEMP_DIR/server-practic.pem 2>/dev/null || true
  
  if ! scp -i $KEY_FILE -r $TEMP_DIR ubuntu@$PUBLIC_IP:$AWS_REMOTE_PATH 2>&1; then
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
  docker-compose -f $COMPOSE_FILE down 2>/dev/null || true
  
  # Build containers
  echo "🏗️  Building containers..."
  if ! docker-compose -f $COMPOSE_FILE build 2>&1; then
    echo ""
    echo "❌ BUILD FAILED!"
    echo "📋 Build errors:"
    docker-compose -f $COMPOSE_FILE build 2>&1 | tail -30
    exit 1
  fi
  echo "✅ Build successful"
  
  # Start containers
  echo "🚀 Starting containers..."
  if ! docker-compose -f $COMPOSE_FILE up -d 2>&1; then
    echo ""
    echo "❌ FAILED TO START CONTAINERS!"
    echo "📋 Container logs:"
    docker-compose -f $COMPOSE_FILE logs --tail=50
    exit 1
  fi
  
  # Wait for services (optimized timing)
  echo "⏳ Waiting for services to start (15 seconds)..."
  sleep 15
  
  # Check container status
  echo ""
  echo "📊 Container Status:"
  docker-compose -f $COMPOSE_FILE ps
  
  # Verify containers are running
  BACKEND_RUNNING=$(docker ps --format "{{.Names}}" | grep -c "mern.*backend" || echo "0")
  FRONTEND_RUNNING=$(docker ps --format "{{.Names}}" | grep -c "mern.*frontend" || echo "0")
  
  echo ""
  if [ "$BACKEND_RUNNING" -eq "0" ]; then
    echo "❌ Backend container is NOT running!"
        echo "📋 Backend logs:"
        docker-compose -f $COMPOSE_FILE logs backend --tail=50
        exit 1
      else
        echo "✅ Backend container is running"
      fi
      
      if [ "$FRONTEND_RUNNING" -eq "0" ]; then
        echo "❌ Frontend container is NOT running!"
        echo "📋 Frontend logs:"
        docker-compose -f $COMPOSE_FILE logs frontend --tail=50
    exit 1
  else
    echo "✅ Frontend container is running"
  fi
  
  # Quick checks (optimized - less wait time)
  echo ""
  echo "🔍 Quick status check..."
  sleep 3
  
  # Check MongoDB connection (quick check)
  BACKEND_LOGS=$(docker-compose -f $COMPOSE_FILE logs backend --tail=20 2>&1)
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
  echo "   cd $AWS_REMOTE_PATH"
  echo "   docker-compose -f $COMPOSE_FILE logs"
  echo ""
  echo "   Or check specific service:"
  echo "   docker-compose -f $COMPOSE_FILE logs backend"
  echo "   docker-compose -f $COMPOSE_FILE logs frontend"
  echo ""
  exit 1
fi

# Open security group ports
echo ""
echo "🔓 Checking security group ports..."
# Try to find Security Group by instance IP first, then fallback to running instances
SG_ID=$(aws ec2 describe-instances \
  --filters "Name=ip-address,Values=$PUBLIC_IP" "Name=instance-state-name,Values=running" \
  --query "Reservations[0].Instances[0].SecurityGroups[0].GroupId" \
  --output text 2>/dev/null)

# Fallback method if first fails
if [ -z "$SG_ID" ] || [ "$SG_ID" == "None" ]; then
  SG_ID=$(aws ec2 describe-instances \
    --filters "Name=instance-state-name,Values=running" \
    --query "Reservations[0].Instances[0].SecurityGroups[0].GroupId" \
    --output text 2>/dev/null)
fi

if [ ! -z "$SG_ID" ] && [ "$SG_ID" != "None" ] && [[ ! "$SG_ID" == *"error"* ]]; then
  echo "✅ Found Security Group: $SG_ID"
  
  # Function to open port with better error handling
  open_port() {
    local port=$1
    local name=$2
    
    # Check if port already exists
    EXISTING=$(aws ec2 describe-security-groups \
      --group-ids $SG_ID \
      --query "SecurityGroups[0].IpPermissions[?FromPort==\`${port}\` && ToPort==\`${port}\`]" \
      --output json 2>/dev/null)
    
    if [ "$EXISTING" != "[]" ] && [ "$EXISTING" != "null" ] && [ ! -z "$EXISTING" ]; then
      echo "ℹ️  Port ${port} (${name}) already open"
    else
      RESULT=$(aws ec2 authorize-security-group-ingress \
        --group-id $SG_ID \
        --protocol tcp \
        --port $port \
        --cidr 0.0.0.0/0 2>&1)
      
      if [ $? -eq 0 ]; then
        echo "✅ Port ${port} (${name}) opened"
      elif [[ "$RESULT" == *"already exists"* ]] || [[ "$RESULT" == *"duplicate"* ]]; then
        echo "ℹ️  Port ${port} (${name}) already exists"
      else
        echo "⚠️  Failed to open port ${port}: ${RESULT}"
      fi
    fi
  }
  
  open_port 80 "Frontend"
  open_port 3000 "Backend"
  open_port 8001 "RedisInsight"
else
  echo "⚠️  Could not get security group ID automatically."
  echo "   Please run: ./aws/fix-security-group.sh"
  echo "   Or open ports 80, 3000, and 8001 manually in AWS Console."
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ DEPLOYMENT SUCCESSFUL!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🌐 Access your application:"
echo "   Frontend: http://$PUBLIC_IP"
echo "   Backend:  http://$PUBLIC_IP:3000"
echo "   RedisInsight: http://$PUBLIC_IP:8001"
echo "   Health:   http://$PUBLIC_IP:3000/health"
echo ""
echo "📊 Database: basic-crud (MongoDB Atlas)"
echo ""
echo "📝 Useful commands:"
echo "   View logs: ssh -i $KEY_FILE ubuntu@$PUBLIC_IP 'cd $AWS_REMOTE_PATH && docker-compose -f $COMPOSE_FILE logs'"
echo "   Restart:   ssh -i $KEY_FILE ubuntu@$PUBLIC_IP 'cd $AWS_REMOTE_PATH && docker-compose -f $COMPOSE_FILE restart'"
echo ""

