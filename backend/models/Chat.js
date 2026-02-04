const mongoose = require('mongoose');

const ChatSchema = new mongoose.Schema({
    bookingId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Booking',
        required: true,
        unique: true
    },
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    technicianId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Technician',
        required: true
    },
    lastMessage: {
        text: String,
        senderId: String,
        timestamp: { type: Date, default: Date.now }
    },
    createdAt: { type: Date, default: Date.now },
    updatedAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Chat', ChatSchema);
