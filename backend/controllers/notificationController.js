const Notification = require('../models/Notification');

exports.getUserNotifications = async (req, res) => {
    try {
        const { userId } = req.params;
        const notifications = await Notification.find({ userId }).sort({ createdAt: -1 });
        res.json(notifications);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching notifications', error: error.message });
    }
};

exports.markAsSeen = async (req, res) => {
    try {
        const { id } = req.params;
        await Notification.findByIdAndUpdate(id, { seen: true });
        res.json({ message: 'Notification marked as seen' });
    } catch (error) {
        res.status(500).json({ message: 'Error updating notification', error: error.message });
    }
};

exports.clearAll = async (req, res) => {
    try {
        const { userId } = req.params;
        await Notification.deleteMany({ userId });
        res.json({ message: 'All notifications cleared' });
    } catch (error) {
        res.status(500).json({ message: 'Error clearing notifications', error: error.message });
    }
};

exports.createNotification = async (userId, title, message, type, bookingId) => {
    try {
        const notification = new Notification({
            userId,
            title,
            message,
            type,
            bookingId
        });
        await notification.save();
        return notification;
    } catch (error) {
        console.error('Error creating notification:', error);
    }
};
