const Commission = require('../models/Commission');

// Create or Update Commission
exports.setCommission = async (req, res) => {
    try {
        const { category, type, value, description, isActive } = req.body;

        let commission = await Commission.findOne({ category });

        if (commission) {
            // Update existing
            commission.type = type || commission.type;
            commission.value = value !== undefined ? value : commission.value;
            commission.description = description || commission.description;
            if (isActive !== undefined) commission.isActive = isActive;
            commission.updatedAt = Date.now();
            await commission.save();
            return res.json(commission);
        }

        // Create new
        const newCommission = new Commission({
            category, type, value, description, isActive
        });
        await newCommission.save();
        res.json(newCommission);

    } catch (err) {
        console.error(err);
        res.status(500).send('Server Error');
    }
};

// Get All Commissions
exports.getCommissions = async (req, res) => {
    try {
        const commissions = await Commission.find();
        res.json(commissions);
    } catch (err) {
        console.error(err);
        res.status(500).send('Server Error');
    }
};

// Get Commission by Category (Internal utility)
exports.getCommissionByCategory = async (req, res) => {
    try {
        const commission = await Commission.findOne({ category: req.params.category });
        if (!commission) return res.status(404).json({ msg: 'Commission not found for this category' });
        res.json(commission);
    } catch (err) {
        console.error(err);
        res.status(500).send('Server Error');
    }
};

// Delete Commission
exports.deleteCommission = async (req, res) => {
    try {
        const commission = await Commission.findById(req.params.id);
        if (!commission) return res.status(404).json({ msg: 'Commission not found' });
        await commission.deleteOne();
        res.json({ msg: 'Commission removed' });
    } catch (err) {
        console.error(err);
        res.status(500).send('Server Error');
    }
};
