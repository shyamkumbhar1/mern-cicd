# Port Configuration Reference

Quick reference guide for all ports used in the MERN Stack application.

## 📍 Local Development

| Service | Host Port | Container Port | URL | Purpose |
|---------|-----------|----------------|-----|---------|
| **Frontend** | 3001 | 80 | http://localhost:3001 | React Application |
| **Backend** | 3000 | 3000 | http://localhost:3000 | Node.js API Server |
| **Redis** | 6379 | 6379 | redis://localhost:6379 | Redis Cache |
| **RedisInsight** | 8001 | 5540 | http://localhost:8001 | Redis Management UI |

### Local Access:
- Frontend: http://localhost:3001
- Backend API: http://localhost:3000
- Health Check: http://localhost:3000/health
- RedisInsight: http://localhost:8001

---

## ☁️ Production Environment (AWS)

**Server IP:** `51.21.127.4`

| Service | Host Port | Container Port | URL | Purpose |
|---------|-----------|----------------|-----|---------|
| **Frontend** | 80 | 80 | http://51.21.127.4 | React Application (Production) |
| **Backend** | 3000 | 3000 | http://51.21.127.4:3000 | Node.js API Server (Production) |
| **Redis** | - | 6379 | redis://redis:6379 | Redis Cache (Internal Only) |
| **RedisInsight** | 8001 | 5540 | http://51.21.127.4:8001 | Redis Management UI |

### Production Access:
- Frontend: http://51.21.127.4
- Backend API: http://51.21.127.4:3000
- Health Check: http://51.21.127.4:3000/health
- RedisInsight: http://51.21.127.4:8001

**Note:** Redis is not exposed externally in production. It's only accessible within the Docker network.

---

## 🔒 Reserved Ports

These ports are reserved for future projects:

| Port | Reserved For | Status |
|------|--------------|--------|
| 8080 | Future - E-commerce Frontend | Available |
| 4000 | Future - Blog App Backend | Available |
| 5000 | Future - Admin Panel | Available |
| 8002 | Future - RedisInsight (E-commerce) | Available |
| 8003 | Future - RedisInsight (Blog App) | Available |

---

## 🔐 Security Group Ports (AWS)

The following ports need to be open in AWS Security Group:

| Port | Protocol | Description | Source |
|------|----------|-------------|--------|
| 80 | TCP | Frontend HTTP | 0.0.0.0/0 |
| 3000 | TCP | Backend API | 0.0.0.0/0 |
| 8001 | TCP | RedisInsight UI | 0.0.0.0/0 |
| 22 | TCP | SSH Access | 0.0.0.0/0 |

---

## 📝 Port Usage Summary

### Port 80
- **Used by:** Production Frontend
- **Description:** Standard HTTP port
- **Environments:** Production only

### Port 3000
- **Used by:** Backend API (all environments)
- **Description:** Node.js backend server
- **Environments:** Local, Production

### Port 3001
- **Used by:** Local Frontend
- **Description:** Frontend development port
- **Environments:** Local only

### Port 6379
- **Used by:** Redis Cache
- **Description:** Redis default port
- **Environments:** Local (exposed), Production (internal only)

### Port 8001
- **Used by:** RedisInsight UI
- **Description:** Redis management interface
- **Environments:** Local, Production

---

## 🛠️ How to View Ports

### Using the helper script:
```bash
./docker/show-ports.sh
```

### View ports.yml directly:
```bash
cat docker/ports.yml
```

### Check running containers:
```bash
docker ps --format "table {{.Names}}\t{{.Ports}}"
```

---

## ⚠️ Important Notes

1. **Port Conflicts:** Always check `ports.yml` before using a new port
2. **Security:** Only expose necessary ports in production
3. **Redis:** Keep Redis internal in production (not exposed externally)
4. **Reserved Ports:** Don't use reserved ports for new services

---

## 📚 Related Files

- `docker/ports.yml` - Machine-readable port configuration (YAML)
- `docker/show-ports.sh` - Script to display ports
- `docker/docker-compose.yml` - Local development ports
- `docker/docker-compose.prod.yml` - Production ports

---

**Last Updated:** December 2025

