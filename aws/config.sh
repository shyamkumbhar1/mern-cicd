#!/bin/bash
# AWS Configuration - Shared by all AWS scripts
# This file contains all AWS-related configuration variables

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# EC2 Instance Details
export AWS_PUBLIC_IP="51.21.127.4"
export AWS_USER="ubuntu"

# Key file path (relative to project root)
export AWS_KEY_FILE="$PROJECT_ROOT/server-practic.pem"

# Project paths
export AWS_PROJECT_PATH="$PROJECT_ROOT"
export AWS_REMOTE_PATH="~/MERN"

# AWS CLI Configuration (optional - for Security Group management)
export AWS_REGION="us-east-1"  # Update if your instance is in a different region

# Helper function to check if key file exists
check_key_file() {
  if [ ! -f "$AWS_KEY_FILE" ]; then
    echo "❌ Key file not found: $AWS_KEY_FILE"
    echo "💡 Please ensure server-practic.pem is in the project root"
    exit 1
  fi
  chmod 400 "$AWS_KEY_FILE" 2>/dev/null || true
}

# Helper function to get absolute path
get_absolute_path() {
  cd "$(dirname "$1")" && pwd -P
}

