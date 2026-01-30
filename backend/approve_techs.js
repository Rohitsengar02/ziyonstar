const mongoose = require('mongoose');
const Technician = require('./models/Technician');
const dotenv = require('dotenv');

dotenv.config();

const updateTechs = async () => {
    try {
        await mongoose.connect(process.env.MONGO_URI || 'mongodb+srv://yogeshthakur782:yogesh@cluster0.ls0da.mongodb.net/test?retryWrites=true&w=majority&appName=Cluster0');
        console.log('MongoDB Connected');

        // Find all technicians
        const techs = await Technician.find({});
        console.log(`Found ${techs.length} technicians.`);

        for (const tech of techs) {
            console.log(`Checking Tech: ${tech.name} (${tech.email}) - Status: ${tech.status}`);

            // Force status to 'active' or 'approved' for testing
            // My bookingController assigns if status is 'active' or 'approved'.
            // Let's set to 'active' which implies online/ready.

            if (tech.status !== 'active') {
                tech.status = 'active';
                tech.isOnline = true; // Ensure they appear online
                await tech.save();
                console.log(`-> Updated to ACTIVE`);
            }
        }

        console.log('Done.');
        process.exit();
    } catch (error) {
        console.error('Error:', error);
        process.exit(1);
    }
};

updateTechs();
