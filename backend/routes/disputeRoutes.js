const express = require('express');
const router = express.Router();
const disputeController = require('../controllers/disputeController');

router.post('/', disputeController.createDispute);
router.get('/', disputeController.getAllDisputes);
router.get('/:id', disputeController.getDisputeById);
router.put('/:id/status', disputeController.updateDisputeStatus);

module.exports = router;
