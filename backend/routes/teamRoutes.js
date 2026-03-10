const express = require('express');
const router = express.Router();
const {
    getTeamMembers,
    addTeamMember,
    updateTeamMember,
    deleteTeamMember
} = require('../controllers/teamController');

// All routes are under /api/team
router.get('/', getTeamMembers);
router.post('/', addTeamMember);
router.put('/:id', updateTeamMember);
router.delete('/:id', deleteTeamMember);

module.exports = router;
