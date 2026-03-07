const Technician = require('../models/Technician');

// Create or Update Technician (Upsert)
exports.registerTechnician = async (req, res) => {
    console.log('Register Technician Request Body:', JSON.stringify(req.body, null, 2));
    try {
        const {
            name, email, firebaseUid, photoUrl, phone, role,
            dob, gender, city, serviceAreaRadius,
            kycType, kycNumber, kycDocumentFront, kycDocumentBack,
            brandExpertise, repairExpertise,
            serviceTypes, coverageAreas,
            bankName, accountHolderName, accountNumber, ifscCode, upiId,
            agreedToTerms, isOnline, fcmToken
        } = req.body;

        // Check if technician exists
        let technician = await Technician.findOne({ firebaseUid });

        if (!technician) {
            // Fallback: Check if technician exists with the same email
            technician = await Technician.findOne({ email: email?.toLowerCase() });
        }

        if (technician) {
            // Update existing
            const fieldsToUpdate = {
                name,
                email: email?.toLowerCase(),
                firebaseUid, // Link to the new UID if we found by email
                photoUrl, phone, role,
                dob, gender, city, serviceAreaRadius,
                kycType, kycNumber, kycDocumentFront, kycDocumentBack,
                brandExpertise, repairExpertise,
                serviceTypes, coverageAreas,
                bankName, accountHolderName, accountNumber, ifscCode, upiId,
                agreedToTerms, isOnline, fcmToken
            };

            // Only update fields that are present in the request and not empty/null
            Object.keys(fieldsToUpdate).forEach(key => {
                const newValue = fieldsToUpdate[key];
                const oldValue = technician[key];

                if (newValue !== undefined) {
                    // Explicitly handle booleans
                    if (key === 'isOnline' || key === 'agreedToTerms') {
                        technician[key] = newValue === true || newValue === 'true';
                        return;
                    }

                    // Special protection: don't overwrite existing data with null/empty if we already have it
                    // This is common during social login sync where provider might return null for phone/photo
                    if ((newValue === null || newValue === '') && (oldValue !== null && oldValue !== '' && oldValue !== undefined)) {
                        console.log(`Skipping update for ${key} because new value is empty and old value exists`);
                        return;
                    }

                    technician[key] = newValue;
                }
            });

            if (agreedToTerms && !technician.agreementDate) {
                technician.agreementDate = new Date();
            }

            await technician.save();

            // Emit status update if isOnline was changed
            if (fieldsToUpdate.isOnline !== undefined) {
                const io = req.app.get('io');
                io.emit('technicianStatusUpdate', {
                    technicianId: technician._id,
                    isOnline: technician.isOnline
                });
            }

            return res.status(200).json({ msg: 'Technician updated', technician });
        } else {
            // Create new
            technician = new Technician({
                name,
                email: email?.toLowerCase(),
                firebaseUid, photoUrl, phone, role,
                dob, gender, city, serviceAreaRadius,
                kycType, kycNumber, kycDocumentFront, kycDocumentBack,
                brandExpertise, repairExpertise,
                serviceTypes, coverageAreas,
                bankName, accountHolderName, accountNumber, ifscCode, upiId,
                agreedToTerms,
                isOnline,
                fcmToken: fcmToken || '',
                status: 'pending'
            });
            if (agreedToTerms) technician.agreementDate = new Date();

            await technician.save();
            return res.status(201).json({ msg: 'Technician registered', technician });
        }
    } catch (err) {
        console.error('Error in registerTechnician:', err);
        if (err.name === 'ValidationError') {
            return res.status(400).json({ msg: 'Validation Error', errors: err.errors });
        }
        res.status(500).json({ msg: 'Server Error', error: err.message });
    }
};

// Get Technician by Firebase UID
// Get Technician by Firebase UID
exports.getTechnician = async (req, res) => {
    try {
        const technician = await Technician.findOne({ firebaseUid: req.params.firebaseUid })
            .populate('brandExpertise')
            .populate('repairExpertise');

        if (!technician) {
            return res.status(404).json({ msg: 'Technician not found' });
        }
        res.json(technician);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};

// Get All Technicians
exports.getAllTechnicians = async (req, res) => {
    try {
        const technicians = await Technician.find()
            .populate('brandExpertise')
            .populate('repairExpertise')
            .sort({ createdAt: -1 });
        if (technicians.length > 0) {
            console.log('Sample Technician Brand Expertise:', JSON.stringify(technicians[0].brandExpertise, null, 2));
            console.log('Sample Technician Repair Expertise:', JSON.stringify(technicians[0].repairExpertise, null, 2));
        }
        res.json(technicians);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};

// Delete Technician
exports.deleteTechnician = async (req, res) => {
    try {
        const technician = await Technician.findById(req.params.id);
        if (!technician) {
            return res.status(404).json({ msg: 'Technician not found' });
        }
        await technician.deleteOne();
        res.json({ msg: 'Technician removed' });
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};

// Delete Technician by Firebase UID
exports.deleteTechnicianByUid = async (req, res) => {
    try {
        const technician = await Technician.findOneAndDelete({ firebaseUid: req.params.firebaseUid });
        if (!technician) {
            return res.status(404).json({ msg: 'Technician not found' });
        }
        res.json({ msg: 'Technician deleted successfully' });
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};

// Update Technician Status / Assign Task (Generic Update by ID)
exports.updateTechnicianById = async (req, res) => {
    try {
        const { status, currentTask } = req.body;
        // Build object to update
        const updateFields = {};
        if (status) updateFields.status = status;
        if (currentTask) updateFields.currentTask = currentTask; // illustrative

        let technician = await Technician.findById(req.params.id);
        if (!technician) return res.status(404).json({ msg: 'Technician not found' });

        technician = await Technician.findByIdAndUpdate(
            req.params.id,
            { $set: updateFields },
            { new: true }
        );

        res.json(technician);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};
