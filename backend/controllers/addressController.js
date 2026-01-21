const Address = require('../models/Address');

// Get all addresses for a user
exports.getAddresses = async (req, res) => {
    try {
        const { userId } = req.params;
        const addresses = await Address.find({ userId }).sort({ isDefault: -1, createdAt: -1 });
        res.json(addresses);
    } catch (err) {
        console.error('Error getting addresses:', err);
        res.status(500).json({ error: 'Server Error' });
    }
};

// Add new address
exports.addAddress = async (req, res) => {
    try {
        const { userId } = req.params;
        const { label, fullAddress, landmark, city, state, pincode, phone, isDefault } = req.body;

        // If this is set as default, unset other defaults
        if (isDefault) {
            await Address.updateMany({ userId }, { isDefault: false });
        }

        const newAddress = new Address({
            userId,
            label,
            fullAddress,
            landmark,
            city,
            state,
            pincode,
            phone,
            isDefault: isDefault || false
        });

        const savedAddress = await newAddress.save();
        res.json(savedAddress);
    } catch (err) {
        console.error('Error adding address:', err);
        res.status(500).json({ error: 'Server Error' });
    }
};

// Update address
exports.updateAddress = async (req, res) => {
    try {
        const { id } = req.params;
        const { label, fullAddress, landmark, city, state, pincode, phone, isDefault } = req.body;

        const address = await Address.findById(id);
        if (!address) {
            return res.status(404).json({ error: 'Address not found' });
        }

        // If setting as default, unset other defaults
        if (isDefault && !address.isDefault) {
            await Address.updateMany({ userId: address.userId }, { isDefault: false });
        }

        address.label = label || address.label;
        address.fullAddress = fullAddress || address.fullAddress;
        address.landmark = landmark !== undefined ? landmark : address.landmark;
        address.city = city || address.city;
        address.state = state || address.state;
        address.pincode = pincode || address.pincode;
        address.phone = phone || address.phone;
        address.isDefault = isDefault !== undefined ? isDefault : address.isDefault;

        const updatedAddress = await address.save();
        res.json(updatedAddress);
    } catch (err) {
        console.error('Error updating address:', err);
        res.status(500).json({ error: 'Server Error' });
    }
};

// Delete address
exports.deleteAddress = async (req, res) => {
    try {
        const { id } = req.params;
        const address = await Address.findById(id);

        if (!address) {
            return res.status(404).json({ error: 'Address not found' });
        }

        await address.deleteOne();
        res.json({ msg: 'Address deleted' });
    } catch (err) {
        console.error('Error deleting address:', err);
        res.status(500).json({ error: 'Server Error' });
    }
};

// Set default address
exports.setDefaultAddress = async (req, res) => {
    try {
        const { id } = req.params;
        const address = await Address.findById(id);

        if (!address) {
            return res.status(404).json({ error: 'Address not found' });
        }

        // Unset all other defaults for this user
        await Address.updateMany({ userId: address.userId }, { isDefault: false });

        // Set this one as default
        address.isDefault = true;
        await address.save();

        res.json({ msg: 'Default address updated', address });
    } catch (err) {
        console.error('Error setting default address:', err);
        res.status(500).json({ error: 'Server Error' });
    }
};
