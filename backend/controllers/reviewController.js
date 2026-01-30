const Review = require('../models/Review');
const Booking = require('../models/Booking');

exports.getTechnicianReviews = async (req, res) => {
    try {
        const { technicianId } = req.params;
        const reviews = await Review.find({ technicianId })
            .populate('userId', 'name photoUrl')
            .sort({ createdAt: -1 });

        res.json(reviews);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching reviews', error: error.message });
    }
};

exports.getLatestReview = async (req, res) => {
    try {
        const { technicianId } = req.params;
        const review = await Review.findOne({ technicianId })
            .populate('userId', 'name photoUrl')
            .sort({ createdAt: -1 });

        res.json(review);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching latest review', error: error.message });
    }
};
