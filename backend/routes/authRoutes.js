const express = require('express');
const router = express.Router();
const { register, login } = require('../controllers/authController');

router.post('/register', register);
router.post('/login', login);
router.get('/pending', require('../controllers/authController').getPendingAdmins);
router.get('/approved', require('../controllers/authController').getApprovedAdmins);
router.put('/approve/:id', require('../controllers/authController').approveAdmin);
router.delete('/remove/:id', require('../controllers/authController').deleteAdmin);
router.put('/update/:id', require('../controllers/authController').updateAdmin);

module.exports = router;
