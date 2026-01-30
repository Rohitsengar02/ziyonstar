const mongoose = require('mongoose');

const ModelSchema = new mongoose.Schema({
    brandId: { type: mongoose.Schema.Types.ObjectId, ref: 'Brand', required: true },
    name: { type: String, required: true },
    price: { type: String, default: '0' }, // Base/Display price for Admin Panel
    repairPrices: [{
        issueName: { type: String, required: true }, // e.g., "Screen", "Battery"
        price: { type: Number, required: true },      // Final Price
        originalPrice: { type: Number },              // Column 2 (Price before discount)
        discount: { type: String }                    // Column 3 (e.g. "48%")
    }],
    createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Model', ModelSchema);
