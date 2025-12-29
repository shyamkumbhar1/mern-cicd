# AWS Deployment Scripts

This folder contains all AWS-related deployment and maintenance scripts for the MERN Stack application.

## 📁 Structure

```
aws/
├── config.sh                    # Main configuration (shared by all scripts)
├── README.md                    # Main documentation
│
├── deploy/                      # Deployment scripts
│   ├── deploy.sh                # Production deployment
│   ├── deploy-dev.sh            # Dev environment deployment
│   └── deploy-preprod.sh        # Pre-prod environment deployment
│
├── manage/                      # Environment management scripts
│   ├── start-dev.sh             # Start dev environment
│   ├── stop-dev.sh              # Stop dev environment
│   ├── start-preprod.sh         # Start pre-prod environment
│   ├── stop-preprod.sh          # Stop pre-prod environment
│   └── update.sh                # Quick update (no rebuild)
│
├── utils/                       # Utility scripts
│   ├── fix-security-group.sh    # Fix Security Group ports
│   ├── fix-redis-cache.sh       # Fix Redis cache issues
│   ├── cleanup.sh               # Docker cleanup
│   ├── cost-check.sh            # AWS cost monitoring
│   ├── auto-stop.sh             # Auto-stop for cron jobs
│   └── setup-cron.sh            # Setup crontab
│
├── docs/                        # Documentation
│   └── COST_SAVING.md           # Cost saving guide
│
└── logs/                        # Logs
    └── cron.log                 # Cron job logs
```

## 🚀 Quick Start

All scripts should be run from the **project root** directory:

### Deployment:
```bash
# Production deployment
./aws/deploy/deploy.sh

# Dev deployment
./aws/deploy/deploy-dev.sh

# Pre-prod deployment
./aws/deploy/deploy-preprod.sh
```

### Management:
```bash
# Start/Stop Dev
./aws/manage/start-dev.sh
./aws/manage/stop-dev.sh

# Start/Stop Pre-prod
./aws/manage/start-preprod.sh
./aws/manage/stop-preprod.sh

# Quick update (no rebuild, fast)
./aws/manage/update.sh
```

### Utilities:
```bash
# Fix Security Group port 8001
./aws/utils/fix-security-group.sh

# Fix Redis cache issues
./aws/utils/fix-redis-cache.sh

# Cost monitoring
./aws/utils/cost-check.sh

# Cleanup
./aws/utils/cleanup.sh
```

## 📋 Scripts Overview

### 1. `deploy.sh` - Full Deployment
Complete deployment script that:
- Transfers project files to AWS EC2
- Installs Docker (if needed)
- Builds Docker containers
- Starts all services
- Opens Security Group ports (80, 3000, 8001)
- Verifies deployment

**Usage:**
```bash
./aws/deploy.sh
```

**Time:** ~5-10 minutes (first time), ~3-5 minutes (subsequent)

---

### 2. `update.sh` - Quick Update
Fast update script for code changes:
- Syncs changed files only
- Restarts containers (no rebuild)
- No Docker build step

**Usage:**
```bash
./aws/update.sh
```

**Time:** ~10-15 seconds

**When to use:**
- Small code changes
- Configuration updates
- Quick fixes

---

### 3. `fix-security-group.sh` - Security Group Fix
Opens port 8001 in AWS Security Group for RedisInsight access.

**Usage:**
```bash
./aws/fix-security-group.sh

# Or with Security Group ID
./aws/fix-security-group.sh sg-xxxxxxxxx
```

**Features:**
- Auto-detects Security Group
- Multiple fallback methods
- Manual input option
- Verification

---

### 4. `fix-redis-cache.sh` - Redis Cache Fix
Fixes Redis cache issues by:
- Checking Redis module installation
- Rebuilding backend container
- Verifying Redis connection
- Testing cache functionality

**Usage:**
```bash
./aws/fix-redis-cache.sh
```

---

## ⚙️ Configuration

All AWS configuration is centralized in `config.sh`:

```bash
# EC2 Instance Details
export AWS_PUBLIC_IP="51.21.127.4"
export AWS_USER="ubuntu"
export AWS_KEY_FILE="$PROJECT_ROOT/server-practic.pem"
export AWS_PROJECT_PATH="$PROJECT_ROOT"
export AWS_REMOTE_PATH="~/MERN"
export AWS_REGION="us-east-1"
```

**To update configuration:**
1. Edit `aws/config.sh`
2. All scripts will automatically use the new values

---

## 🔑 Prerequisites

1. **AWS EC2 Instance** running Ubuntu
2. **SSH Key File** (`server-practic.pem`) in project root
3. **AWS CLI** (optional, for Security Group management)
   ```bash
   aws configure
   ```

---

## 📝 Common Tasks

### Initial Deployment
```bash
./aws/deploy.sh
```

### Update Code
```bash
./aws/update.sh
```

### Check Logs
```bash
ssh -i server-practic.pem ubuntu@51.21.127.4
cd ~/MERN-prod
docker-compose -f docker/compose/docker-compose.prod.yml logs
```

### Restart Services
```bash
ssh -i server-practic.pem ubuntu@51.21.127.4
cd ~/MERN-prod
docker-compose -f docker/compose/docker-compose.prod.yml restart
```

### View Container Status
```bash
ssh -i server-practic.pem ubuntu@51.21.127.4
docker ps
```

---

## 🌐 Access URLs

After deployment, access your application at:

- **Frontend:** http://51.21.127.4
- **Backend API:** http://51.21.127.4:3000
- **Health Check:** http://51.21.127.4:3000/health
- **RedisInsight:** http://51.21.127.4:8001

---

## 🐛 Troubleshooting

### Deployment Fails
1. Check AWS instance is running
2. Verify SSH key permissions: `chmod 400 server-practic.pem`
3. Check Security Group allows SSH (port 22)
4. View logs: `ssh -i server-practic.pem ubuntu@51.21.127.4 'cd ~/MERN-prod && docker-compose -f docker/compose/docker-compose.prod.yml logs'`

### Port Not Accessible
1. Run: `./aws/fix-security-group.sh`
2. Or manually open ports in AWS Console:
   - Port 80 (Frontend)
   - Port 3000 (Backend)
   - Port 8001 (RedisInsight)

### Redis Cache Not Working
1. Run: `./aws/fix-redis-cache.sh`
2. Check Redis container: `docker ps | grep redis`
3. Check backend logs: `docker logs mern-backend | grep -i redis`

---

## 📚 Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)
- [MongoDB Atlas](https://www.mongodb.com/cloud/atlas)

---

## 🔒 Security Notes

- SSH key file (`server-practic.pem`) should have `400` permissions
- Never commit `.pem` files to Git
- Use environment variables for sensitive data
- Regularly update dependencies

---

**Last Updated:** December 2025

