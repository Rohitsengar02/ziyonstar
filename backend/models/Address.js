const mongoose = require('mongoose');

const AddressSchema = new mongoose.Schema({
    userId: {
        type: String,
        required: true,
        index: true
    },
    label: {
        type: String,
        default: 'Home'  // Home, Office, Other
    },
    fullAddress: {
        type: String,
        required: true
    },
    landmark: {
        type: String
    },
    city: {
        type: String
    },
    state: {
        type: String
    },
    pincode: {
        type: String
    },
    phone: {
        type: String
    },
    isDefault: {
        type: Boolean,
        default: false
    },
    createdAt: {
        type: Date,
        default: Date.now
    }
});

module.exports = mongoose.model('Address', AddressSchema);
