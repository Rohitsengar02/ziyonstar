const Model = require('../models/Model');

// Create a new model
exports.createModel = async (req, res) => {
    try {
        const { brandId, name, price } = req.body;

        if (!brandId || !name || !price) {
            return res.status(400).json({ msg: 'Please provide brandId, name, and price' });
        }

        const newModel = new Model({
            brandId,
            name,
            price
        });

        const savedModel = await newModel.save();
        res.json(savedModel);

    } catch (err) {
        console.error(err);
        res.status(500).send('Server Error');
    }
};

// Update a model
exports.updateModel = async (req, res) => {
    try {
        const { name, price } = req.body;
        let model = await Model.findById(req.params.id);
        if (!model) return res.status(404).json({ msg: 'Model not found' });

        model.name = name || model.name;
        model.price = price || model.price;

        await model.save();
        res.json(model);
    } catch (err) {
        console.error(err);
        res.status(500).send('Server Error');
    }
};

// Get models for a specific brand
exports.getModelsByBrand = async (req, res) => {
    try {
        const models = await Model.find({ brandId: req.params.brandId }).sort({ createdAt: -1 });
        res.json(models);
    } catch (err) {
        console.error(err);
        res.status(500).send('Server Error');
    }
};

// Delete a model
exports.deleteModel = async (req, res) => {
    try {
        const model = await Model.findById(req.params.id);
        if (!model) {
            return res.status(404).json({ msg: 'Model not found' });
        }
        await model.deleteOne();
        res.json({ msg: 'Model removed' });
    } catch (err) {
        console.error(err);
        res.status(500).send('Server Error');
    }
};
