const User = require('../models/User');

// Register or Update User (Upsert)
exports.registerUser = async (req, res) => {
    try {
        const { name, email, firebaseUid, photoUrl, phone, role, fcmToken } = req.body;

        let user = await User.findOne({ firebaseUid });

        if (!user) {
            // Fallback: Check if user exists with the same email
            user = await User.findOne({ email });
        }

        if (user) {
            user.name = name || user.name;
            user.email = email || user.email;
            user.firebaseUid = firebaseUid || user.firebaseUid; // Update UID if it changed
            user.photoUrl = photoUrl || user.photoUrl;
            user.phone = phone || user.phone;
            user.fcmToken = fcmToken || user.fcmToken;
            // Only update role if provided
            if (role) user.role = role;

            await user.save();
            return res.status(200).json({ msg: 'User updated', user });
        } else {
            user = new User({
                name,
                email,
                firebaseUid,
                photoUrl,
                phone,
                fcmToken: fcmToken || '',
                role: role || 'user'
            });
            await user.save();
            return res.status(201).json({ msg: 'User registered', user });
        }
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};

// Get User by Firebase UID
exports.getUser = async (req, res) => {
    try {
        const user = await User.findOne({ firebaseUid: req.params.firebaseUid });
        if (!user) {
            return res.status(404).json({ msg: 'User not found' });
        }
        res.json(user);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};

// Get All Users (for admin analytics)
exports.getAllUsers = async (req, res) => {
    try {
        const users = await User.find().select('-__v');
        res.json(users);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};
