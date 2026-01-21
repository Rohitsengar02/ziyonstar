const mongoose = require('mongoose');

const CommissionSchema = new mongoose.Schema({
    category: { type: String, required: true, unique: true }, // e.g., 'Mobile', 'Laptop'
    type: { type: String, enum: ['percentage', 'fixed'], default: 'percentage' },
    value: { type: Number, required: true }, // e.g. 10 for 10%
    description: { type: String },
    isActive: { type: Boolean, default: true },
    updatedAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Commission', CommissionSchema);
