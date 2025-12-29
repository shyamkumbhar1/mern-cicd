# RedisInsight Automatic Database Setup

## Overview

The system attempts to automatically configure RedisInsight to connect to Redis database when the container starts.

## How It Works

1. **Init Script**: `docker/scripts/redisinsight-init.sh` runs automatically when RedisInsight container starts
2. **Retry Logic**: Script waits up to 60 seconds for RedisInsight API to be ready
3. **Auto-Configuration**: If API is accessible, database connection is added automatically
4. **Fallback**: If automatic setup fails, you can add database manually (one-time setup)

## Manual Setup (If Automatic Fails)

If automatic setup doesn't work, follow these steps:

### Step 1: Open RedisInsight
```
http://localhost:8001
```

### Step 2: Add Database
1. Click **"Add Database"** button
2. Enter connection details:
   - **Host**: `redis` (container name) or `localhost`
   - **Port**: `6379`
   - **Name**: `MERN Redis` (optional)
3. Click **"Add Redis Database"**

### Step 3: Verify
- Database should appear in the list
- You can click on it to view keys and data

## Troubleshooting

### API Not Ready
If you see "API not ready" messages:
- RedisInsight takes time to fully initialize
- Wait 30-60 seconds after container starts
- Check logs: `docker logs mern-redisinsight`

### Database Already Exists
If database already exists:
- Script will detect and skip
- No action needed

### Manual Setup Required
If automatic setup fails:
- This is a **one-time setup**
- Configuration is saved in `redisinsight-data` volume
- It will persist across container restarts

## Environment-Specific Names

- **Local**: `MERN Redis`
- **Dev**: `MERN Redis (Dev)`
- **Pre-Prod**: `MERN Redis (Pre-Prod)`
- **Production**: `MERN Redis (Production)`

## Testing

To test the init script manually:
```bash
docker exec mern-redisinsight sh /init.sh
```

## Notes

- Configuration is persisted in Docker volume
- One-time manual setup is acceptable if automatic setup fails
- Script runs in background and doesn't block RedisInsight startup

---

**Last Updated**: December 2025

