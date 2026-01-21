const express = require('express');
const router = express.Router();
const {
    getAddresses,
    addAddress,
    updateAddress,
    deleteAddress,
    setDefaultAddress
} = require('../controllers/addressController');

// Get all addresses for a user
router.get('/:userId', getAddresses);

// Add new address for a user
router.post('/:userId', addAddress);

// Update an address
router.put('/:id', updateAddress);

// Delete an address
router.delete('/:id', deleteAddress);

// Set default address
router.put('/:id/default', setDefaultAddress);

module.exports = router;
