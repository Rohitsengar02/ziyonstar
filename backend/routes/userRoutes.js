const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');

// Register/Update User
router.post('/register', userController.registerUser);

// Get User by Firebase UID
router.get('/:firebaseUid', userController.getUser);

module.exports = router;
