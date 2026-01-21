const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '.env') });
const Issue = require('./models/Issue');
const connectDB = require('./config/db');
const { cloudinary } = require('./config/cloudinary');

// Connect to Database
connectDB();

const issuesData = [
    {
        name: 'Screen',
        category: 'Display',
        icon: 'smartphone',
        imageFile: 'issue_screen.png',
        base_price: '2999',
        symptoms: ['Cracked Glass', 'Touch Issue', 'Black Lines', 'No Display'], // Note: Schema doesn't have symptoms yet, but good to have in mind. Schema only has name, category, base_price, icon, imageUrl
    },
    {
        name: 'Battery',
        category: 'Power',
        icon: 'battery',
        imageFile: 'issue_battery.png',
        base_price: '1499',
    },
    {
        name: 'Camera',
        category: 'Camera',
        icon: 'camera',
        imageFile: 'issue_camera.png',
        base_price: '1999',
    },
    {
        name: 'Charging',
        category: 'Power',
        icon: 'plug',
        imageFile: 'issue_charging.png',
        base_price: '999',
    },
    {
        name: 'Speaker',
        category: 'Audio',
        icon: 'speaker',
        imageFile: 'issue_speaker.png',
        base_price: '899',
    },
    {
        name: 'Back Glass',
        category: 'Body',
        icon: 'smartphone',
        imageFile: 'issue_backglass.png',
        base_price: '2499',
    },
    {
        name: 'Mic',
        category: 'Audio',
        icon: 'mic',
        imageFile: 'issue_mic.png',
        base_price: '899',
    },
    {
        name: 'Software',
        category: 'Software',
        icon: 'cpu',
        imageFile: 'issue_software.png',
        base_price: '499',
    },
    {
        name: 'Water Damage',
        category: 'Damage',
        icon: 'droplet',
        imageFile: 'issue_water.png',
        base_price: '1499',
    },
    {
        name: 'Motherboard',
        category: 'Hardware',
        icon: 'cpu',
        imageFile: 'issue_motherboard.png',
        base_price: '3999',
    },
    {
        name: 'Face/Touch ID',
        category: 'Security',
        icon: 'smartphone', // No scanFace in basic list
        imageFile: 'issue_faceid.png',
        base_price: '2499',
    },
    {
        name: 'Sensors',
        category: 'Sensors',
        icon: 'smartphone', // No specific sensor icon
        imageFile: 'issue_sensors.png',
        base_price: '999',
    },
];

const seedIssues = async () => {
    try {
        console.log('Clearing existing issues...');
        await Issue.deleteMany({});

        console.log('Uploading images and seeding issues...');

        for (const issue of issuesData) {
            const imagePath = path.join(__dirname, '../assets/images/issues', issue.imageFile);

            console.log(`Uploading ${issue.name} image from ${imagePath}...`);

            const result = await cloudinary.uploader.upload(imagePath, {
                folder: 'ziyonstar_issues',
                use_filename: true,
                unique_filename: false,
            });

            console.log(`Image uploaded: ${result.secure_url}`);

            const newIssue = new Issue({
                name: issue.name,
                category: issue.category,
                base_price: issue.base_price,
                icon: issue.icon,
                imageUrl: result.secure_url,
            });

            await newIssue.save();
            console.log(`Saved issue: ${issue.name}`);
        }

        console.log('Seeding completed successfully!');
        process.exit(0);
    } catch (error) {
        console.error('Error seeding issues:', error);
        process.exit(1);
    }
};

seedIssues();
