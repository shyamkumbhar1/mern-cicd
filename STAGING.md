# Staging Environments Setup

Complete staging setup for MERN Stack with Local, Dev, Pre-prod, and Production environments on the same AWS instance.

## 📋 Environments Overview

| Environment | Server Path | Frontend Port | Backend Port | RedisInsight | Database |
|-------------|-------------|---------------|--------------|-------------|----------|
| **Local** | Local machine | 3001 | 3000 | 8001 | basic-crud-dev |
| **Dev** | ~/MERN-dev | 3001 | 3000 | 8001 | basic-crud-dev |
| **Pre-prod** | ~/MERN-preprod | 8080 | 4000 | 8002 | basic-crud-staging |
| **Production** | ~/MERN-prod | 80 | 3000 | 8001 | basic-crud |

## 🚀 Deployment Commands

### Deploy to Dev Environment
```bash
./aws/deploy-dev.sh
```
**Access URLs:**
- Frontend: http://51.21.127.4:3001
- Backend: http://51.21.127.4:3000
- RedisInsight: http://51.21.127.4:8001

### Deploy to Pre-prod Environment
```bash
./aws/deploy-preprod.sh
```
**Access URLs:**
- Frontend: http://51.21.127.4:8080
- Backend: http://51.21.127.4:4000
- RedisInsight: http://51.21.127.4:8002

### Deploy to Production Environment
```bash
./aws/deploy.sh
# or
./aws/deploy-prod.sh  # (if renamed)
```
**Access URLs:**
- Frontend: http://51.21.127.4
- Backend: http://51.21.127.4:3000
- RedisInsight: http://51.21.127.4:8001

## 📁 File Structure

```
MERN/
├── docker/
│   ├── docker-compose.yml          # Local development
│   ├── docker-compose.dev.yml      # Dev environment
│   ├── docker-compose.preprod.yml  # Pre-prod environment
│   ├── docker-compose.prod.yml      # Production environment
│   └── ports.yml                    # Port configuration
│
├── .env.dev                        # Dev environment variables
├── .env.preprod                    # Pre-prod environment variables
├── .env.production                 # Production environment variables
│
└── aws/
    ├── deploy-dev.sh               # Deploy to Dev
    ├── deploy-preprod.sh           # Deploy to Pre-prod
    ├── deploy.sh                   # Deploy to Production
    └── config.sh                   # Shared configuration
```

## 🔧 Environment Configuration

### Dev Environment
- **NODE_ENV:** development
- **Database:** basic-crud-dev
- **Hot Reload:** Enabled
- **Volumes:** Mounted for live code changes

### Pre-prod Environment
- **NODE_ENV:** staging
- **Database:** basic-crud-staging
- **Hot Reload:** Disabled
- **Production-like:** Optimized build

### Production Environment
- **NODE_ENV:** production
- **Database:** basic-crud
- **Hot Reload:** Disabled
- **Optimized:** Full production build

## 🔐 Container Names

Each environment has unique container names to avoid conflicts:

**Dev:**
- mern-frontend-dev
- mern-backend-dev
- mern-redis-dev
- mern-redisinsight-dev

**Pre-prod:**
- mern-frontend-preprod
- mern-backend-preprod
- mern-redis-preprod
- mern-redisinsight-preprod

**Production:**
- mern-frontend
- mern-backend
- mern-redis
- mern-redisinsight

## 🔌 Port Management

All ports are documented in `docker/ports.yml`. View ports:
```bash
./docker/show-ports.sh
```

### Port Allocation
- **3000:** Backend (Dev, Production)
- **3001:** Frontend (Local, Dev)
- **4000:** Backend (Pre-prod)
- **6379:** Redis (Local, Dev)
- **6380:** Redis (Pre-prod)
- **8001:** RedisInsight (Local, Dev, Production)
- **8002:** RedisInsight (Pre-prod)
- **8080:** Frontend (Pre-prod)
- **80:** Frontend (Production)

## 📊 Database Setup

Each environment uses a separate MongoDB database:

1. **Dev:** `basic-crud-dev`
2. **Pre-prod:** `basic-crud-staging`
3. **Production:** `basic-crud`

**Note:** Create these databases in MongoDB Atlas before deployment.

## 🛠️ Management Commands

### View Logs
```bash
# Dev
ssh -i server-practic.pem ubuntu@51.21.127.4
cd ~/MERN-dev
docker-compose -f docker/docker-compose.dev.yml logs -f

# Pre-prod
cd ~/MERN-preprod
docker-compose -f docker/docker-compose.preprod.yml logs -f

# Production
cd ~/MERN-prod
docker-compose -f docker/docker-compose.prod.yml logs -f
```

### Restart Services
```bash
# Dev
cd ~/MERN-dev && docker-compose -f docker/docker-compose.dev.yml restart

# Pre-prod
cd ~/MERN-preprod && docker-compose -f docker/docker-compose.preprod.yml restart

# Production
cd ~/MERN-prod && docker-compose -f docker/docker-compose.prod.yml restart
```

### Stop Services
```bash
# Dev
cd ~/MERN-dev && docker-compose -f docker/docker-compose.dev.yml down

# Pre-prod
cd ~/MERN-preprod && docker-compose -f docker/docker-compose.preprod.yml down

# Production
cd ~/MERN-prod && docker-compose -f docker/docker-compose.prod.yml down
```

## 🔒 Security Group Ports

Ensure these ports are open in AWS Security Group:

- **22:** SSH
- **80:** Production Frontend
- **3000:** Backend (Dev, Production)
- **3001:** Dev Frontend
- **4000:** Pre-prod Backend
- **8080:** Pre-prod Frontend
- **8001:** RedisInsight (Dev, Production)
- **8002:** Pre-prod RedisInsight

## 📝 Deployment Workflow

1. **Develop Locally**
   ```bash
   docker-compose -f docker/docker-compose.yml up
   ```

2. **Deploy to Dev**
   ```bash
   ./aws/deploy-dev.sh
   ```

3. **Test in Pre-prod**
   ```bash
   ./aws/deploy-preprod.sh
   ```

4. **Deploy to Production**
   ```bash
   ./aws/deploy.sh
   ```

## ⚠️ Important Notes

1. **Port Conflicts:** Each environment uses unique ports
2. **Container Names:** Unique names prevent conflicts
3. **Database Isolation:** Separate databases for each environment
4. **Same Server:** All environments run on the same AWS instance
5. **Environment Files:** `.env.dev`, `.env.preprod`, `.env.production` are created on server

## 🐛 Troubleshooting

### Port Already in Use
```bash
# Check what's using the port
sudo lsof -i :3000
sudo lsof -i :4000

# Stop conflicting containers
docker ps
docker stop <container-name>
```

### Container Name Conflicts
```bash
# List all containers
docker ps -a

# Remove old containers
docker rm <container-name>
```

### Database Connection Issues
- Verify database names in MongoDB Atlas
- Check `.env` files on server
- Verify network access in Atlas

---

**Last Updated:** December 2025

