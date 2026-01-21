const express = require('express');
const router = express.Router();
const { upload } = require('../config/cloudinary');
const promoController = require('../controllers/promoController');

// Admin Routes (Should be protected in prod)
router.post('/', upload.single('image'), promoController.createPromo);
router.get('/', promoController.getPromos);
router.get('/:id', promoController.getPromoById);
router.put('/:id', upload.single('image'), promoController.updatePromo);
router.delete('/:id', promoController.deletePromo);

// Public/User Routes
router.post('/validate', promoController.validatePromo); // Check if code is valid

module.exports = router;
