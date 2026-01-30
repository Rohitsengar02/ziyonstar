const express = require('express');
const router = express.Router();
const reviewController = require('../controllers/reviewController');

router.get('/technician/:technicianId', reviewController.getTechnicianReviews);
router.get('/technician/:technicianId/latest', reviewController.getLatestReview);

module.exports = router;
