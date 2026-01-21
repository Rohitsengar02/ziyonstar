const User = require('../models/User');

// Register or Update User (Upsert)
exports.registerUser = async (req, res) => {
    try {
        const { name, email, firebaseUid, photoUrl, phone, role } = req.body;

        let user = await User.findOne({ firebaseUid });

        if (user) {
            user.name = name || user.name;
            user.email = email || user.email;
            user.photoUrl = photoUrl || user.photoUrl;
            user.phone = phone || user.phone;
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
