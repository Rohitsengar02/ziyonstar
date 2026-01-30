const mongoose = require('mongoose');
const Model = require('./models/Model');
require('dotenv').config();

const diagnose = async () => {
    await mongoose.connect(process.env.MONGO_URI);

    // Check specific models causing issues
    const modelsToCheck = ['REALME 9i', 'REAMNE 9i', 'Realme 9i'];

    console.log('--- Checking Database Entries ---');
    for (const name of modelsToCheck) {
        // Case insensitive search
        const m = await Model.findOne({ name: { $regex: new RegExp(`^${name}$`, 'i') } });
        if (m) {
            console.log(`FOUND: "${m.name}"`);
            console.log(`ID: ${m._id}`);
            console.log(`Prices count: ${m.repairPrices.length}`);
            if (m.repairPrices.length > 0) {
                console.log('Sample Prices:');
                m.repairPrices.slice(0, 5).forEach(p => console.log(`   - ${p.issueName}: ${p.price}`));
            }
        } else {
            console.log(`NOT FOUND: "${name}"`);
        }
    }

    console.log('\n--- Checking All Models Count ---');
    const total = await Model.countDocuments();
    console.log(`Total Models in DB: ${total}`);

    process.exit();
};

diagnose();
