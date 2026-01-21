const express = require('express');
const router = express.Router();
const commissionController = require('../controllers/commissionController');

// Admin Routes
router.post('/', commissionController.setCommission); // Create or Update
router.get('/', commissionController.getCommissions);
router.get('/:category', commissionController.getCommissionByCategory);
router.delete('/:id', commissionController.deleteCommission);

module.exports = router;
