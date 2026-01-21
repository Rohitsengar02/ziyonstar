const express = require('express');
const router = express.Router();
const { upload } = require('../config/cloudinary');
const { createBrand, getBrands, updateBrand, deleteBrand } = require('../controllers/brandController');

router.post('/', upload.single('image'), createBrand);
router.get('/', getBrands);
router.put('/:id', upload.single('image'), updateBrand);
router.delete('/:id', deleteBrand);

module.exports = router;
