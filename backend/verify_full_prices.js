const mongoose = require('mongoose');
const Model = require('./models/Model');
require('dotenv').config();

const verify = async () => {
    await mongoose.connect(process.env.MONGO_URI);

    // Check one model in detail
    const m = await Model.findOne({ name: 'REALME 9 PRO 5G' });
    if (m) {
        console.log(`Model: ${m.name}`);
        console.log('Repair Prices:');
        console.table(m.repairPrices.map(p => ({ Issue: p.issueName, Price: p.price })));
    } else {
        console.log('Model not found');
    }
    process.exit();
};

verify();
