const express = require('express');
const router = express.Router();
const { upload } = require('../config/cloudinary');
const issueController = require('../controllers/issueController');

router.post('/', upload.single('image'), issueController.createIssue);
router.get('/', issueController.getIssues);
router.put('/:id', upload.single('image'), issueController.updateIssue);
router.delete('/:id', issueController.deleteIssue);

module.exports = router;
