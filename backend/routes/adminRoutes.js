const express = require('express');
const router = express.Router();
const adminController = require('../controllers/adminController');
const { upload } = require('../config/cloudinary');

// Get Profile
router.get('/:id', adminController.getProfile);

// Update Profile (with or without image)
router.put('/:id', upload.single('image'), adminController.updateProfile);

// Change Password
router.put('/:id/password', adminController.changePassword);

module.exports = router;
