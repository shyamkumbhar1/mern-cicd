# Docker Folder Structure

Organized structure for Docker configuration files.

## 📁 Folder Structure

```
docker/
├── compose/                      # Docker Compose files
│   ├── docker-compose.yml       # Local development
│   ├── docker-compose.dev.yml   # Dev environment
│   ├── docker-compose.preprod.yml # Pre-prod environment
│   └── docker-compose.prod.yml  # Production environment
│
├── dockerfiles/                  # Dockerfiles
│   ├── Dockerfile.backend       # Backend Dockerfile
│   └── Dockerfile.frontend      # Frontend Dockerfile
│
├── config/                       # Configuration files
│   ├── nginx.conf               # Nginx configuration
│   └── ports.yml                # Port configuration
│
├── scripts/                      # Utility scripts
│   ├── show-ports.sh            # Display port configuration
│   └── redisinsight-init.sh     # RedisInsight initialization
│
└── docs/                         # Documentation
    └── PORTS.md                 # Port documentation
```

## 🚀 Usage

### Local Development:
```bash
docker-compose -f docker/compose/docker-compose.yml up -d
```

### Dev Environment:
```bash
docker-compose -f docker/compose/docker-compose.dev.yml up -d
```

### Pre-prod Environment:
```bash
docker-compose -f docker/compose/docker-compose.preprod.yml up -d
```

### Production:
```bash
docker-compose -f docker/compose/docker-compose.prod.yml up -d
```

## 📝 Path References

### Docker Compose Files:
- **Dockerfile paths:** `../dockerfiles/Dockerfile.backend` or `dockerfiles/Dockerfile.frontend`
- **Context paths:** `../backend` or `..` (project root)

### Scripts:
- **Ports file:** `../config/ports.yml`
- **Show ports:** `./scripts/show-ports.sh`

### Dockerfiles:
- **Nginx config:** `docker/config/nginx.conf` (from project root)

## 🔧 Configuration

### Ports:
- **Local:** Frontend: 3001, Backend: 3000, RedisInsight: 8001
- **Dev:** Frontend: 3001, Backend: 3000, RedisInsight: 8001
- **Pre-prod:** Frontend: 8080, Backend: 4000, RedisInsight: 8002
- **Production:** Frontend: 80, Backend: 3000, RedisInsight: 8001

### Services:
- **Backend:** Node.js API with Redis caching
- **Frontend:** React app with Nginx
- **Redis:** Cache store
- **RedisInsight:** Redis UI management

## 📋 Notes

- All compose files use relative paths from project root
- Dockerfiles are referenced from compose file location
- Scripts use relative paths to config files
- Environment-specific configs in `.env.dev`, `.env.preprod`, `.env.production`

---

**Last Updated:** December 2025

