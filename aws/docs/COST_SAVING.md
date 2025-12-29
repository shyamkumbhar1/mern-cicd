# Cost Saving Guide

Complete guide for reducing AWS and infrastructure costs for MERN Stack deployment.

## 💰 Cost Saving Measures Implemented

### 1. ✅ Resource Limits
- **Dev Environment:** Limited CPU (0.5) and Memory (512MB) per container
- **Pre-prod Environment:** Limited CPU (0.75) and Memory (768MB) per container
- **Savings:** Prevents resource waste, allows more efficient instance usage

### 2. ✅ Start/Stop Scripts
- **Scripts Created:**
  - `aws/start-dev.sh` - Start dev environment
  - `aws/stop-dev.sh` - Stop dev environment
  - `aws/start-preprod.sh` - Start pre-prod environment
  - `aws/stop-preprod.sh` - Stop pre-prod environment
- **Usage:**
  ```bash
  ./aws/stop-dev.sh      # Stop when not in use
  ./aws/start-dev.sh     # Start when needed
  ```

### 3. ✅ Cost Monitoring
- **Script:** `aws/cost-check.sh`
- **Usage:**
  ```bash
  ./aws/cost-check.sh
  ```
- **Shows:**
  - Current month's cost
  - Estimated monthly cost
  - Cost breakdown by service

### 4. ✅ Cleanup Script
- **Script:** `aws/cleanup.sh`
- **Usage:**
  ```bash
  ./aws/cleanup.sh
  ```
- **Removes:**
  - Unused Docker images
  - Stopped containers
  - Unused volumes
  - Unused networks

### 5. ✅ Auto-stop Script
- **Script:** `aws/auto-stop.sh`
- **For Cron Jobs:** Automatically stop environments at specified times

---

## 📊 Resource Limits Configuration

### Dev Environment Limits:
- **Backend:** 0.5 CPU, 512MB RAM
- **Frontend:** 0.25 CPU, 256MB RAM
- **Redis:** 0.25 CPU, 256MB RAM

### Pre-prod Environment Limits:
- **Backend:** 0.75 CPU, 768MB RAM
- **Frontend:** 0.25 CPU, 256MB RAM
- **Redis:** 0.25 CPU, 256MB RAM

**Total Dev Resources:** ~1 CPU, ~1GB RAM
**Total Pre-prod Resources:** ~1.25 CPU, ~1.25GB RAM

---

## 🕐 Automated Cost Saving (Cron Jobs)

### Setup Auto-stop at Night:

```bash
# Edit crontab
crontab -e

# Add these lines:
# Stop dev/pre-prod at 9 PM daily
0 21 * * * /home/india/shared/solominds/MERN/aws/auto-stop.sh

# Start dev at 9 AM on weekdays only
0 9 * * 1-5 /home/india/shared/solominds/MERN/aws/start-dev.sh
```

**Savings:** ~12 hours/day × 30 days = ~360 hours/month saved
**Estimated:** ~$5-10/month savings

---

## 💡 Additional Cost Saving Tips

### 1. Instance Right-sizing
```bash
# Check current instance type
aws ec2 describe-instances --query "Reservations[*].Instances[*].[InstanceType]"

# Options:
# t3.micro   - $7-8/month  (1 vCPU, 1GB) - Good for dev only
# t3.small   - $15/month   (2 vCPU, 2GB) - Good for small prod
# t3.medium  - $30/month   (2 vCPU, 4GB) - Current
```

**Action:** If using t3.medium, consider downgrading to t3.small if resources allow.

### 2. Reserved Instances
- **On-demand:** $30/month
- **Reserved (1 year):** ~$20/month (33% savings)
- **Reserved (3 years):** ~$15/month (50% savings)

**Best for:** Long-term projects (1+ years)

### 3. MongoDB Atlas Optimization
- **Dev:** Use Free Tier (M0) - $0/month
- **Pre-prod:** Use M2 Shared - $9/month (only when testing)
- **Production:** Use M10 - $57/month (only when needed)

**Current:** If using M10 for all, switch dev to M0
**Savings:** ~$48/month

### 4. Stop Environments on Weekends
```bash
# Add to crontab
# Stop on Friday 6 PM
0 18 * * 5 /home/india/shared/solominds/MERN/aws/auto-stop.sh

# Start on Monday 9 AM
0 9 * * 1 /home/india/shared/solominds/MERN/aws/start-dev.sh
```

**Savings:** ~48 hours/week × 4 weeks = ~192 hours/month
**Estimated:** ~$3-5/month savings

### 5. Use Spot Instances (Advanced)
- **On-demand:** $30/month
- **Spot:** ~$10-15/month (60-70% savings)
- **Risk:** Can be terminated, but good for dev/pre-prod

---

## 📈 Estimated Savings

| Action | Current | After | Monthly Savings |
|--------|---------|-------|-----------------|
| Resource Limits | - | - | ~$2-3 |
| Auto-stop (12hrs/day) | - | - | ~$5-10 |
| Weekend Stop | - | - | ~$3-5 |
| Right-size Instance | $30 | $15 | ~$15 |
| Reserved Instance | $30 | $20 | ~$10 |
| MongoDB Dev to M0 | $57 | $9 | ~$48 |
| **Total Potential** | **$87** | **$44** | **~$43/month (50%)** |

---

## 🛠️ Quick Commands

### Daily Operations:
```bash
# Check costs
./aws/cost-check.sh

# Stop dev when done
./aws/stop-dev.sh

# Start dev when needed
./aws/start-dev.sh

# Cleanup unused resources
./aws/cleanup.sh
```

### Weekly Operations:
```bash
# Full cleanup
./aws/cleanup.sh

# Check costs
./aws/cost-check.sh
```

---

## 📋 Cost Monitoring Schedule

### Daily:
- Check costs: `./aws/cost-check.sh`
- Stop unused environments: `./aws/stop-dev.sh`

### Weekly:
- Full cleanup: `./aws/cleanup.sh`
- Review costs and optimize

### Monthly:
- Review instance size
- Check Reserved Instance options
- Optimize MongoDB tiers

---

## ⚠️ Important Notes

1. **Production:** Never stop production environment
2. **Backups:** Ensure backups before cleanup
3. **Monitoring:** Monitor costs regularly
4. **Testing:** Test stop/start scripts before automation

---

## 🔗 Related Files

- `aws/start-dev.sh` - Start dev environment
- `aws/stop-dev.sh` - Stop dev environment
- `aws/start-preprod.sh` - Start pre-prod environment
- `aws/stop-preprod.sh` - Stop pre-prod environment
- `aws/cost-check.sh` - Check AWS costs
- `aws/cleanup.sh` - Cleanup Docker resources
- `aws/auto-stop.sh` - Auto-stop for cron jobs

---

**Last Updated:** December 2025

