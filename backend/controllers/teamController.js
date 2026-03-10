const TeamMember = require('../models/TeamMember');

// @desc    Get all team members
// @route   GET /api/team
// @access  Public
exports.getTeamMembers = async (req, res) => {
    try {
        const team = await TeamMember.find({ isActive: true }).sort({ displayOrder: 1 });
        res.json({ success: true, count: team.length, data: team });
    } catch (error) {
        console.error('Error fetching team members:', error);
        res.status(500).json({ success: false, message: 'Server Error' });
    }
};

// @desc    Add new team member
// @route   POST /api/team
// @access  Private/Admin
exports.addTeamMember = async (req, res) => {
    try {
        const { name, role, image, displayOrder } = req.body;
        
        if (!name || !role || !image) {
            return res.status(400).json({ success: false, message: 'Please provide name, role and image' });
        }

        const teamMember = await TeamMember.create({
            name,
            role,
            image,
            displayOrder
        });

        res.status(201).json({ success: true, data: teamMember });
    } catch (error) {
        console.error('Error adding team member:', error);
        res.status(500).json({ success: false, message: 'Server Error' });
    }
};

// @desc    Update team member
// @route   PUT /api/team/:id
// @access  Private/Admin
exports.updateTeamMember = async (req, res) => {
    try {
        let teamMember = await TeamMember.findById(req.params.id);

        if (!teamMember) {
            return res.status(404).json({ success: false, message: 'Team member not found' });
        }

        teamMember = await TeamMember.findByIdAndUpdate(req.params.id, req.body, {
            new: true,
            runValidators: true
        });

        res.json({ success: true, data: teamMember });
    } catch (error) {
        console.error('Error updating team member:', error);
        res.status(500).json({ success: false, message: 'Server Error' });
    }
};

// @desc    Delete team member
// @route   DELETE /api/team/:id
// @access  Private/Admin
exports.deleteTeamMember = async (req, res) => {
    try {
        const teamMember = await TeamMember.findById(req.params.id);

        if (!teamMember) {
            return res.status(404).json({ success: false, message: 'Team member not found' });
        }

        await teamMember.deleteOne();

        res.json({ success: true, message: 'Team member removed' });
    } catch (error) {
        console.error('Error deleting team member:', error);
        res.status(500).json({ success: false, message: 'Server Error' });
    }
};
