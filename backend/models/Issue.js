const mongoose = require('mongoose');

const IssueSchema = new mongoose.Schema({
    name: { type: String, required: true },
    category: { type: String, required: true }, // e.g. Display, Power, Software
    base_price: { type: String, required: true },
    icon: { type: String }, // Icon name string
    imageUrl: { type: String },
    createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Issue', IssueSchema);
