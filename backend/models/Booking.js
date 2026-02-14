const mongoose = require('mongoose');

const bookingSchema = new mongoose.Schema({
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    technicianId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Technician',
        default: null
    },
    // Service Details
    deviceBrand: { type: String, required: true },
    deviceModel: { type: String, required: true },
    issues: [{
        issueName: String,
        issueImage: String,
        price: Number
    }],
    totalPrice: { type: Number, required: true },

    // Review fields
    rating: { type: Number, default: 0 },
    reviewText: { type: String, default: '' },
    reviewed: { type: Boolean, default: false },

    // Scheduling
    scheduledDate: { type: Date, required: true },
    timeSlot: { type: String, required: true },

    // Address
    address: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Address'
    },
    addressDetails: { type: String }, // Fallback for text-only addresses

    // Status Flow
    status: {
        type: String,
        enum: [
            'Pending_Assignment', // Created, waiting for tech assignment (if manual/auto)
            'Pending_Acceptance', // Assigned to tech, waiting for tech response
            'Awaiting_Payment',   // Online payment pending
            'Accepted',
            'On_Way',             // Tech is on the way to user
            'Arrived',            // Tech has arrived at location
            'Rejected',           // Tech rejected, waiting for user action
            'Reassign_Requested', // User requested new tech
            'In_Progress',
            'Picked_Up',          // Device picked up by technician
            'Completed',
            'Cancelled'
        ],
        default: 'Pending_Assignment'
    },

    // History of technicians who rejected this booking
    rejectedBy: [{
        technicianId: { type: mongoose.Schema.Types.ObjectId, ref: 'Technician' },
        reason: String,
        rejectedAt: { type: Date, default: Date.now }
    }],

    paymentStatus: {
        type: String,
        enum: ['Pending', 'Paid', 'Failed'],
        default: 'Pending'
    },
    paymentMethod: {
        type: String,
        enum: ['UPI', 'Card', 'Cash'],
        default: 'Cash'
    },
    transactionId: {
        type: String,
        default: ''
    },
    paymentDetails: {
        type: Object,
        default: {}
    },
    otp: {
        type: String,
        default: ''
    },
    otpVerified: {
        type: Boolean,
        default: false
    },
    pickupDetails: {
        images: [String],
        deliveryTime: String,
        isPickedUp: { type: Boolean, default: false },
        pickedUpAt: Date
    }

}, { timestamps: true });

module.exports = mongoose.model('Booking', bookingSchema);
