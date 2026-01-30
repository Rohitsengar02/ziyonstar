const mongoose = require('mongoose');
const dotenv = require('dotenv');
const Brand = require('./models/Brand');
const Model = require('./models/Model');

// Load env vars
dotenv.config();

const brandsData = [
    {
        title: 'Apple',
        description: 'Premier smartphones with iOS.',
        icon: 'fa-apple',
        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/f/fa/Apple_logo_black.svg',
        models: [
            { name: 'iPhone 15 Pro Max', price: '₹1499' },
            { name: 'iPhone 15 Pro', price: '₹1399' },
            { name: 'iPhone 15', price: '₹1299' },
            { name: 'iPhone 14 Pro Max', price: '₹1399' },
            { name: 'iPhone 14', price: '₹1199' },
            { name: 'iPhone 13', price: '₹1099' },
            { name: 'iPhone 12', price: '₹999' },
            { name: 'iPhone 11', price: '₹899' },
        ],
    },
    {
        title: 'Samsung',
        description: 'Android flagship and mid-range devices.',
        icon: 'fa-android',
        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/2/24/Samsung_Logo.svg',
        models: [
            { name: 'Galaxy S24 Ultra', price: '₹1499' },
            { name: 'Galaxy S24', price: '₹1299' },
            { name: 'Galaxy S23 Ultra', price: '₹1299' },
            { name: 'Galaxy S23', price: '₹1199' },
            { name: 'Galaxy A54', price: '₹899' },
            { name: 'Galaxy Z Fold 5', price: '₹1799' },
        ],
    },
    {
        title: 'Google',
        description: 'Pixel phones with pure Android experience.',
        icon: 'fa-google',
        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/2/2f/Google_2015_logo.svg',
        models: [
            { name: 'Pixel 8 Pro', price: '₹1299' },
            { name: 'Pixel 8', price: '₹1099' },
            { name: 'Pixel 7 Pro', price: '₹1099' },
            { name: 'Pixel 7a', price: '₹899' },
            { name: 'Pixel 6', price: '₹799' },
        ],
    },
    {
        title: 'OnePlus',
        description: 'Fast and smooth Android smartphones.',
        icon: 'fa-mobile',
        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/f/f8/OnePlus_logo.svg',
        models: [
            { name: 'OnePlus 12', price: '₹1299' },
            { name: 'OnePlus 11', price: '₹1099' },
            { name: 'OnePlus 11R', price: '₹999' },
            { name: 'OnePlus Nord CE 3', price: '₹799' },
        ],
    },
    {
        title: 'Xiaomi',
        description: 'Feature-rich phones at affordable prices.',
        icon: 'fa-mobile',
        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/a/ae/Xiaomi_logo_%282021-%29.svg',
        models: [
            { name: 'Xiaomi 14 Ultra', price: '₹1399' },
            { name: 'Xiaomi 13 Pro', price: '₹1199' },
            { name: 'Redmi Note 13 Pro', price: '₹899' },
            { name: 'Poco X6 Pro', price: '₹799' },
        ],
    },
];

const seedDB = async () => {
    try {
        await mongoose.connect(process.env.MONGO_URI);
        console.log('MongoDB Connected for Seeding');

        // Clear existing data
        await Brand.deleteMany({});
        await Model.deleteMany({});
        console.log('Cleared existing Brands and Models');

        for (const brandData of brandsData) {
            // Create Brand
            const brand = new Brand({
                title: brandData.title,
                description: brandData.description,
                icon: brandData.icon,
                imageUrl: brandData.imageUrl,
            });
            const savedBrand = await brand.save();
            console.log(`Created Brand: ${savedBrand.title}`);

            // Create Models for this Brand
            const modelDocs = brandData.models.map(m => ({
                brandId: savedBrand._id,
                name: m.name,
                price: m.price
            }));

            await Model.insertMany(modelDocs);
            console.log(`Added ${modelDocs.length} models for ${savedBrand.title}`);
        }

        console.log('✅ Seeding Completed Successfully');
        process.exit();
    } catch (error) {
        console.error('❌ Seeding Failed:', error);
        process.exit(1);
    }
};

seedDB();
