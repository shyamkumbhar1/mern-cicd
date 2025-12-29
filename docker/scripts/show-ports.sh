#!/bin/bash
# Display port configuration in a readable format

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PORTS_FILE="$SCRIPT_DIR/../config/ports.yml"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}📋 Port Configuration Summary${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if [ ! -f "$PORTS_FILE" ]; then
  echo "❌ Ports file not found: $PORTS_FILE"
  exit 1
fi

# Check if yq is installed (YAML parser)
if ! command -v yq &> /dev/null; then
  echo "⚠️  yq not installed. Showing basic info..."
  echo ""
  echo "📄 Ports file location: $PORTS_FILE"
  echo ""
  echo "💡 To install yq for better parsing:"
  echo "   sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64"
  echo "   sudo chmod +x /usr/local/bin/yq"
  echo ""
  echo "📋 Current Ports (from docker-compose files):"
  echo ""
  echo "Local Environment:"
  echo "  Frontend:    http://localhost:3001"
  echo "  Backend:     http://localhost:3000"
  echo "  Redis:       redis://localhost:6379"
  echo "  RedisInsight: http://localhost:8001"
  echo ""
  echo "Production Environment (51.21.127.4):"
  echo "  Frontend:    http://51.21.127.4"
  echo "  Backend:     http://51.21.127.4:3000"
  echo "  RedisInsight: http://51.21.127.4:8001"
  echo "  Redis:       Internal only (not exposed)"
  exit 0
fi

# Parse and display using yq
echo -e "${CYAN}📍 Local Development Environment${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
yq eval '.environments.local.services | to_entries | .[] | "  \(.key | ascii_upcase):\n    Port: \(.value.host_port):\(.value.container_port)\n    URL: \(.value.url)\n    Purpose: \(.value.purpose)\n"' "$PORTS_FILE" 2>/dev/null || echo "  Error parsing local config"

echo ""
echo -e "${CYAN}☁️  Production Environment (AWS)${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
SERVER_IP=$(yq eval '.environments.production.server_ip' "$PORTS_FILE" 2>/dev/null)
echo "  Server IP: $SERVER_IP"
echo ""
yq eval '.environments.production.services | to_entries | .[] | "  \(.key | ascii_upcase):\n    Port: \(.value.host_port // "internal"):\(.value.container_port)\n    URL: \(.value.url)\n    Purpose: \(.value.purpose)\n"' "$PORTS_FILE" 2>/dev/null || echo "  Error parsing production config"

echo ""
echo -e "${YELLOW}🔒 Reserved Ports${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
yq eval '.reserved_ports[] | "  Port \(.port): \(.reserved_for) (\(.status))"' "$PORTS_FILE" 2>/dev/null || echo "  No reserved ports"

echo ""
echo -e "${GREEN}💡 Quick Access URLs${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Local Frontend:    http://localhost:3001"
echo "  Local Backend:     http://localhost:3000"
echo "  Local RedisInsight: http://localhost:8001"
echo ""
echo "  Prod Frontend:     http://$SERVER_IP"
echo "  Prod Backend:      http://$SERVER_IP:3000"
echo "  Prod RedisInsight: http://$SERVER_IP:8001"
echo ""

