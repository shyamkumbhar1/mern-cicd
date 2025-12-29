# MERN Stack CRUD Application

Complete MERN Stack application with Docker support for local development and AWS deployment.

## 🚀 Features

- ✅ Full CRUD operations (Create, Read, Update, Delete)
- ✅ MongoDB Atlas integration
- ✅ Docker Compose for local development
- ✅ Production-ready Docker setup
- ✅ One-command AWS deployment
- ✅ React frontend with modern UI
- ✅ Express.js REST API backend

## 📁 Project Structure

```
MERN/
├── backend/           # Node.js/Express backend
│   ├── src/
│   │   └── server.js
│   ├── package.json
│   └── Dockerfile
├── frontend/          # React frontend
│   ├── src/
│   ├── public/
│   ├── package.json
│   ├── Dockerfile
│   └── nginx.conf
├── docker/
│   ├── docker-compose.yml      # Local development
│   ├── docker-compose.prod.yml # Production (AWS)
│   ├── ports.yml               # Port configuration reference
│   ├── PORTS.md                # Port documentation
│   └── show-ports.sh           # Port display script
├── aws/                        # AWS deployment scripts
│   ├── config.sh
│   ├── deploy.sh
│   └── ...
├── .env                        # Local environment
└── .env.production             # Production environment
```

## 🛠️ Local Development

### Prerequisites
- Docker and Docker Compose installed
- Node.js 18+ (optional, for local development)

### Setup

1. **Clone or navigate to project:**
   ```bash
   cd /home/india/shared/solominds/MERN
   ```

2. **Create `.env` file** (already created with MongoDB Atlas connection):
   ```bash
   # .env file is already configured
   ```

3. **Start services:**
   ```bash
   docker-compose up -d
   ```

4. **Access application:**
   - Frontend: http://localhost:3001
   - Backend API: http://localhost:3000
   - Health Check: http://localhost:3000/health
   - RedisInsight: http://localhost:8001

5. **View port configuration:**
   ```bash
   ./docker/show-ports.sh
   # Or check: docker/ports.yml or docker/PORTS.md
   ```

### Development Commands

```bash
# Start services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down

# Rebuild after changes
docker-compose up -d --build

# View specific service logs
docker-compose logs -f backend
docker-compose logs -f frontend
```

## ☁️ AWS Deployment

### Prerequisites
- AWS EC2 instance running
- EC2 instance public IP
- SSH key file
- AWS CLI configured (optional, for automatic port opening)

### Quick Deploy

1. **Make deploy script executable:**
   ```bash
   chmod +x deploy.sh
   ```

2. **Run deployment:**
   ```bash
   ./deploy.sh
   ```

The script will:
- ✅ Transfer project to EC2
- ✅ Install Docker (if needed)
- ✅ Build and start containers
- ✅ Open security group ports
- ✅ Deploy application

### Manual Deployment

If you prefer manual steps:

1. **Transfer project:**
   ```bash
   scp -i server-practic.pem -r /home/india/shared/solominds/MERN ubuntu@51.21.127.4:~/
   ```

2. **SSH into EC2:**
   ```bash
   ssh -i server-practic.pem ubuntu@51.21.127.4
   ```

3. **Setup on EC2:**
   ```bash
   cd ~/MERN
   sudo apt update
   sudo apt install -y docker.io docker-compose
   sudo systemctl start docker
   sudo usermod -aG docker ubuntu
   ```

4. **Start services:**
   ```bash
   docker-compose -f docker-compose.prod.yml up -d --build
   ```

5. **Open ports in Security Group:**
   - Port 80 (HTTP) - Frontend
   - Port 3000 (Custom TCP) - Backend API
   - Port 8001 (Custom TCP) - RedisInsight UI

## 🔌 Port Configuration

All ports are documented in `docker/ports.yml` and `docker/PORTS.md`.

### Quick Port Reference

**Local Development:**
- Frontend: `3001` → http://localhost:3001
- Backend: `3000` → http://localhost:3000
- Redis: `6379` → redis://localhost:6379
- RedisInsight: `8001` → http://localhost:8001

**Production (AWS):**
- Frontend: `80` → http://51.21.127.4
- Backend: `3000` → http://51.21.127.4:3000
- RedisInsight: `8001` → http://51.21.127.4:8001
- Redis: Internal only (not exposed)

**View all ports:**
```bash
./docker/show-ports.sh
cat docker/PORTS.md
```

## 📊 Database

- **Database Name:** basic-crud
- **Provider:** MongoDB Atlas
- **Connection:** Configured in `.env` and `.env.production`

## 🔧 Configuration

### Environment Variables

**Local (.env):**
```env
MONGO_URI=mongodb+srv://user:pass@cluster.mongodb.net/basic-crud?retryWrites=true&w=majority
NODE_ENV=development
PORT=3000
REACT_APP_API_URL=http://localhost:3000
```

**Production (.env.production):**
```env
MONGO_URI=mongodb+srv://user:pass@cluster.mongodb.net/basic-crud?retryWrites=true&w=majority
NODE_ENV=production
PORT=3000
REACT_APP_API_URL=http://51.21.127.4:3000
```

## 📝 API Endpoints

- `GET /health` - Health check
- `GET /api/items` - Get all items
- `GET /api/items/:id` - Get single item
- `POST /api/items` - Create item
- `PUT /api/items/:id` - Update item
- `DELETE /api/items/:id` - Delete item

## 🐛 Troubleshooting

### Local Development

**Port already in use:**
```bash
# Find process using port
sudo lsof -i :3000
sudo lsof -i :3001

# Kill process
sudo kill -9 <PID>
```

**Docker issues:**
```bash
# Clean up
docker-compose down -v
docker system prune -a
```

### AWS Deployment

**Connection refused:**
- Check security group ports (80, 3000)
- Verify containers are running: `docker ps`
- Check logs: `docker-compose -f docker-compose.prod.yml logs`

**MongoDB connection error:**
- Verify MongoDB Atlas connection string
- Check network access in Atlas (allow 0.0.0.0/0 for testing)
- Verify database name is correct

**Container not starting:**
```bash
# Check logs
docker-compose -f docker-compose.prod.yml logs backend
docker-compose -f docker-compose.prod.yml logs frontend

# Restart containers
docker-compose -f docker-compose.prod.yml restart
```

## 📚 Tech Stack

- **Frontend:** React 18
- **Backend:** Node.js, Express.js
- **Database:** MongoDB Atlas
- **Containerization:** Docker, Docker Compose
- **Web Server:** Nginx (production)
- **Deployment:** AWS EC2

## 🎯 Next Steps

1. ✅ Local development setup complete
2. ✅ AWS deployment ready
3. 🔄 Add authentication (JWT)
4. 🔄 Add file upload
5. 🔄 Add pagination
6. 🔄 Add search/filter

## 📞 Support

For issues or questions:
- Check logs: `docker-compose logs`
- Verify environment variables
- Check MongoDB Atlas connection
- Verify security group settings

---

**Happy Coding! 🚀**

