const AdminNotification = require('../models/AdminNotification');

exports.createAdminNotification = async (title, message, type, disputeId, bookingId) => {
    try {
        const notification = new AdminNotification({
            title,
            message,
            type,
            disputeId,
            bookingId
        });
        await notification.save();
        return notification;
    } catch (error) {
        console.error('Error creating admin notification:', error);
    }
};

exports.getAdminNotifications = async (req, res) => {
    try {
        const notifications = await AdminNotification.find().sort({ createdAt: -1 });
        res.json(notifications);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching admin notifications', error: error.message });
    }
};

exports.markAsSeen = async (req, res) => {
    try {
        await AdminNotification.findByIdAndUpdate(req.params.id, { seen: true });
        res.json({ message: 'Notification marked as seen' });
    } catch (error) {
        res.status(500).json({ message: 'Error updating notification', error: error.message });
    }
};

exports.clearAll = async (req, res) => {
    try {
        await AdminNotification.deleteMany({});
        res.json({ message: 'All admin notifications cleared' });
    } catch (error) {
        res.status(500).json({ message: 'Error clearing notifications', error: error.message });
    }
};
