const Booking = require('../models/Booking');
const Technician = require('../models/Technician');
const Commission = require('../models/Commission');
const Review = require('../models/Review');
const notificationController = require('./notificationController');

// Helper: Find next available technician
// Helper: Find next available technician
const findNextTechnician = async (excludedTechIds = []) => {
    // Find first 'active' OR 'approved' technician not in excluded list
    const tech = await Technician.findOne({
        status: { $in: ['active', 'approved'] },
        _id: { $nin: excludedTechIds }
    });
    return tech;
};

// 1. Create Booking
exports.createBooking = async (req, res) => {
    try {
        const { userId, deviceBrand, deviceModel, issues, totalPrice, scheduledDate, timeSlot, addressId, address, technicianId } = req.body;

        let assignedTech = null;

        // If a technician was specifically selected by the User
        if (technicianId) {
            const selectedTech = await Technician.findById(technicianId);
            if (selectedTech && (selectedTech.status === 'active' || selectedTech.status === 'approved')) {
                assignedTech = selectedTech;
            }
        }

        // If no tech selected or selection failed, try auto-assign
        if (!assignedTech) {
            assignedTech = await findNextTechnician();
        }

        const paymentMethod = req.body.paymentMethod || 'Cash';
        const isOnlinePayment = paymentMethod === 'UPI' || paymentMethod === 'Card';
        const otp = Math.floor(100000 + Math.random() * 900000).toString();

        const newBooking = new Booking({
            userId,
            deviceBrand,
            deviceModel,
            issues,
            totalPrice,
            scheduledDate,
            timeSlot,
            address: addressId || address,
            addressDetails: req.body.addressDetails,
            technicianId: assignedTech ? assignedTech._id : null,
            status: isOnlinePayment
                ? 'Awaiting_Payment'
                : (assignedTech ? 'Pending_Acceptance' : 'Pending_Assignment'),
            paymentMethod: paymentMethod,
            otp
        });

        await newBooking.save();
        console.log(`Booking created: ${newBooking._id} for user: ${userId}`);

        // Notify User
        try {
            await notificationController.createNotification(
                userId,
                'Booking Placed',
                `Your repair for ${deviceBrand} ${deviceModel} has been booked.`,
                'success',
                newBooking._id
            );
            console.log(`Notification triggered for user: ${userId}`);
        } catch (err) {
            console.error(`Failed to notify user: ${err.message}`);
        }

        // Notify Technician if assigned
        if (assignedTech) {
            console.log(`Assigned Technician found: ${assignedTech._id} (${assignedTech.email})`);
            try {
                await notificationController.createNotification(
                    assignedTech._id,
                    'New Job Request!',
                    `You have a new repair request for ${deviceBrand} ${deviceModel}.`,
                    'info',
                    newBooking._id
                );
                console.log(`Notification triggered for technician: ${assignedTech._id}`);
            } catch (err) {
                console.error(`Failed to notify technician: ${err.message}`);
            }
        } else {
            console.warn(`No technician assigned to booking: ${newBooking._id}`);
        }

        res.status(201).json(newBooking);
    } catch (error) {
        console.error('Error in createBooking:', error);
        res.status(500).json({ message: 'Error creating booking', error: error.message });
    }
};

// 2. Get Booking Details
exports.getBooking = async (req, res) => {
    try {
        const booking = await Booking.findById(req.params.id)
            .populate('technicianId', 'name photoUrl phone')
            .populate('userId', 'name email phone')
            .populate('address');
        if (!booking) return res.status(404).json({ message: 'Booking not found' });
        res.json(booking);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching booking', error: error.message });
    }
};

// 3. Get Technician's Bookings
exports.getTechnicianBookings = async (req, res) => {
    try {
        const { technicianId } = req.params;
        const bookings = await Booking.find({
            technicianId,
            status: { $ne: 'Awaiting_Payment' }
        })
            .populate('userId', 'name phone photoUrl')
            .populate('address')
            .sort({ createdAt: -1 });
        res.json(bookings);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching technician bookings', error: error.message });
    }
};


