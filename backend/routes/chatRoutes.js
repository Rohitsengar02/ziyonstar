const express = require('express');
const router = express.Router();
const chatController = require('../controllers/chatController');

router.post('/get-or-create', chatController.getOrCreateChat);
router.get('/messages/:chatId', chatController.getChatMessages);
router.post('/messages', chatController.sendMessage);

module.exports = router;
