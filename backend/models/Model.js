const mongoose = require('mongoose');

const ModelSchema = new mongoose.Schema({
    brandId: { type: mongoose.Schema.Types.ObjectId, ref: 'Brand', required: true },
    name: { type: String, required: true },
    price: { type: String, required: true }, // Store as string to include currency or formatted price
    createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Model', ModelSchema);
