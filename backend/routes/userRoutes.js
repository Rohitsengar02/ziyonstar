const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');

// Get All Users (for admin)
router.get('/', userController.getAllUsers);

// Register/Update User
router.post('/register', userController.registerUser);

// Get User by Firebase UID
router.get('/:firebaseUid', userController.getUser);

// Delete User
router.delete('/:firebaseUid', userController.deleteUser);

module.exports = router;
