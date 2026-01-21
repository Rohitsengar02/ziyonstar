const ExpertiseRequest = require('../models/ExpertiseRequest');
const Technician = require('../models/Technician');

// Technician submits a request
exports.createRequest = async (req, res) => {
    try {
        const { technicianId, brandExpertise, repairExpertise } = req.body;

        const newRequest = new ExpertiseRequest({
            technicianId,
            brandExpertise,
            repairExpertise,
            status: 'pending'
        });

        await newRequest.save();
        res.status(201).json(newRequest);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};

// Admin gets all pending requests
exports.getPendingRequests = async (req, res) => {
    try {
        const requests = await ExpertiseRequest.find({ status: 'pending' })
            .populate('technicianId', 'name email')
            .populate('brandExpertise')
            .populate('repairExpertise');
        res.json(requests);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};

// Admin gets a specific request detail
exports.getRequestById = async (req, res) => {
    try {
        const request = await ExpertiseRequest.findById(req.params.id)
            .populate('technicianId')
            .populate('brandExpertise')
            .populate('repairExpertise');
        if (!request) return res.status(404).json({ msg: 'Request not found' });
        res.json(request);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};

// Admin approves/rejects a request
exports.updateRequestStatus = async (req, res) => {
    try {
        const { status, adminComment } = req.body;
        const request = await ExpertiseRequest.findById(req.params.id);

        if (!request) return res.status(404).json({ msg: 'Request not found' });

        request.status = status;
        if (adminComment) request.adminComment = adminComment;
        request.updatedAt = Date.now();

        if (status === 'approved') {
            // Add new expertise to technician record
            const technician = await Technician.findById(request.technicianId);

            // Add brands (avoid duplicates)
            request.brandExpertise.forEach(brandId => {
                const bIdStr = brandId.toString();
                if (!technician.brandExpertise.some(id => id.toString() === bIdStr)) {
                    technician.brandExpertise.push(brandId);
                }
            });

            // Add repairs (avoid duplicates)
            request.repairExpertise.forEach(issueId => {
                const iIdStr = issueId.toString();
                if (!technician.repairExpertise.some(id => id.toString() === iIdStr)) {
                    technician.repairExpertise.push(issueId);
                }
            });

            await technician.save();
        }

        await request.save();
        res.json(request);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};