// 4. Technician Respond (Accept/Reject)
exports.respondToBooking = async (req, res) => {
    try {
        const { id } = req.params;
        const { action, reason } = req.body; // action: 'accept' or 'reject'

        const booking = await Booking.findById(id);
        if (!booking) return res.status(404).json({ message: 'Booking not found' });

        if (action === 'accept') {
            booking.status = 'Accepted';
            await booking.save();

            // Notify User
            await notificationController.createNotification(
                booking.userId,
                'Technician Accepted',
                'A technician has accepted your repair booking and will arrive as scheduled.',
                'success',
                booking._id
            );

            return res.json({ message: 'Booking Accepted', booking });
        }

        if (action === 'reject') {
            // Add to history
            booking.rejectedBy.push({
                technicianId: booking.technicianId,
                reason: reason || 'No reason provided',
                rejectedAt: new Date()
            });

            // Set main status to Rejected (waiting for user)
            booking.status = 'Rejected';

            // Clear current tech
            booking.technicianId = null;
            await booking.save();

            // Notify User
            await notificationController.createNotification(
                booking.userId,
                'Booking Rejected',
                'The technician could not accept this job. Please reassign to find another expert.',
                'warning',
                booking._id
            );

            return res.json({ message: 'Booking Rejected', booking });
        }

        res.status(400).json({ message: 'Invalid action' });
    } catch (error) {
        res.status(500).json({ message: 'Error updating booking', error: error.message });
    }
};

// 5. User Requests Reassignment
exports.reassignBooking = async (req, res) => {
    try {
        const { id } = req.params;
        // userId should be verified from token in real app

        const booking = await Booking.findById(id);
        if (!booking) return res.status(404).json({ message: 'Booking not found' });

        if (booking.status !== 'Rejected') {
            return res.status(400).json({ message: 'Booking is not in Rejected state' });
        }

        // Get list of previous rejectors
        const rejectedIds = booking.rejectedBy.map(r => r.technicianId);

        // Find new tech
        const nextTech = await findNextTechnician(rejectedIds);

        if (nextTech) {
            booking.technicianId = nextTech._id;
            booking.status = 'Pending_Acceptance';
            await booking.save();

            // Notify User
            await notificationController.createNotification(
                booking.userId,
                'New Technician Assigned',
                'We have assigned a new technician for your repair.',
                'info',
                booking._id
            );

            // Notify Technician
            await notificationController.createNotification(
                nextTech._id,
                'Urgent: Job Reassigned to You',
                `A repair for ${booking.deviceBrand} has been reassigned to you.`,
                'info',
                booking._id
            );

            return res.json({ message: 'New Technician Assigned', booking });
        } else {
            // Fallback if no tech found
            booking.status = 'Pending_Assignment'; // Back to admin queue
            await booking.save();
            return res.json({ message: 'No available technicians found. Moved to Admin Queue.', booking });
        }

    } catch (error) {
        res.status(500).json({ message: 'Error reassigning booking', error: error.message });
    }
};

// 6. Get User Bookings
exports.getUserBookings = async (req, res) => {
    try {
        const { userId } = req.params;
        const bookings = await Booking.find({ userId })
            .populate('technicianId', 'name photoUrl phone')
            .sort({ createdAt: -1 });
        res.json(bookings);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching user bookings', error: error.message });
    }
};

