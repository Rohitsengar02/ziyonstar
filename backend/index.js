const express = require('express');
const connectDB = require('./config/db');
require('dotenv').config();

const app = express();

// Connect Database
connectDB();

const cors = require('cors');
app.use(cors({
    origin: '*',
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With', 'access-control-request-private-network'],
    credentials: true,
}));

// Nominatim Proxy to fix CORS issues on Flutter Web
const axios = require('axios');
app.get('/api/location/reverse', async (req, res) => {
    try {
        const { lat, lon } = req.query;
        if (!lat || !lon) {
            return res.status(400).json({ success: false, message: 'Latitude and longitude are required' });
        }

        console.log(`[PROXY] Reverse geocoding for ${lat}, ${lon}`);
        const response = await axios.get(`https://nominatim.openstreetmap.org/reverse?format=json&lat=${lat}&lon=${lon}&zoom=18&addressdetails=1`, {
            headers: { 'User-Agent': 'ZiyonStarApp/1.0' },
            timeout: 10000
        });

        res.json(response.data);
    } catch (error) {
        console.error('[PROXY ERROR]', error.message);
        res.status(500).json({ success: false, message: 'Failed to fetch address from Nominatim', error: error.message });
    }
});

app.get('/api/location/search', async (req, res) => {
    try {
        const { q } = req.query;
        if (!q) {
            return res.status(400).json({ success: false, message: 'Search query is required' });
        }

        console.log(`[PROXY] Searching for ${q}`);
        const response = await axios.get(`https://nominatim.openstreetmap.org/search?format=json&q=${encodeURIComponent(q)}&limit=5`, {
            headers: { 'User-Agent': 'ZiyonStarApp/1.0' },
            timeout: 10000
        });

        res.json(response.data);
    } catch (error) {
        console.error('[PROXY ERROR]', error.message);
        res.status(500).json({ success: false, message: 'Failed to search address from Nominatim', error: error.message });
    }
});

app.use(express.json());

// Request Logging Middleware
app.use((req, res, next) => {
    console.log(`${new Date().toISOString()} - ${req.method} ${req.url}`);
    next();
});

// Routes
app.use('/api/auth', require('./routes/authRoutes'));
app.use('/api/brands', require('./routes/brandRoutes'));
app.use('/api/models', require('./routes/modelRoutes'));
app.use('/api/issues', require('./routes/issueRoutes'));
app.use('/api/promos', require('./routes/promoRoutes'));
app.use('/api/commissions', require('./routes/commissionRoutes'));
app.use('/api/technicians', require('./routes/technicianRoutes'));
app.use('/api/users', require('./routes/userRoutes'));
app.use('/api/upload', require('./routes/uploadRoutes'));
app.use('/api/expertise', require('./routes/expertiseRoutes'));
app.use('/api/addresses', require('./routes/addressRoutes'));
app.use('/api/bookings', require('./routes/bookingRoutes'));
app.use('/api/notifications', require('./routes/notificationRoutes'));
app.use('/api/admin-notifications', require('./routes/adminNotificationRoutes'));
app.use('/api/disputes', require('./routes/disputeRoutes'));
app.use('/api/reviews', require('./routes/reviewRoutes'));
app.use('/api/contact', require('./routes/contactRoutes'));
app.use('/api/settings', require('./routes/settingsRoutes'));
app.use('/api/admin', require('./routes/adminRoutes'));
app.use('/api/analytics', require('./routes/analyticsRoutes'));
app.use('/api/chat', require('./routes/chatRoutes'));
app.use('/api/payments', require('./routes/paymentRoutes'));




app.get('/health', (req, res) => res.json({ status: 'ok', message: 'Backend is running' }));
app.get('/api/health', (req, res) => res.json({ status: 'ok', route: '/api/health' }));


const PORT = process.env.PORT || 5001;

const http = require('http');
const server = http.createServer(app);
const { Server } = require("socket.io");
const io = new Server(server, {
    cors: {
        origin: "*",
        methods: ["GET", "POST", "PUT", "DELETE"]
    }
});

// Store connected users for status management
const connectedUsers = new Map();

io.on('connection', (socket) => {
    console.log('A user connected:', socket.id);

    socket.on('register', (data) => {
        if (data.userId && data.role) {
            connectedUsers.set(socket.id, { userId: data.userId, role: data.role });
            console.log(`User registered: ${data.userId} as ${data.role}`);

            // Join a secure room for specific user notifications
            socket.join(data.userId);

            // If it's a technician, we could broadcast status here if needed
            if (data.role === 'technician') {
                io.emit('technicianStatusUpdate', { technicianId: data.userId, isOnline: true });
            }
        }
    });

    // Chat handlers
    socket.on('join_chat', (data) => {
        if (data.chatId) {
            socket.join(data.chatId);
            console.log(`Socket ${socket.id} joined chat: ${data.chatId}`);
        }
    });

    socket.on('send_message', (data) => {
        console.log('New message received via socket:', data);
        // data should have chatId, senderId, senderRole, text, createdAt
        if (data.chatId) {
            io.to(data.chatId).emit('receive_message', data);
        }
    });

    socket.on('disconnect', () => {
        const user = connectedUsers.get(socket.id);
        if (user) {
            console.log(`User disconnected: ${user.userId}`);
            if (user.role === 'technician') {
                io.emit('technicianStatusUpdate', { technicianId: user.userId, isOnline: false });
            }
            connectedUsers.delete(socket.id);
        }
    });
});

// Make io available globally for other routes/controllers
app.set('io', io);

server.listen(PORT, '0.0.0.0', () => console.log(`Server started on port ${PORT} bound to 0.0.0.0 with Socket.io enabled`));
