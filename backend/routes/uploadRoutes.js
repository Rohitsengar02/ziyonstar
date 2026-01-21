const express = require('express');
const router = express.Router();
const { upload } = require('../config/cloudinary');

// Upload single file
router.post('/', (req, res, next) => {
    console.log('Upload request received');
    console.log('Content-Type:', req.headers['content-type']);

    upload.single('file')(req, res, (err) => {
        if (err) {
            console.error('Cloudinary Upload Error:', err);
            console.error('Error name:', err.name);
            console.error('Error message:', err.message);
            console.error('Error code:', err.code);
            return res.status(500).json({
                error: 'Image upload failed',
                details: err.message,
                code: err.code
            });
        }

        if (!req.file) {
            console.log('No file in request');
            console.log('Request body keys:', Object.keys(req.body || {}));
            return res.status(400).json({ msg: 'No file uploaded' });
        }

        console.log('File uploaded successfully:', req.file.path);
        res.json({ url: req.file.path, public_id: req.file.filename });
    });
});

module.exports = router;
