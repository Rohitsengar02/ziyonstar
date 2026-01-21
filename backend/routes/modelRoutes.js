const express = require('express');
const router = express.Router();
const modelController = require('../controllers/modelController');

// @route   POST api/models
// @desc    Create a new model
// @access  Public (should be protected)
router.post('/', modelController.createModel);

// @route   GET api/models/:brandId
// @desc    Get all models for a brand
// @access  Public
router.get('/:brandId', modelController.getModelsByBrand);

router.put('/:id', modelController.updateModel);

// @route   DELETE api/models/:id
// @desc    Delete a model
// @access  Public (should be protected)
router.delete('/:id', modelController.deleteModel);

module.exports = router;
