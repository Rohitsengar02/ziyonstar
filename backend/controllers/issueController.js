const Issue = require('../models/Issue');

// Create Issue
exports.createIssue = async (req, res) => {
    try {
        if (!req.body) {
            return res.status(400).json({ msg: 'No data provided' });
        }
        const { name, category, base_price, icon } = req.body;
        let imageUrl = '';
        if (req.file) {
            imageUrl = req.file.path;
        }

        const newIssue = new Issue({ name, category, base_price, icon, imageUrl });
        const savedIssue = await newIssue.save();
        res.json(savedIssue);
    } catch (err) {
        console.error(err);
        res.status(500).send('Server Error');
    }
};

// Get All Issues
exports.getIssues = async (req, res) => {
    try {
        const issues = await Issue.find().sort({ createdAt: -1 });
        res.json(issues);
    } catch (err) {
        console.error(err);
        res.status(500).send('Server Error');
    }
};

// Update Issue
exports.updateIssue = async (req, res) => {
    try {
        const { name, category, base_price, icon } = req.body;
        let issue = await Issue.findById(req.params.id);
        if (!issue) return res.status(404).json({ msg: 'Issue not found' });

        issue.name = name || issue.name;
        issue.category = category || issue.category;
        issue.base_price = base_price || issue.base_price;
        issue.icon = icon || issue.icon;
        if (req.file) {
            issue.imageUrl = req.file.path;
        }

        await issue.save();
        res.json(issue);
    } catch (err) {
        console.error(err);
        res.status(500).send('Server Error');
    }
};

// Delete Issue
exports.deleteIssue = async (req, res) => {
    try {
        const issue = await Issue.findById(req.params.id);
        if (!issue) return res.status(404).json({ msg: 'Issue not found' });
        await issue.deleteOne();
        res.json({ msg: 'Issue removed' });
    } catch (err) {
        console.error(err);
        res.status(500).send('Server Error');
    }
};
