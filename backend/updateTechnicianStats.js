const Technician = require('./models/Technician');
const Review = require('./models/Review');
const Booking = require('./models/Booking');
const connectDB = require('./config/db');
require('dotenv').config();

async function updateTechnicianStats() {
    try {
        await connectDB();
        console.log('Connected to database');

        const technicians = await Technician.find();
        console.log(`Found ${technicians.length} technicians`);

        for (const tech of technicians) {
            const reviews = await Review.find({ technicianId: tech._id });
            const completedBookings = await Booking.countDocuments({
                technicianId: tech._id,
                status: 'Completed'
            });

            const totalReviews = reviews.length;
            const averageRating = totalReviews > 0
                ? Math.round((reviews.reduce((sum, r) => sum + r.rating, 0) / totalReviews) * 10) / 10
                : 0;

            tech.averageRating = averageRating;
            tech.totalReviews = totalReviews;
            tech.completedJobs = completedBookings;

            await tech.save();
            console.log(`Updated ${tech.name}: ${averageRating} stars, ${totalReviews} reviews, ${completedBookings} jobs`);
        }

        console.log('✅ All technician stats updated successfully!');
        process.exit(0);
    } catch (error) {
        console.error('Error updating stats:', error);
        process.exit(1);
    }
}

updateTechnicianStats();
