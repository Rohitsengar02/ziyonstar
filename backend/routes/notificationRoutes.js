const express = require('express');
const router = express.Router();
const notificationController = require('../controllers/notificationController');

router.get('/user/:userId', notificationController.getUserNotifications);
router.put('/:id/seen', notificationController.markAsSeen);
router.delete('/user/:userId', notificationController.clearAll);

module.exports = router;
