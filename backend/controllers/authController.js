const Admin = require('../models/Admin');
// Note: In production, use bcrypt for password hashing
// const bcrypt = require('bcryptjs'); 

exports.register = async (req, res) => {
    try {
        const { name, email, password, role } = req.body;

        let admin = await Admin.findOne({ email });
        if (admin) return res.status(400).json({ msg: 'Admin already exists' });

        admin = new Admin({
            name,
            email,
            password, // TODO: Hash this password
            role: role || 'admin',
            isApproved: false // Requires Master Admin approval
        });

        await admin.save();
        res.status(201).json({ msg: 'Admin registered. Wait for approval.' });

    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
};

exports.login = async (req, res) => {
    try {
        const { email, password } = req.body;

        const admin = await Admin.findOne({ email });
        if (!admin) return res.status(400).json({ msg: 'Invalid credentials' });

        if (admin.password !== password) { // TODO: Use bcrypt.compare
            return res.status(400).json({ msg: 'Invalid credentials' });
        }

        if (!admin.isApproved) {
            return res.status(403).json({ msg: 'Account pending approval.' });
        }

        const payload = {
            id: admin._id,
            name: admin.name,
            email: admin.email,
            role: admin.role
        };

        // If you want to use JWT: (leaving simpler response for now to match flutter expectation)
        res.json(payload);

    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
};

exports.getPendingAdmins = async (req, res) => {
    try {
        const admins = await Admin.find({ isApproved: false });
        res.json(admins);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
};

exports.getApprovedAdmins = async (req, res) => {
    try {
        const admins = await Admin.find({ isApproved: true, role: { $ne: 'master_admin' } });
        res.json(admins);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
};

exports.approveAdmin = async (req, res) => {
    try {
        const admin = await Admin.findByIdAndUpdate(req.params.id, { isApproved: true }, { new: true });
        res.json(admin);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
};

exports.deleteAdmin = async (req, res) => {
    try {
        await Admin.findByIdAndDelete(req.params.id);
        res.json({ msg: 'Admin removed' });
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
};

exports.updateAdmin = async (req, res) => {
    try {
        const admin = await Admin.findByIdAndUpdate(req.params.id, { $set: req.body }, { new: true });
        res.json(admin);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
};
