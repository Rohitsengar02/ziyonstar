const mongoose = require('mongoose');

const ExpertiseRequestSchema = new mongoose.Schema({
    technicianId: { type: mongoose.Schema.Types.ObjectId, ref: 'Technician', required: true },
    brandExpertise: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Brand' }],
    repairExpertise: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Issue' }],
    status: {
        type: String,
        enum: ['pending', 'approved', 'rejected'],
        default: 'pending'
    },
    adminComment: { type: String },
    createdAt: { type: Date, default: Date.now },
    updatedAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('ExpertiseRequest', ExpertiseRequestSchema);
