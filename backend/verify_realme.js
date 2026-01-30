const mongoose = require('mongoose');
const XLSX = require('xlsx');
const Model = require('./models/Model');
const Brand = require('./models/Brand');
require('dotenv').config();

const connectDB = async () => {
    try {
        await mongoose.connect(process.env.MONGO_URI);
        console.log('MongoDB Connected');
    } catch (error) {
        console.error('DB Error', error);
        process.exit(1);
    }
};

const verify = async () => {
    await connectDB();

    const realme = await Brand.findOne({ title: { $regex: /^realme$/i } });
    if (!realme) {
        console.log('Brand Realme not found in DB');
        process.exit();
    }

    const count = await Model.countDocuments({ brandId: realme._id });
    console.log(`Total Models for Realme: ${count}`);

    const models = await Model.find({ brandId: realme._id }).select('name price');
    models.forEach(m => console.log(`- ${m.name}: ${m.price}`));

    process.exit();
};

verify();
