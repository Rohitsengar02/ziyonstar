const mongoose = require('mongoose');

const technicianSchema = new mongoose.Schema({
    name: {
        type: String,
        required: true,
    },
    email: {
        type: String,
        required: true,
        unique: true,
    },
    firebaseUid: {
        type: String,
        required: true,
        unique: true,
    },
    photoUrl: {
        type: String,
        default: '',
    },
    phone: {
        type: String,
        default: '',
    },
    fcmToken: {
        type: String,
        default: '',
    },
    role: {
        type: String,
        default: 'technician',
    },
    status: {
        type: String,
        enum: ['pending', 'approved', 'active', 'blocked', 'rejected', 'suspended'],
        default: 'pending',
    },
    isOnline: {
        type: Boolean,
        default: false,
    },
    // Onboarding Data
    dob: { type: Date },
    gender: { type: String },
    city: { type: String },
    serviceAreaRadius: { type: String }, // e.g., '10km'

    // KYC
    kycType: { type: String }, // 'Aadhaar', 'Driving License', etc.
    kycNumber: { type: String },
    kycDocumentFront: { type: String }, // URL
    kycDocumentBack: { type: String }, // URL

    // Expertise
    brandExpertise: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Brand' }],
    repairExpertise: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Issue' }], // or Categories

    // Service Type & Coverage
    serviceTypes: [{ type: String }], // 'Walk-in', 'Home Visit', 'Pick & Drop'
    coverageAreas: [{ type: String }], // List of pin codes or areas

    // Bank Details
    bankName: { type: String },
    accountHolderName: { type: String },
    accountNumber: { type: String },
    ifscCode: { type: String },
    upiId: { type: String },

    // Agreement
    agreedToTerms: { type: Boolean, default: false },
    agreementDate: { type: Date },

    // Ratings
    averageRating: { type: Number, default: 0 },
    totalReviews: { type: Number, default: 0 },
    completedJobs: { type: Number, default: 0 },

}, { timestamps: true });

module.exports = mongoose.model('Technician', technicianSchema);
