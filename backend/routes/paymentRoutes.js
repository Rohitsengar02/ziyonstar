const express = require('express');
const router = express.Router();
const paymentController = require('../controllers/paymentController');

// Create payment order
router.post('/create-order', paymentController.createPaymentOrder);

// Check payment status
router.post('/check-status', paymentController.checkPaymentStatus);

// Webhook callback from UPIGateway
router.post('/webhook', paymentController.paymentWebhook);

module.exports = router;
