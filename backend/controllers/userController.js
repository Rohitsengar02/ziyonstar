const User = require('../models/User');

// Register or Update User (Upsert)
exports.registerUser = async (req, res) => {
    try {
        const { name, email, firebaseUid, photoUrl, phone, role, fcmToken } = req.body;
        console.log('--- Register/Update User Request ---');
        console.log('Body:', JSON.stringify(req.body, null, 2));

        let user = await User.findOne({ firebaseUid });

        if (!user && email) {
            // Fallback: Check if user exists with the same email
            user = await User.findOne({ email });
        }

        if (user) {
            console.log('Updating existing user:', user._id);
            // Explicitly update only if fields are provided in the body
            if (name !== undefined) user.name = name;
            if (email !== undefined) user.email = email;
            if (firebaseUid !== undefined) user.firebaseUid = firebaseUid;
            if (photoUrl !== undefined) user.photoUrl = photoUrl;
            if (phone !== undefined) user.phone = phone;
            if (fcmToken !== undefined) user.fcmToken = fcmToken;
            if (role !== undefined) user.role = role;

            await user.save();
            console.log('User updated successfully');
            return res.status(200).json({ msg: 'User updated', user });
        } else {
            console.log('Creating new user');
            user = new User({
                name: name || 'User',
                email,
                firebaseUid,
                photoUrl: photoUrl || '',
                phone: phone || '',
                fcmToken: fcmToken || '',
                role: role || 'user'
            });
            await user.save();
            console.log('User registered successfully');
            return res.status(201).json({ msg: 'User registered', user });
        }
    } catch (err) {
        console.error('Register/Update Error:', err.message);
        res.status(500).json({ error: 'Server Error', details: err.message });
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

// Delete User by Firebase UID
exports.deleteUser = async (req, res) => {
    try {
        const user = await User.findOneAndDelete({ firebaseUid: req.params.firebaseUid });
        if (!user) {
            return res.status(404).json({ msg: 'User not found' });
        }
        res.json({ msg: 'User deleted successfully' });
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};
