# AWS Folder Structure

Organized structure for AWS deployment and management scripts.

## 📁 Folder Structure

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

## 🚀 Usage

### Deployment:
```bash
# Production
./aws/deploy/deploy.sh

# Dev
./aws/deploy/deploy-dev.sh

# Pre-prod
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

# Quick Update
./aws/manage/update.sh
```

### Utilities:
```bash
# Cost monitoring
./aws/utils/cost-check.sh

# Cleanup
./aws/utils/cleanup.sh

# Fix Security Group
./aws/utils/fix-security-group.sh

# Fix Redis
./aws/utils/fix-redis-cache.sh

# Setup cron
./aws/utils/setup-cron.sh
```

## 📝 Notes

- All scripts load `config.sh` from parent directory (`../config.sh`)
- Scripts maintain backward compatibility
- Logs are stored in `logs/` folder
- Documentation in `docs/` folder

---

**Last Updated:** December 2025

