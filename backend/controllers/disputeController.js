const Dispute = require('../models/Dispute');
const Booking = require('../models/Booking');
const notificationController = require('./notificationController');
const adminNotificationController = require('./adminNotificationController');

exports.createDispute = async (req, res) => {
    try {
        console.log('Received Dispute Request Body:', req.body);
        const { bookingId, userId, reason, description } = req.body;

        if (!bookingId || !userId) {
            return res.status(400).json({ message: 'bookingId and userId are required' });
        }

        const booking = await Booking.findById(bookingId);
        if (!booking) {
            console.error('Booking not found for ID:', bookingId);
            return res.status(422).json({ message: 'Booking not found' }); // Use 422 to distinguish from Route 404
        }

        const dispute = new Dispute({
            bookingId,
            userId,
            technicianId: booking.technicianId,
            reason,
            description
        });

        await dispute.save();

        // Notify User
        await notificationController.createNotification(
            userId,
            'Complaint Received',
            'We have received your complaint regarding the booking. Our team will investigate it soon.',
            'warning',
            bookingId
        );

        // Notify Admin
        await adminNotificationController.createAdminNotification(
            'New Dispute Raised',
            `A new complaint has been filed for booking #BK-${bookingId.toString().substring(bookingId.toString().length - 8).toUpperCase()}`,
            'error',
            dispute._id,
            bookingId
        );

        res.status(201).json(dispute);
    } catch (error) {
        res.status(500).json({ message: 'Error creating dispute', error: error.message });
    }
};

exports.getAllDisputes = async (req, res) => {
    try {
        const disputes = await Dispute.find()
            .populate('userId', 'name email phone')
            .populate('technicianId', 'name email phone')
            .populate('bookingId')
            .sort({ createdAt: -1 });
        res.json(disputes);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching disputes', error: error.message });
    }
};

exports.getDisputeById = async (req, res) => {
    try {
        const dispute = await Dispute.findById(req.params.id)
            .populate('userId', 'name email phone')
            .populate('technicianId', 'name email phone')
            .populate('bookingId');
        if (!dispute) {
            return res.status(404).json({ message: 'Dispute not found' });
        }
        res.json(dispute);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching dispute', error: error.message });
    }
};

exports.updateDisputeStatus = async (req, res) => {
    try {
        const { status, adminNotes } = req.body;
        const dispute = await Dispute.findById(req.params.id);

        if (!dispute) {
            return res.status(404).json({ message: 'Dispute not found' });
        }

        dispute.status = status;
        if (adminNotes) dispute.adminNotes = adminNotes;
        if (status === 'Resolved') dispute.resolvedAt = new Date();

        await dispute.save();

        // Notify user about update
        await notificationController.createNotification(
            dispute.userId,
            'Complaint Update',
            `The status of your complaint has been updated to: ${status}.`,
            status === 'Resolved' ? 'success' : 'info',
            dispute.bookingId
        );

        res.json(dispute);
    } catch (error) {
        res.status(500).json({ message: 'Error updating dispute', error: error.message });
    }
};
