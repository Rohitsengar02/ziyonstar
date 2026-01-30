const Admin = require('../models/Admin');
const bcrypt = require('bcryptjs');

// Get Admin Profile
exports.getProfile = async (req, res) => {
    try {
        const admin = await Admin.findById(req.params.id).select('-password');
        if (!admin) {
            return res.status(404).json({ msg: 'Admin not found' });
        }
        res.json(admin);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};

// Update Admin Profile (Name, Image)
exports.updateProfile = async (req, res) => {
    try {
        const { name } = req.body;
        const profileImage = req.file ? req.file.path : undefined;

        const admin = await Admin.findById(req.params.id);
        if (!admin) {
            return res.status(404).json({ msg: 'Admin not found' });
        }

        if (name) admin.name = name;
        if (profileImage) admin.profileImage = profileImage;

        await admin.save();
        res.json(admin);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};

// Change Password
exports.changePassword = async (req, res) => {
    try {
        const { currentPassword, newPassword } = req.body;

        const admin = await Admin.findById(req.params.id);
        if (!admin) {
            return res.status(404).json({ msg: 'Admin not found' });
        }

        // Check if password is hashed (starts with $2a$)
        // If hashed, use bcrypt.compare.
        // If not hashed (legacy plaintext), compare directly.
        let isMatch = false;
        if (admin.password.startsWith('$2a$')) {
            isMatch = await bcrypt.compare(currentPassword, admin.password);
        } else {
            isMatch = admin.password === currentPassword;
        }

        if (!isMatch) {
            return res.status(400).json({ msg: 'Invalid current password' });
        }

        const salt = await bcrypt.genSalt(10);
        admin.password = await bcrypt.hash(newPassword, salt);

        await admin.save();
        res.json({ msg: 'Password updated successfully' });
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};
