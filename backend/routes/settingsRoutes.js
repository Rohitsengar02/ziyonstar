const express = require('express');
const router = express.Router();
const settingsController = require('../controllers/settingsController');

// Get Info
router.get('/contact-info', settingsController.getCompanyInfo);

// Update Info (Protected usually, but simple for now)
router.put('/contact-info', settingsController.updateCompanyInfo);

module.exports = router;
