const mongoose = require('mongoose');
const Issue = require('./models/Issue');
require('dotenv').config();

(async () => {
    await mongoose.connect(process.env.MONGO_URI);

    // 1. Delete all generic issues again
    await Issue.deleteMany({});
    console.log('Cleared old generic issues.');

    // 2. Insert Issues with LOCAL ASSET PATHS
    const newIssues = [
        { name: 'Screen', category: 'Display', base_price: '0', icon: 'smartphone', imageUrl: 'assets/images/issues/issue_screen.png' },
        { name: 'Battery', category: 'Power', base_price: '0', icon: 'battery', imageUrl: 'assets/images/issues/issue_battery.png' },
        { name: 'Receiver', category: 'Sound', base_price: '0', icon: 'speaker', imageUrl: 'assets/images/issues/issue_speaker.png' },
        { name: 'Charging Jack', category: 'Power', base_price: '0', icon: 'plug', imageUrl: 'assets/images/issues/issue_charging.png' },
        { name: 'Mic', category: 'Sound', base_price: '0', icon: 'mic', imageUrl: 'assets/images/issues/issue_mic.png' },
        { name: 'Speaker', category: 'Sound', base_price: '0', icon: 'speaker', imageUrl: 'assets/images/issues/issue_speaker.png' },
        { name: 'Front Camera', category: 'Camera', base_price: '0', icon: 'camera', imageUrl: 'assets/images/issues/issue_camera.png' },
        { name: 'Back Camera', category: 'Camera', base_price: '0', icon: 'camera', imageUrl: 'assets/images/issues/issue_camera.png' },
        { name: 'Aux Jack', category: 'Sound', base_price: '0', icon: 'headphones', imageUrl: 'assets/images/issues/issue_speaker.png' },
        { name: 'Sensors', category: 'Other', base_price: '0', icon: 'cpu', imageUrl: 'assets/images/issues/issue_sensors.png' },
        { name: 'Motherboard', category: 'Other', base_price: '0', icon: 'cpu', imageUrl: 'assets/images/issues/issue_motherboard.png' },
        { name: 'Water Damage', category: 'Other', base_price: '0', icon: 'droplet', imageUrl: 'assets/images/issues/issue_water.png' },
        { name: 'Software', category: 'Data', base_price: '0', icon: 'code', imageUrl: 'assets/images/issues/issue_software.png' },
        { name: 'Face/Touch ID', category: 'Security', base_price: '0', icon: 'scanFace', imageUrl: 'assets/images/issues/issue_faceid.png' },
        { name: 'Back Glass', category: 'Body', base_price: '0', icon: 'smartphone', imageUrl: 'assets/images/issues/issue_backglass.png' }
    ];

    await Issue.insertMany(newIssues);
    console.log('Seeded new Issues with Local Asset Paths.');
    process.exit();
})();
