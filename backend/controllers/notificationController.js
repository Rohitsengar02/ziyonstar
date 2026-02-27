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
        console.log(`[Notification] Triggered for target ID: ${userId}`);

        // 1. Find the target person (User or Technician)
        let target = await User.findById(userId);
        if (!target) {
            target = await Technician.findById(userId);
        }

        if (!target) {
            console.error(`[Notification] Error: Target not found in MongoDB for ID: ${userId}`);
            return null;
        }

        console.log(`[Notification] Target identified: ${target.email} (${target.role || 'user'})`);

        // 2. Save to MongoDB (Internal History)
        const notification = new Notification({
            userId: target._id,
            title,
            message,
            type: type || 'info',
            bookingId
        });
        await notification.save();

        // 3. Sync to Firebase Cloud Firestore (User-facing History)
        // This is what the app listens to for the notification list
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
                        mongoId: notification._id.toString(),
                        title: title,
                        body: message
                    },
                    timestamp: admin.firestore.FieldValue.serverTimestamp(),
                    seen: false,
                    role: target.role || 'user'
                });
                console.log(`[Notification] Firestore sync SUCCESS for UID: ${target.firebaseUid}`);
            } catch (fsError) {
                console.error(`[Notification] Firestore Error: ${fsError.message}`);
            }
        } else {
            console.warn(`[Notification] Firestore skip: Target ${target.email} has no firebaseUid`);
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
                    title: title,
                    body: message,
                    click_action: 'FLUTTER_NOTIFICATION_CLICK'
                },
                android: {
                    priority: 'high',
                    notification: {
                        channelId: isTechnician ? 'technician_high_importance' : 'high_importance_channel',
                        sound: 'default',
                        icon: 'ic_launcher',
                        color: '#1E3A8A',
                        clickAction: 'FLUTTER_NOTIFICATION_CLICK',
                        visibility: 'public'
                    }
                },
                apns: {
                    payload: {
                        aps: {
                            sound: 'default',
                            contentAvailable: true,
                            badge: 1,
                            interruptionLevel: 'critical'
                        }
                    }
                },
                token: target.fcmToken
            };

            try {
                console.log(`[Notification] Attempting FCM push to token suffix: ...${target.fcmToken.slice(-10)}`);
                const response = await admin.messaging().send(payload);
                console.log(`[Notification] Push SUCCESS. Message ID: ${response}`);
            } catch (fcmError) {
                console.error(`[Notification] FCM Error: ${fcmError.message}`);
            }
        } else {
            console.warn(`[Notification] FCM Skip: Target ${target.email} has no fcmToken registered.`);
        }

        return notification;
    } catch (error) {
        console.error('[Notification] Critical System Error:', error);
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
