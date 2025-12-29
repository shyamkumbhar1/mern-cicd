#!/bin/bash

# Load AWS configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config.sh"

# Environment-specific variables
export ENV="preprod"
export AWS_REMOTE_PATH="~/MERN-preprod"
export COMPOSE_FILE="docker/compose/docker-compose.preprod.yml"
export ENV_FILE=".env.preprod"

# Use config variables
PUBLIC_IP="$AWS_PUBLIC_IP"
KEY_FILE="$AWS_KEY_FILE"
PROJECT_PATH="$AWS_PROJECT_PATH"

echo "🚀 Deploying MERN Stack to AWS - PRE-PROD Environment"
echo "📍 Instance IP: $PUBLIC_IP"
echo "📊 Database: basic-crud-staging (MongoDB Atlas)"
echo "🌍 Environment: Pre-Production (Staging)"

# Check key file exists
check_key_file

# Transfer project (exclude key file)
echo "📦 Transferring project to server..."
if command -v rsync &> /dev/null; then
  if ! rsync -avz --exclude='server-practic.pem' --exclude='node_modules' --exclude='.git' \
    -e "ssh -i $KEY_FILE" \
    $PROJECT_PATH/ ubuntu@$PUBLIC_IP:$AWS_REMOTE_PATH/ 2>&1; then
    echo "❌ Failed to transfer project to server"
    exit 1
  fi
else
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

# Setup and deploy on EC2
echo "⚙️  Setting up on server..."
DEPLOY_ERROR=0

ssh -i $KEY_FILE ubuntu@$PUBLIC_IP << ENDSSH || DEPLOY_ERROR=1
  cd $AWS_REMOTE_PATH
  
  # Install Docker if not installed
  if ! command -v docker &> /dev/null; then
    echo "📦 Installing Docker..."
    sudo apt update -y
    sudo apt install -y docker.io docker-compose
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker ubuntu
    echo "✅ Docker installed"
  fi
  
  # Ensure .env.preprod exists
  if [ ! -f "$ENV_FILE" ]; then
    echo "Creating $ENV_FILE..."
    cat > $ENV_FILE << EOF
NODE_ENV=staging
PORT=3000
MONGO_URI=mongodb+srv://shyamkumbhar509_db_user:6kUz4xLQGc2msUDz@ecommarce.ep0aggw.mongodb.net/basic-crud-staging?retryWrites=true&w=majority
REDIS_HOST=redis
REDIS_PORT=6379
REACT_APP_API_URL=http://$PUBLIC_IP:4000
EOF
  fi
  
  # Stop existing containers
  echo "🛑 Stopping existing containers..."
  docker-compose -f $COMPOSE_FILE down 2>/dev/null || true
  
  # Build containers
  echo "🏗️  Building containers..."
  if ! docker-compose -f $COMPOSE_FILE build 2>&1; then
    echo "❌ BUILD FAILED!"
    docker-compose -f $COMPOSE_FILE build 2>&1 | tail -30
    exit 1
  fi
  echo "✅ Build successful"
  
  # Start containers
  echo "🚀 Starting containers..."
  if ! docker-compose -f $COMPOSE_FILE up -d 2>&1; then
    echo "❌ FAILED TO START CONTAINERS!"
    docker-compose -f $COMPOSE_FILE logs --tail=50
    exit 1
  fi
  
  # Wait for services
  echo "⏳ Waiting for services to start..."
  sleep 15
  
  # Check container status
  echo ""
  echo "📊 Container Status:"
  docker-compose -f $COMPOSE_FILE ps
  
  echo ""
  echo "✅ Pre-prod deployment complete!"
ENDSSH

if [ $DEPLOY_ERROR -eq 1 ]; then
  echo "❌ Deployment failed!"
  exit 1
fi

# Open security group ports for pre-prod
echo ""
echo "🔓 Opening security group ports for Pre-prod..."
SG_ID=$(aws ec2 describe-instances \
  --filters "Name=ip-address,Values=$PUBLIC_IP" "Name=instance-state-name,Values=running" \
  --query "Reservations[0].Instances[0].SecurityGroups[0].GroupId" \
  --output text 2>/dev/null)

if [ ! -z "$SG_ID" ] && [ "$SG_ID" != "None" ]; then
  open_port() {
    local port=$1
    local name=$2
    EXISTING=$(aws ec2 describe-security-groups \
      --group-ids $SG_ID \
      --query "SecurityGroups[0].IpPermissions[?FromPort==\`${port}\` && ToPort==\`${port}\`]" \
      --output json 2>/dev/null)
    
    if [ "$EXISTING" == "[]" ] || [ "$EXISTING" == "null" ] || [ -z "$EXISTING" ]; then
      aws ec2 authorize-security-group-ingress \
        --group-id $SG_ID \
        --protocol tcp \
        --port $port \
        --cidr 0.0.0.0/0 2>/dev/null && echo "✅ Port ${port} (${name}) opened" || echo "ℹ️  Port ${port} already exists"
    else
      echo "ℹ️  Port ${port} (${name}) already open"
    fi
  }
  
  open_port 8080 "Pre-prod Frontend"
  open_port 4000 "Pre-prod Backend"
  open_port 8002 "Pre-prod RedisInsight"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ PRE-PROD DEPLOYMENT SUCCESSFUL!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🌐 Access your Pre-prod application:"
echo "   Frontend: http://$PUBLIC_IP:8080"
echo "   Backend:  http://$PUBLIC_IP:4000"
echo "   RedisInsight: http://$PUBLIC_IP:8002"
echo "   Health:   http://$PUBLIC_IP:4000/health"
echo ""
echo "📊 Database: basic-crud-staging (MongoDB Atlas)"
echo ""

