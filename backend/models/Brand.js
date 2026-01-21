const mongoose = require('mongoose');

const BrandSchema = new mongoose.Schema({
    title: { type: String, required: true },
    description: { type: String },
    icon: { type: String }, // URL from cloudinary or icon code
    imageUrl: { type: String, required: true }, // Cloudinary URL
    createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Brand', BrandSchema);
