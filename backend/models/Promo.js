const mongoose = require('mongoose');

const PromoSchema = new mongoose.Schema({
    code: { type: String, required: true, unique: true }, // e.g., SAVE500
    title: { type: String, required: true }, // e.g., Summer Sale
    description: { type: String },
    discountType: { type: String, enum: ['percentage', 'fixed'], default: 'fixed' },
    discountValue: { type: Number, required: true }, // 500 or 10 (percent)
    minOrderValue: { type: Number, default: 0 },
    maxDiscount: { type: Number }, // Max discount for percentage
    validFrom: { type: Date, default: Date.now },
    validUntil: { type: Date },
    usageLimit: { type: Number }, // Max total uses
    usedCount: { type: Number, default: 0 },
    isActive: { type: Boolean, default: true },
    imageUrl: { type: String }, // Optional banner image
    createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Promo', PromoSchema);
