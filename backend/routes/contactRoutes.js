const express = require('express');
const router = express.Router();
const contactController = require('../controllers/contactController');

// Submit Contact Form
router.post('/', contactController.createContact);

// Get All Messages (Admin)
router.get('/', contactController.getAllContacts);

// Update Message (Admin)
router.put('/:id', contactController.updateContact);

// Delete Message (Admin)
router.delete('/:id', contactController.deleteContact);

module.exports = router;
