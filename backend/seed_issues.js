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
        console.log('Connecting to DB...');
        // DB connection is handled by connectDB() call above, but we need to ensure it's ready if logic was different. 
        // connectDB is async but not awaited here in original code? 
        // Original code: connectDB(); 
        // It connects. Mongoose buffers.

        console.log('Starting issue seed/update...');

        // Verify/Add new issues to the list
        const allIssuesData = [
            ...issuesData,
            {
                name: 'Front Camera',
                category: 'Camera',
                icon: 'camera',
                imageFile: 'issue_frontcamera.png',
                base_price: '1299',
            },
            {
                name: 'Main Speaker', // Back/Loud Speaker
                category: 'Audio',
                icon: 'speaker',
                imageFile: 'issue_speakerback.png',
                base_price: '999',
            }
        ];

        for (const issue of allIssuesData) {
            let imageUrl = '';

            // Try to find existing first to avoid re-uploading if not needed? 
            // Or just re-upload to ensure latest image. Cloudinary handles duplicates if filename same?
            // User requested "PUSH THESE ALL ISSUE IMAGES", so we will upload.

            try {
                const imagePath = path.join(__dirname, '../assets/images/issues', issue.imageFile);
                console.log(`Uploading ${issue.name} image from ${imagePath}...`);
                const result = await cloudinary.uploader.upload(imagePath, {
                    folder: 'ziyonstar_issues',
                    use_filename: true,
                    unique_filename: false,
                });
                imageUrl = result.secure_url;
            } catch (imgError) {
                console.error(`Failed to upload image for ${issue.name}: ${imgError.message}`);
                // Continue? If existing issue has image, keep it?
                // For now, allow failing if file missing but standard issues should have files.
            }

            const updateData = {
                category: issue.category,
                base_price: issue.base_price,
                icon: issue.icon,
            };

            if (imageUrl) {
                updateData.imageUrl = imageUrl;
            }

            const doc = await Issue.findOneAndUpdate(
                { name: issue.name },
                { $set: updateData },
                { upsert: true, new: true }
            );
            console.log(`Upserted issue: ${doc.name}`);
        }

        console.log('Issue seeding/updating completed successfully!');
        process.exit(0);
    } catch (error) {
        console.error('Error seeding issues:', error);
        process.exit(1);
    }
};

seedIssues();
