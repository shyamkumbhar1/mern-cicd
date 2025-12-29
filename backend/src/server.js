const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const redis = require('redis');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json());

// Redis Client
const redisClient = redis.createClient({
  socket: {
    host: process.env.REDIS_HOST || 'localhost',
    port: process.env.REDIS_PORT || 6379
  }
});

redisClient.on('error', (err) => console.error('❌ Redis Client Error:', err));
redisClient.on('connect', () => console.log('✅ Redis Connected'));

// Connect to Redis
(async () => {
  try {
    await redisClient.connect();
    console.log('✅ Redis Connected');
  } catch (error) {
    console.error('❌ Redis connection error:', error);
  }
})();

// MongoDB Atlas Connection
mongoose.connect(process.env.MONGO_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
.then(() => console.log('✅ MongoDB Atlas Connected - Database: basic-crud'))
.catch(err => console.error('❌ MongoDB connection error:', err));

// Model
const Item = mongoose.model('Item', new mongoose.Schema({
  name: String,
  description: String,
  createdAt: { type: Date, default: Date.now }
}));

// Cache helper functions
const getCache = async (key) => {
  try {
    // Check if Redis is connected
    if (!redisClient.isReady && !redisClient.isOpen) {
      return null;
    }
    const data = await redisClient.get(key);
    return data ? JSON.parse(data) : null;
  } catch (error) {
    console.error('Redis get error:', error);
    return null;
  }
};

const setCache = async (key, data, expiry = 3600) => {
  try {
    // Check if Redis is connected
    if (!redisClient.isReady && !redisClient.isOpen) {
      console.log('Redis not ready, skipping cache set');
      return;
    }
    await redisClient.setEx(key, expiry, JSON.stringify(data));
  } catch (error) {
    console.error('Redis set error:', error);
  }
};

const deleteCache = async (pattern) => {
  try {
    // Check if Redis is connected
    if (!redisClient.isReady && !redisClient.isOpen) {
      return;
    }
    const keys = await redisClient.keys(pattern);
    if (keys.length > 0) {
      await redisClient.del(keys);
    }
  } catch (error) {
    console.error('Redis delete error:', error);
  }
};

// Health check
app.get('/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    database: 'basic-crud',
    timestamp: new Date() 
  });
});

// GET all items (with caching)
app.get('/api/items', async (req, res) => {
  try {
    const cacheKey = 'items:all';
    
    // Check cache first
    const cachedData = await getCache(cacheKey);
    if (cachedData) {
      console.log('📦 Cache hit: items:all');
      return res.json(cachedData);
    }
    
    // If not in cache, fetch from database
    const items = await Item.find();
    
    // Store in cache for 1 hour
    await setCache(cacheKey, items, 3600);
    console.log('💾 Cache miss: items:all - stored in cache');
    
    res.json(items);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// GET single item (with caching)
app.get('/api/items/:id', async (req, res) => {
  try {
    const cacheKey = `items:${req.params.id}`;
    
    // Check cache
    const cachedData = await getCache(cacheKey);
    if (cachedData) {
      console.log(`📦 Cache hit: ${cacheKey}`);
      return res.json(cachedData);
    }
    
    // Fetch from database
    const item = await Item.findById(req.params.id);
    if (!item) {
      return res.status(404).json({ error: 'Item not found' });
    }
    
    // Store in cache
    await setCache(cacheKey, item, 3600);
    console.log(`💾 Cache miss: ${cacheKey} - stored in cache`);
    
    res.json(item);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// POST create item (invalidate cache)
app.post('/api/items', async (req, res) => {
  try {
    const item = new Item(req.body);
    await item.save();
    
    // Invalidate cache
    await deleteCache('items:*');
    console.log('🗑️  Cache invalidated: items:*');
    
    res.status(201).json(item);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// PUT update item (invalidate cache)
app.put('/api/items/:id', async (req, res) => {
  try {
    const item = await Item.findByIdAndUpdate(
      req.params.id, 
      req.body, 
      { new: true, runValidators: true }
    );
    if (!item) {
      return res.status(404).json({ error: 'Item not found' });
    }
    
    // Invalidate specific item and all items cache
    await deleteCache(`items:${req.params.id}`);
    await deleteCache('items:all');
    console.log('🗑️  Cache invalidated: items:*');
    
    res.json(item);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// DELETE item (invalidate cache)
app.delete('/api/items/:id', async (req, res) => {
  try {
    const item = await Item.findByIdAndDelete(req.params.id);
    if (!item) {
      return res.status(404).json({ error: 'Item not found' });
    }
    
    // Invalidate cache
    await deleteCache(`items:${req.params.id}`);
    await deleteCache('items:all');
    console.log('🗑️  Cache invalidated: items:*');
    
    res.json({ message: 'Item deleted successfully', item });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`📊 Database: basic-crud`);
  console.log(`🌐 Environment: ${process.env.NODE_ENV || 'development'}`);
});

