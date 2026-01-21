const Promo = require('../models/Promo');

// Create Promo
exports.createPromo = async (req, res) => {
    try {
        if (!req.body) return res.status(400).json({ msg: 'No data provided' });

        const {
            code, title, description, discountType, discountValue,
            minOrderValue, maxDiscount, validUntil, usageLimit, isActive
        } = req.body;

        let imageUrl = '';
        if (req.file) {
            imageUrl = req.file.path;
        }

        // Check if code exists
        const existingPromo = await Promo.findOne({ code });
        if (existingPromo) {
            return res.status(400).json({ msg: 'Promo code already exists' });
        }

        const newPromo = new Promo({
            code, title, description, discountType, discountValue,
            minOrderValue, maxDiscount, validUntil, usageLimit, isActive, imageUrl
        });

        const savedPromo = await newPromo.save();
        res.status(201).json(savedPromo);
    } catch (err) {
        console.error(err);
        res.status(500).send('Server Error');
    }
};

// Get All Promos
exports.getPromos = async (req, res) => {
    try {
        const promos = await Promo.find().sort({ createdAt: -1 });
        res.json(promos);
    } catch (err) {
        console.error(err);
        res.status(500).send('Server Error');
    }
};

// Get Single Promo by ID
exports.getPromoById = async (req, res) => {
    try {
        const promo = await Promo.findById(req.params.id);
        if (!promo) return res.status(404).json({ msg: 'Promo not found' });
        res.json(promo);
    } catch (err) {
        console.error(err);
        if (err.kind === 'ObjectId') return res.status(404).json({ msg: 'Promo not found' });
        res.status(500).send('Server Error');
    }
};

// Validate Promo Code (Public/User side)
exports.validatePromo = async (req, res) => {
    try {
        const { code, cartTotal } = req.body;
        const promo = await Promo.findOne({ code, isActive: true });

        if (!promo) {
            return res.status(404).json({ msg: 'Invalid or expired promo code', valid: false });
        }

        // Check expiry
        if (promo.validUntil && new Date() > promo.validUntil) {
            return res.status(400).json({ msg: 'Promo code expired', valid: false });
        }

        // Check usage limit
        if (promo.usageLimit && promo.usedCount >= promo.usageLimit) {
            return res.status(400).json({ msg: 'Promo code usage limit reached', valid: false });
        }

        // Check min order value
        if (cartTotal && promo.minOrderValue > cartTotal) {
            return res.status(400).json({
                msg: `Minimum order value of ₹${promo.minOrderValue} required`,
                valid: false
            });
        }

        res.json({ valid: true, promo });
    } catch (err) {
        console.error(err);
        res.status(500).send('Server Error');
    }
};

// Update Promo
exports.updatePromo = async (req, res) => {
    try {
        const promo = await Promo.findById(req.params.id);
        if (!promo) return res.status(404).json({ msg: 'Promo not found' });

        const {
            code, title, description, discountType, discountValue,
            minOrderValue, maxDiscount, validUntil, usageLimit, isActive
        } = req.body;

        promo.code = code || promo.code;
        promo.title = title || promo.title;
        promo.description = description || promo.description;
        promo.discountType = discountType || promo.discountType;
        promo.discountValue = discountValue || promo.discountValue;
        promo.minOrderValue = minOrderValue || promo.minOrderValue;
        promo.maxDiscount = maxDiscount || promo.maxDiscount;
        promo.validUntil = validUntil || promo.validUntil;
        promo.usageLimit = usageLimit || promo.usageLimit;
        if (isActive !== undefined) promo.isActive = isActive;

        if (req.file) {
            promo.imageUrl = req.file.path;
        }

        await promo.save();
        res.json(promo);
    } catch (err) {
        console.error(err);
        res.status(500).send('Server Error');
    }
};

// Delete Promo
exports.deletePromo = async (req, res) => {
    try {
        const promo = await Promo.findById(req.params.id);
        if (!promo) return res.status(404).json({ msg: 'Promo not found' });
        await promo.deleteOne();
        res.json({ msg: 'Promo removed' });
    } catch (err) {
        console.error(err);
        res.status(500).send('Server Error');
    }
};
