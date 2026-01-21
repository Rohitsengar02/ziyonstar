const express = require('express');
const connectDB = require('./config/db');
require('dotenv').config();

const app = express();

// Connect Database
connectDB();

// Middleware
app.use((req, res, next) => {
    const origin = req.headers.origin || '*';
    console.log(`[CORS DEBUG] ${req.method} ${req.url} - Origin: ${origin}`);

    res.setHeader('Access-Control-Allow-Origin', origin);
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With, access-control-request-private-network');
    res.setHeader('Access-Control-Allow-Credentials', 'true');

    // Private Network Access (PNA)
    if (req.headers['access-control-request-private-network']) {
        res.setHeader('Access-Control-Allow-Private-Network', 'true');
    }

    if (req.method === 'OPTIONS') {
        return res.sendStatus(200);
    }
    next();
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

const PORT = process.env.PORT || 5001;

app.listen(PORT, '0.0.0.0', () => console.log(`Server started on port ${PORT} bound to 0.0.0.0`));
