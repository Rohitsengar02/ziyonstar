const express = require('express');
const router = express.Router();
const analyticsController = require('../controllers/analyticsController');

// Get Dashboard Analytics
router.get('/', analyticsController.getDashboardStats);

module.exports = router;
