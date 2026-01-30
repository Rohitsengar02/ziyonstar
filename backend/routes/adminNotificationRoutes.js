const express = require('express');
const router = express.Router();
const controller = require('../controllers/adminNotificationController');

router.get('/', controller.getAdminNotifications);
router.put('/:id/seen', controller.markAsSeen);
router.delete('/', controller.clearAll);

module.exports = router;
