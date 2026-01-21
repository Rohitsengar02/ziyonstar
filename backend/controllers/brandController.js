const Brand = require('../models/Brand');

exports.createBrand = async (req, res) => {
    try {
        const { title, description, icon } = req.body;

        if (!req.file) {
            return res.status(400).json({ msg: 'Image is required' });
        }

        const newBrand = new Brand({
            title,
            description,
            icon,
            imageUrl: req.file.path // Cloudinary URL
        });

        const savedBrand = await newBrand.save();
        res.json(savedBrand);

    } catch (err) {
        console.error(err);
        res.status(500).send('Server Error');
    }
};

exports.getBrands = async (req, res) => {
    try {
        const brands = await Brand.find().sort({ createdAt: -1 });
        res.json(brands);
    } catch (err) {
        console.error(err);
        res.status(500).send('Server Error');
    }
};

exports.updateBrand = async (req, res) => {
    try {
        const { title, description, icon } = req.body;
        let brand = await Brand.findById(req.params.id);
        if (!brand) return res.status(404).json({ msg: 'Brand not found' });

        brand.title = title || brand.title;
        brand.description = description || brand.description;
        brand.icon = icon || brand.icon;
        if (req.file) {
            brand.imageUrl = req.file.path;
        }

        await brand.save();
        res.json(brand);
    } catch (err) {
        console.error(err);
        res.status(500).send('Server Error');
    }
};

exports.deleteBrand = async (req, res) => {
    try {
        const brand = await Brand.findById(req.params.id);
        if (!brand) return res.status(404).json({ msg: 'Brand not found' });
        await brand.deleteOne();
        res.json({ msg: 'Brand removed' });
    } catch (err) {
        console.error(err);
        res.status(500).send('Server Error');
    }
};
