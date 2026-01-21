const express = require('express');
const router = express.Router();
const technicianController = require('../controllers/technicianController');

// @route   POST api/technicians/register
// @desc    Register or Update Technician
// @access  Public (or protected if you add auth middleware)
router.post('/register', technicianController.registerTechnician);

// @route   GET api/technicians/:firebaseUid
// @desc    Get technician by Firebase UID
// @access  Public
router.get('/:firebaseUid', technicianController.getTechnician);

// @route   GET api/technicians
// @desc    Get all technicians
// @access  Public (Admin)
router.get('/', technicianController.getAllTechnicians);

// @route   DELETE api/technicians/:id
// @desc    Delete technician
// @access  Public (Admin)
router.delete('/:id', technicianController.deleteTechnician);

// @route   PUT api/technicians/:id
// @desc    Update technician status/task
// @access  Public (Admin)
router.put('/:id', technicianController.updateTechnicianById);

module.exports = router;
