const Notification = require('../models/Notification');
const User = require('../models/User');
const Technician = require('../models/Technician');
const admin = require('../config/firebase');

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
        console.log(`Creating notification for user: ${userId}, Title: ${title}`);
        // 1. Save to MongoDB
        const notification = new Notification({
            userId,
            title,
            message,
            type,
            bookingId
        });
        await notification.save();

        // 2. Find internal User/Technician to get firebaseUid and fcmToken
        let target = await User.findById(userId) || await Technician.findById(userId);

        if (!target) {
            console.error(`Target not found in MongoDB for ID: ${userId}`);
            return notification;
        }

        console.log(`Target found: ${target.email}, Role: ${target.role || 'user'}, FCM Token: ${target.fcmToken ? 'Yes' : 'No'}`);

        // 3. Save to Firestore History (for cross-device parity)
        if (target.firebaseUid) {
            try {
                const db = admin.firestore();
                await db.collection('notifications').add({
                    userId: target.firebaseUid,
                    receiverId: target.firebaseUid,
                    senderId: 'system',
                    title,
                    body: message,
                    data: {
                        type: type || 'info',
                        bookingId: bookingId ? bookingId.toString() : '',
                        mongoId: notification._id.toString()
                    },
                    timestamp: admin.firestore.FieldValue.serverTimestamp(),
                    seen: false,
                    role: target.role || 'user'
                });
                console.log('Notification synced to Firestore for user:', target.firebaseUid);
            } catch (fsError) {
                console.error('Error syncing to Firestore:', fsError.message);
            }
        } else {
            console.warn(`Target ${target.email} has no firebaseUid, skipping Firestore sync.`);
        }

        // 4. Send Push Notification via FCM
        if (target.fcmToken) {
            const isTechnician = target.role === 'technician';

            const payload = {
                notification: {
                    title: title,
                    body: message,
                },
                data: {
                    type: type || 'info',
                    bookingId: bookingId ? bookingId.toString() : '',
                    click_action: 'FLUTTER_NOTIFICATION_CLICK'
                },
                android: {
                    priority: 'high',
                    notification: {
                        channelId: isTechnician ? 'technician_high_importance' : 'high_importance_channel',
                        sound: 'default',
                        priority: 'high',
                        visibility: 'public',
                    }
                },
                apns: {
                    payload: {
                        aps: {
                            sound: 'default',
                            contentAvailable: true,
                            badge: 1,
                        }
                    }
                },
                token: target.fcmToken
            };

            try {
                console.log(`Sending FCM to ${target.email} via token: ${target.fcmToken.substring(0, 10)}...`);
                await admin.messaging().send(payload);
                console.log(`Push notification sent successfully to ${target.role}: ${target.email}`);
            } catch (fcmError) {
                console.error('Error sending FCM:', fcmError.message);
            }
        } else {
            console.warn(`Target ${target.email} has no fcmToken, skipping Push Notification.`);
        }

        return notification;
    } catch (error) {
        console.error('Error creating notification:', error);
    }
};

exports.sendTestNotification = async (req, res) => {
    try {
        const { firebaseUid } = req.body;
        console.log(`Test notification requested for firebaseUid: ${firebaseUid}`);

        const technician = await Technician.findOne({ firebaseUid });
        if (!technician) {
            return res.status(404).json({ message: 'Technician not found' });
        }

        await exports.createNotification(
            technician._id,
            '🔔 Test Notification!',
            'Your push notification system is working correctly. Great job!',
            'info'
        );

        res.status(200).json({ message: 'Test notification sent' });
    } catch (error) {
        console.error('Error in sendTestNotification:', error);
        res.status(500).json({ message: 'Error sending test notification', error: error.message });
    }
};