// 7. Update Booking Status (Technician updates job progress)
exports.updateBookingStatus = async (req, res) => {
    try {
        const { id } = req.params;
        const { status } = req.body;

        const validStatuses = [
            'Pending_Assignment',
            'Pending_Acceptance',
            'Accepted',
            'On_Way',
            'Arrived',
            'In_Progress',
            'Completed',
            'Cancelled',
            'Rejected'
        ];

        if (!validStatuses.includes(status)) {
            return res.status(400).json({ message: 'Invalid status', validStatuses });
        }

        const booking = await Booking.findById(id);
        if (!booking) return res.status(404).json({ message: 'Booking not found' });

        booking.status = status;
        if (status === 'Completed') {
            booking.completedAt = new Date();
            booking.paymentStatus = 'Paid';
        }
        await booking.save();

        // Notify User
        let notifTitle = 'Booking Update';
        let notifMsg = `Your booking status is now ${status.replace('_', ' ')}.`;
        let notifType = 'info';

        if (status === 'Completed') {
            notifTitle = 'Repair Completed';
            notifMsg = 'Your repair has been successfully completed. Thank you!';
            notifType = 'success';
        } else if (status === 'On_Way') {
            notifTitle = 'Technician En Route';
            notifMsg = 'Your technician is on the way and will arrive shortly.';
            notifType = 'info';
        } else if (status === 'Arrived') {
            notifTitle = 'Technician Arrived';
            notifMsg = 'The technician has reached your location and is starting work.';
            notifType = 'success';
        } else if (status === 'Cancelled') {
            notifTitle = 'Booking Cancelled';
            notifMsg = 'Your repair booking has been cancelled.';
            notifType = 'warning';
        }

        await notificationController.createNotification(
            booking.userId,
            notifTitle,
            notifMsg,
            notifType,
            booking._id
        );

        res.json({ success: true, message: `Status updated to ${status}`, booking });
    } catch (error) {
        res.status(500).json({ message: 'Error updating booking status', error: error.message });
    }
};
// 8. Get All Bookings (Admin)
exports.getAllBookings = async (req, res) => {
    try {
        const bookings = await Booking.find()
            .populate('userId', 'name email phone')
            .populate('technicianId', 'name photoUrl phone')
            .populate('address')
            .sort({ createdAt: -1 });
        res.json(bookings);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching all bookings', error: error.message });
    }
};

// 9. Submit Review
exports.submitReview = async (req, res) => {
    try {
        const { id } = req.params;
        const { rating, reviewText } = req.body;

        const booking = await Booking.findById(id).populate('userId', 'name photoUrl');
        if (!booking) return res.status(404).json({ message: 'Booking not found' });

        if (booking.status !== 'Completed') {
            return res.status(400).json({ message: 'Only completed bookings can be reviewed' });
        }

        // Update Booking
        booking.rating = rating;
        booking.reviewText = reviewText;
        booking.reviewed = true;
        await booking.save();

        // Create separate Review document
        const newReview = new Review({
            bookingId: booking._id,
            technicianId: booking.technicianId,
            userId: booking.userId._id,
            rating,
            reviewText,
            userName: booking.userId.name,
            userPhoto: booking.userId.photoUrl
        });
        await newReview.save();

        // Update Technician Stats
        const technician = await Technician.findById(booking.technicianId);
        if (technician) {
            const allReviews = await Review.find({ technicianId: technician._id });
            const completedBookings = await Booking.countDocuments({
                technicianId: technician._id,
                status: 'Completed'
            });

            const total = allReviews.length;
            const avg = total > 0 ? allReviews.reduce((sum, r) => sum + r.rating, 0) / total : 0;

            technician.averageRating = Math.round(avg * 10) / 10; // Round to 1 decimal
            technician.totalReviews = total;
            technician.completedJobs = completedBookings;
            await technician.save();
        }

        res.json({ success: true, message: 'Review submitted successfully', booking, review: newReview });
    } catch (error) {
        res.status(500).json({ message: 'Error submitting review', error: error.message });
    }
};

