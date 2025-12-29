#!/bin/bash

# Setup Crontab for Auto-stop
# This script adds crontab entry to stop dev/pre-prod at 11:50 PM

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CRON_LOG="$PROJECT_ROOT/aws/logs/cron.log"
AUTO_STOP_SCRIPT="$PROJECT_ROOT/aws/utils/auto-stop.sh"

echo "⏰ Setting up Crontab for Auto-stop..."
echo ""

# Create log file if it doesn't exist
touch "$CRON_LOG"

# Check if entry already exists
if crontab -l 2>/dev/null | grep -q "auto-stop.sh"; then
  echo "ℹ️  Crontab entry already exists"
  echo ""
  echo "Current crontab entries:"
  crontab -l | grep -A 1 -B 1 "auto-stop"
  echo ""
  read -p "Do you want to update it? (y/N): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Crontab update cancelled"
    exit 0
  fi
  # Remove old entry
  crontab -l 2>/dev/null | grep -v "auto-stop.sh" | crontab -
fi

# Add new crontab entry
echo "📝 Adding crontab entry..."
AUTO_STOP_SCRIPT_ABS="$PROJECT_ROOT/aws/utils/auto-stop.sh"
(crontab -l 2>/dev/null; echo ""; echo "# MERN Stack - Auto-stop dev and pre-prod environments at 11:50 PM daily"; echo "50 23 * * * $AUTO_STOP_SCRIPT_ABS >> $CRON_LOG 2>&1") | crontab -

if [ $? -eq 0 ]; then
  echo "✅ Crontab entry added successfully!"
  echo ""
  echo "📋 Current crontab:"
  crontab -l
  echo ""
  echo "📝 Log file: $CRON_LOG"
  echo ""
  echo "💡 To view logs: tail -f $CRON_LOG"
  echo "💡 To remove: crontab -e (then delete the line)"
else
  echo "❌ Failed to add crontab entry"
  exit 1
fi

