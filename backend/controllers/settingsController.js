const CompanyInfo = require('../models/CompanyInfo');

// Get Company Contact Info
exports.getCompanyInfo = async (req, res) => {
    try {
        let info = await CompanyInfo.findOne();
        if (!info) {
            // Create default if not exists
            info = new CompanyInfo();
            await info.save();
        }
        res.json(info);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};

// Update Company Contact Info
exports.updateCompanyInfo = async (req, res) => {
    try {
        const { phone, email, address, workingHours } = req.body;

        let info = await CompanyInfo.findOne();
        if (!info) {
            info = new CompanyInfo();
        }

        if (phone) info.phone = phone;
        if (email) info.email = email;
        if (address) info.address = address;
        if (workingHours) info.workingHours = workingHours;

        info.updatedAt = Date.now();
        await info.save();

        res.json(info);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};
