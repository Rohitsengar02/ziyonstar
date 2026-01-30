const mongoose = require('mongoose');

const AdminNotificationSchema = new mongoose.Schema({
    adminId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Admin'
    },
    title: {
        type: String,
        required: true
    },
    message: {
        type: String,
        required: true
    },
    type: {
        type: String,
        enum: ['success', 'warning', 'info', 'error'],
        default: 'info'
    },
    seen: {
        type: Boolean,
        default: false
    },
    disputeId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Dispute'
    },
    bookingId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Booking'
    },
    createdAt: {
        type: Date,
        default: Date.now
    }
});

module.exports = mongoose.model('AdminNotification', AdminNotificationSchema);