// 10. Get Technician Wallet
exports.getTechnicianWallet = async (req, res) => {
    try {
        const { technicianId } = req.params;

        // Find all completed bookings for this technician
        const bookings = await Booking.find({
            technicianId,
            status: 'Completed'
        }).sort({ updatedAt: -1 });

        // Get all active commissions
        const commissions = await Commission.find({ isActive: true });

        // Find default commission if any (category 'General' or the first one)
        const defaultComm = commissions.find(c => c.category === 'General') || commissions[0] || { type: 'percentage', value: 10 };

        let totalEarnings = 0;
        let todayEarnings = 0;
        let weekEarnings = 0;
        let monthEarnings = 0;

        const now = new Date();
        const startOfDay = new Date(now.getFullYear(), now.getMonth(), now.getDate());
        const startOfWeek = new Date(now);
        startOfWeek.setDate(now.getDate() - now.getDay());
        const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);

        const activities = bookings.map(b => {
            // Logic to determine commission (since Booking doesn't have category, using default for now or we could check issues)
            let commValue = defaultComm.value;
            let commType = defaultComm.type;

            let earnings = b.totalPrice;
            if (commType === 'percentage') {
                earnings = b.totalPrice * (1 - commValue / 100);
            } else {
                earnings = b.totalPrice - commValue;
            }

            totalEarnings += earnings;
            if (b.updatedAt >= startOfDay) todayEarnings += earnings;
            if (b.updatedAt >= startOfWeek) weekEarnings += earnings;
            if (b.updatedAt >= startOfMonth) monthEarnings += earnings;

            return {
                id: b._id,
                orderId: b._id.toString().substring(0, 8),
                amount: earnings,
                totalPrice: b.totalPrice,
                commission: b.totalPrice - earnings,
                date: b.updatedAt,
                device: `${b.deviceBrand} ${b.deviceModel}`,
                type: 'earnings'
            };
        });

        // Simulate some payouts or just return earnings
        res.json({
            balance: totalEarnings,
            today: todayEarnings,
            week: weekEarnings,
            month: monthEarnings,
            pending: 0, // Placeholder
            activities: activities.slice(0, 20) // Recent 20 transactions
        });

    } catch (error) {
        res.status(500).json({ message: 'Error fetching wallet data', error: error.message });
    }
};

// 11. Verify OTP and Start Job
exports.verifyOtpAndStartJob = async (req, res) => {
    try {
        const { id } = req.params;
        const { otp } = req.body;

        const booking = await Booking.findById(id);
        if (!booking) return res.status(404).json({ message: 'Booking not found' });

        if (booking.otp !== otp) {
            return res.status(400).json({ success: false, message: 'Invalid OTP' });
        }

        booking.otpVerified = true;
        booking.status = 'In_Progress';
        await booking.save();

        // Notify via Socket.io
        const io = req.app.get('io');
        if (io) {
            io.emit('job_started', {
                bookingId: booking._id,
                status: 'In_Progress'
            });
        }

        // Notify User via push notification
        await notificationController.createNotification(
            booking.userId,
            'Job Started',
            `Technician has verified the OTP and started work on your ${booking.deviceBrand}.`,
            'success',
            booking._id
        );

        res.json({ success: true, message: 'OTP verified successfully. Job started.', booking });
    } catch (error) {
        res.status(500).json({ message: 'Error verifying OTP', error: error.message });
    }
};

// 12. Confirm Pickup
exports.confirmPickup = async (req, res) => {
    try {
        const { id } = req.params;
        const { images, deliveryTime } = req.body;

        const booking = await Booking.findById(id);
        if (!booking) return res.status(404).json({ message: 'Booking not found' });

        booking.status = 'Picked_Up';
        booking.pickupDetails = {
            images: images || [],
            deliveryTime: deliveryTime || '',
            isPickedUp: true,
            pickedUpAt: new Date()
        };

        await booking.save();

        // Notify via Socket.io
        const io = req.app.get('io');
        if (io) {
            io.emit('device_picked_up', {
                bookingId: booking._id,
                status: 'Picked_Up',
                pickupDetails: booking.pickupDetails
            });
        }

        // Notify User via push notification
        await notificationController.createNotification(
            booking.userId,
            'Device Picked Up',
            `Technician has picked up your device. Estimated delivery: ${deliveryTime}.`,
            'info',
            booking._id
        );

        res.json({ success: true, message: 'Device picked up successfully.', booking });
    } catch (error) {
        res.status(500).json({ message: 'Error confirming pickup', error: error.message });
    }
};
