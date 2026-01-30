const mongoose = require('mongoose');

const CompanyInfoSchema = new mongoose.Schema({
    phone: { type: String, default: '+1 (555) 123-4567' },
    email: { type: String, default: 'support@ziyonstar.com' },
    address: { type: String, default: '123 Tech Street, Silicon Valley, CA 94025' },
    workingHours: { type: String, default: 'Monday - Friday: 9:00 AM - 6:00 PM' },
    updatedAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('CompanyInfo', CompanyInfoSchema);
