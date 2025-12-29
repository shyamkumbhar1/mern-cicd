#!/bin/bash

# AWS Cost Monitoring Script
# Shows current month's AWS costs

echo "💰 AWS Cost Monitoring"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if AWS CLI is configured
if ! command -v aws &> /dev/null; then
  echo "❌ AWS CLI not installed"
  echo "💡 Install: sudo apt install awscli"
  exit 1
fi

# Check if credentials are configured
if ! aws sts get-caller-identity &> /dev/null; then
  echo "❌ AWS credentials not configured"
  echo "💡 Run: aws configure"
  exit 1
fi

# Get current month start and end dates
START_DATE=$(date -d "$(date +%Y-%m-01)" +%Y-%m-%d)
END_DATE=$(date +%Y-%m-%d)

echo "📅 Period: $START_DATE to $END_DATE"
echo ""

# Get cost and usage
echo "📊 Fetching cost data..."
COST=$(aws ce get-cost-and-usage \
  --time-period Start=$START_DATE,End=$END_DATE \
  --granularity MONTHLY \
  --metrics BlendedCost \
  --query 'ResultsByTime[0].Total.BlendedCost.Amount' \
  --output text 2>/dev/null)

if [ $? -eq 0 ] && [ ! -z "$COST" ]; then
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "💵 Current Month Cost: \$${COST}"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  
  # Calculate estimated monthly cost
  DAYS_PASSED=$(($(date +%d)))
  DAYS_IN_MONTH=$(date -d "$(date +%Y-%m-01) +1 month -1 day" +%d)
  ESTIMATED_MONTHLY=$(echo "scale=2; $COST * $DAYS_IN_MONTH / $DAYS_PASSED" | bc)
  
  echo "📈 Estimated Monthly Cost: \$$ESTIMATED_MONTHLY"
  echo ""
  
  # Cost breakdown by service (if available)
  echo "📋 Cost Breakdown by Service:"
  aws ce get-cost-and-usage \
    --time-period Start=$START_DATE,End=$END_DATE \
    --granularity MONTHLY \
    --metrics BlendedCost \
    --group-by Type=SERVICE \
    --query 'ResultsByTime[0].Groups[*].[Keys[0],Metrics.BlendedCost.Amount]' \
    --output table 2>/dev/null | head -20
  
  echo ""
  echo "💡 Cost Saving Tips:"
  echo "   1. Stop dev/pre-prod when not in use: ./aws/stop-dev.sh"
  echo "   2. Use resource limits (already configured)"
  echo "   3. Consider Reserved Instances for long-term"
  echo "   4. Right-size your instance type"
  
else
  echo "⚠️  Could not fetch cost data"
  echo "💡 Make sure AWS Cost Explorer is enabled"
  echo "   Or check AWS Console: https://console.aws.amazon.com/cost-management/"
fi

echo ""

