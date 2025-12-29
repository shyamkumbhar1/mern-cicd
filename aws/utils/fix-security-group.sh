#!/bin/bash

# Load AWS configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config.sh"

# Use config variables
PUBLIC_IP="$AWS_PUBLIC_IP"

# Allow Security Group ID as command line argument
if [ ! -z "$1" ]; then
  MANUAL_SG_ID="$1"
fi

echo "🔓 Opening Security Group port 8001 for RedisInsight..."

# Method 1: Find Security Group by instance IP
SG_ID=$(aws ec2 describe-instances \
  --filters "Name=ip-address,Values=$PUBLIC_IP" "Name=instance-state-name,Values=running" \
  --query "Reservations[0].Instances[0].SecurityGroups[0].GroupId" \
  --output text 2>&1)

# Method 2: If Method 1 fails, try by instance state
if [ -z "$SG_ID" ] || [ "$SG_ID" == "None" ]; then
  echo "⚠️  Method 1 failed, trying alternative method..."
  SG_ID=$(aws ec2 describe-instances \
    --filters "Name=instance-state-name,Values=running" \
    --query "Reservations[0].Instances[0].SecurityGroups[0].GroupId" \
    --output text 2>&1)
fi

# Method 3: Try to find by listing all instances and matching IP
if [ -z "$SG_ID" ] || [ "$SG_ID" == "None" ]; then
  echo "⚠️  Method 2 failed, trying to find by listing all instances..."
  # Get all running instances with their IPs and Security Groups
  INSTANCE_DATA=$(aws ec2 describe-instances \
    --filters "Name=instance-state-name,Values=running" \
    --query "Reservations[*].Instances[*].[PublicIpAddress,SecurityGroups[0].GroupId]" \
    --output text 2>&1)
  
  # Try to find matching IP
  SG_ID=$(echo "$INSTANCE_DATA" | grep "$PUBLIC_IP" | awk '{print $2}' | head -1)
fi

# Method 4: Try to find Security Group attached to any instance with this IP in network interfaces
if [ -z "$SG_ID" ] || [ "$SG_ID" == "None" ]; then
  echo "⚠️  Method 3 failed, trying network interfaces..."
  SG_ID=$(aws ec2 describe-network-interfaces \
    --filters "Name=addresses.association.public-ip,Values=$PUBLIC_IP" \
    --query "NetworkInterfaces[0].Groups[0].GroupId" \
    --output text 2>&1)
fi

if [ -z "$SG_ID" ] || [ "$SG_ID" == "None" ] || [[ "$SG_ID" == *"error"* ]]; then
  echo "❌ Could not get Security Group ID automatically."
  echo ""
  echo "💡 Available Security Groups in current region:"
  aws ec2 describe-security-groups --query "SecurityGroups[*].[GroupId,GroupName]" --output table 2>&1 | head -15
  echo ""
  echo "💡 To find the correct Security Group:"
  echo "   1. Go to AWS Console → EC2 → Instances"
  echo "   2. Find instance with IP: $PUBLIC_IP"
  echo "   3. Click on instance → Security tab → Security Group ID"
  echo ""
  echo "💡 Or provide Security Group ID manually:"
  if [ -z "$MANUAL_SG_ID" ]; then
    read -p "Enter Security Group ID (e.g., sg-xxxxxxxxx) or press Enter to skip: " MANUAL_SG_ID
  fi
  if [ ! -z "$MANUAL_SG_ID" ]; then
    SG_ID="$MANUAL_SG_ID"
    echo "✅ Using Security Group: $SG_ID"
  else
    echo ""
    echo "📋 Manual steps to open port 8001 in AWS Console:"
    echo "   1. Go to AWS Console → EC2 → Security Groups"
    echo "   2. Find the Security Group attached to instance $PUBLIC_IP"
    echo "   3. Edit Inbound Rules → Add Rule"
    echo "   4. Type: Custom TCP, Port: 8001, Source: 0.0.0.0/0"
    echo "   5. Save rules"
    exit 1
  fi
fi

echo "✅ Found Security Group: $SG_ID"
echo "🔓 Opening port 8001..."

# Check if port is already open
EXISTING=$(aws ec2 describe-security-groups \
  --group-ids $SG_ID \
  --query "SecurityGroups[0].IpPermissions[?FromPort==\`8001\` && ToPort==\`8001\`]" \
  --output json 2>/dev/null)

if [ "$EXISTING" != "[]" ] && [ "$EXISTING" != "null" ] && [ ! -z "$EXISTING" ]; then
  echo "ℹ️  Port 8001 is already open in Security Group"
else
  # Open port 8001
  RESULT=$(aws ec2 authorize-security-group-ingress \
    --group-id $SG_ID \
    --protocol tcp \
    --port 8001 \
    --cidr 0.0.0.0/0 2>&1)
  EXIT_CODE=$?
  
  if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ Port 8001 opened successfully!"
  else
    if [[ "$RESULT" == *"already exists"* ]] || [[ "$RESULT" == *"duplicate"* ]]; then
      echo "ℹ️  Port 8001 already exists (may have been added between check and add)"
    else
      echo "❌ Failed to open port 8001:"
      echo "$RESULT"
      exit 1
    fi
  fi
fi

# Verify port is open
echo ""
echo "🔍 Verifying port 8001 is open..."
VERIFY=$(aws ec2 describe-security-groups \
  --group-ids $SG_ID \
  --query "SecurityGroups[0].IpPermissions[?FromPort==\`8001\` && ToPort==\`8001\`]" \
  --output json 2>/dev/null)

if [ "$VERIFY" != "[]" ] && [ "$VERIFY" != "null" ] && [ ! -z "$VERIFY" ]; then
  echo "✅ Verified: Port 8001 is open in Security Group"
  echo ""
  echo "🌐 RedisInsight should now be accessible at:"
  echo "   http://$PUBLIC_IP:8001"
else
  echo "⚠️  Warning: Could not verify port 8001 is open"
  echo "   Please check manually in AWS Console"
fi

