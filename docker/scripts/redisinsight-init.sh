#!/bin/sh
# Auto-configure RedisInsight to connect to Redis database
# Works on both local and AWS environments
# This script runs automatically when RedisInsight container starts

set -e

echo "🔄 RedisInsight Auto-Configuration Script"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Configuration
RI_API="http://localhost:5540/api/v1"
REDIS_HOST=${REDIS_HOST:-redis}
REDIS_PORT=${REDIS_PORT:-6379}
DB_NAME=${DB_NAME:-"MERN Redis"}
MAX_RETRIES=20
RETRY_DELAY=3

# Function to check if RedisInsight API is ready
check_api_ready() {
  local attempt=1
  echo "⏳ Waiting for RedisInsight API to be ready..."
  
  while [ $attempt -le $MAX_RETRIES ]; do
    # Try multiple endpoints and methods
    if wget -q --spider --timeout=3 "$RI_API/instance" 2>/dev/null || \
       wget -qO- --timeout=3 "http://localhost:5540" 2>/dev/null | grep -q "html\|json" || \
       wget -qO- --timeout=3 "http://localhost:5540/api/instance" 2>/dev/null | grep -q "instance\|version" || \
       wget -qO- --timeout=3 "http://localhost:5540/api/v1/instance" 2>/dev/null | grep -q "instance\|version"; then
      echo "✅ RedisInsight API is ready (attempt $attempt/$MAX_RETRIES)"
      # Give it a few more seconds to fully initialize
      sleep 5
      return 0
    fi
    echo "   Attempt $attempt/$MAX_RETRIES - API not ready yet, waiting ${RETRY_DELAY}s..."
    sleep $RETRY_DELAY
    attempt=$((attempt + 1))
  done
  
  echo "❌ RedisInsight API not ready after $MAX_RETRIES attempts"
  echo "💡 RedisInsight might need more time to start"
  echo "💡 You can add database manually via UI: http://localhost:8001"
  return 1
}

# Function to check if database already exists
check_database_exists() {
  local response
  response=$(wget -qO- --timeout=5 "$RI_API/databases" 2>/dev/null || echo "[]")
  
  if echo "$response" | grep -q "\"host\":\"$REDIS_HOST\"" && echo "$response" | grep -q "\"port\":$REDIS_PORT"; then
    echo "ℹ️  Database connection already exists"
    return 0
  fi
  return 1
}

# Function to add Redis database
add_database() {
  echo "📦 Adding Redis database to RedisInsight..."
  echo "   Host: $REDIS_HOST"
  echo "   Port: $REDIS_PORT"
  echo "   Name: $DB_NAME"
  
  # Create database configuration JSON
  DB_CONFIG=$(cat <<EOF
{
  "host": "$REDIS_HOST",
  "port": $REDIS_PORT,
  "name": "$DB_NAME",
  "db": 0,
  "connectionType": "STANDALONE",
  "tls": false,
  "verifyServerCert": false
}
EOF
)
  
  # Try to add database
  local response
  local http_code
  
  response=$(wget -qO- --post-data="$DB_CONFIG" \
    --header="Content-Type: application/json" \
    --header="Accept: application/json" \
    --timeout=10 \
    "$RI_API/databases" 2>&1)
  
  http_code=$?
  
  if [ $http_code -eq 0 ] && [ -n "$response" ]; then
    # Check if response contains error
    if echo "$response" | grep -qi "error\|fail\|exception"; then
      echo "⚠️  API returned error: $response"
      return 1
    else
      echo "✅ Redis database added successfully!"
      echo "   Response: $response"
      return 0
    fi
  else
    echo "⚠️  Failed to add database (HTTP code: $http_code)"
    echo "   Response: $response"
    return 1
  fi
}

# Main execution
main() {
  # Wait for RedisInsight API to be ready
  if ! check_api_ready; then
    echo "❌ Cannot proceed - RedisInsight API not available"
    echo "💡 You may need to add database manually via UI: http://localhost:8001"
    exit 1
  fi
  
  # Check if database already exists
  if check_database_exists; then
    echo "✅ Database connection already configured"
    exit 0
  fi
  
  # Add database
  if add_database; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✅ RedisInsight Auto-Configuration Complete!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "🌐 Access RedisInsight: http://localhost:8001"
    echo "📊 Database: $DB_NAME ($REDIS_HOST:$REDIS_PORT)"
    exit 0
  else
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "⚠️  Auto-configuration failed"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "💡 You can add database manually:"
    echo "   1. Open: http://localhost:8001"
    echo "   2. Click 'Add Database'"
    echo "   3. Host: $REDIS_HOST"
    echo "   4. Port: $REDIS_PORT"
    echo ""
    exit 1
  fi
}

# Run main function in background
main &
