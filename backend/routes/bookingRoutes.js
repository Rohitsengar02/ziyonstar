const express = require('express');
const router = express.Router();
const bookingController = require('../controllers/bookingController');

// Create Booking
router.post('/', bookingController.createBooking);

// Get All Bookings (Admin) - Place before specific ID routes
router.get('/', bookingController.getAllBookings);


// Get Booking by ID
router.get('/:id', bookingController.getBooking);

// Get User's Bookings
router.get('/user/:userId', bookingController.getUserBookings);

// Get Technician's Bookings
router.get('/technician/:technicianId', bookingController.getTechnicianBookings);

// Get Technician's Wallet Stats
router.get('/technician/:technicianId/wallet', bookingController.getTechnicianWallet);

// Technician Responds (Accept/Reject)
router.post('/:id/respond', bookingController.respondToBooking);

// Update Booking Status (Technician updates job progress)
router.post('/:id/status', bookingController.updateBookingStatus);

// User Requests Reassignment
router.post('/:id/reassign', bookingController.reassignBooking);

// User Submits Review
router.post('/:id/review', bookingController.submitReview);

module.exports = router;
