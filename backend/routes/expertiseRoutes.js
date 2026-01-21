const express = require('express');
const router = express.Router();
const expertiseController = require('../controllers/expertiseController');

// Submit request (technician)
router.post('/request', expertiseController.createRequest);

// Get all pending requests (admin)
router.get('/requests/pending', expertiseController.getPendingRequests);

// Get request detail (admin)
router.get('/requests/:id', expertiseController.getRequestById);

// Approve/Reject request (admin)
router.put('/requests/:id/status', expertiseController.updateRequestStatus);

module.exports = router;
