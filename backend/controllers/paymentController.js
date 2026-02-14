const axios = require('axios');
const Booking = require('../models/Booking');

// UPIGateway Configuration (Should be in .env)
const UPI_GATEWAY_KEY = process.env.UPIGATEWAY_KEY;
if (!UPI_GATEWAY_KEY) {
    console.error('CRITICAL: UPIGATEWAY_KEY is not defined in .env');
}
const CREATE_ORDER_URL = 'https://merchant.upigateway.com/api/create_order';
const CHECK_STATUS_URL = 'https://merchant.upigateway.com/api/check_order_status';

exports.createPaymentOrder = async (req, res) => {
    try {
        const { bookingId, amount, customerName, customerEmail, customerMobile } = req.body;

        const booking = await Booking.findById(bookingId);
        if (!booking) {
            return res.status(404).json({ success: false, message: 'Booking not found' });
        }

        const client_txn_id = `TXN_${Date.now()}_${bookingId.substring(0, 5)}`;
        // Clean customer mobile (remove + prefix if exists)
        const cleanMobile = customerMobile.replace('+', '').slice(-10);

        const payload = {
            key: UPI_GATEWAY_KEY,
            client_txn_id: client_txn_id,
            amount: parseFloat(amount), // Send as number
            p_info: `Repair service for ${booking.deviceBrand} ${booking.deviceModel}`,
            customer_name: customerName,
            customer_email: customerEmail || 'customer@ziyonstar.com',
            customer_mobile: cleanMobile,
            redirect_url: process.env.FRONTEND_URL || 'https://ziyonstar.onrender.com/payment-status'
        };

        console.log('UPIGateway Request Payload:', { ...payload, key: '***' });

        const response = await axios.post(CREATE_ORDER_URL, payload, {
            timeout: 15000 // 15 seconds timeout
        });

        console.log('UPIGateway Response:', JSON.stringify(response.data, null, 2));

        if (response.data && response.data.status) {
            // Update booking with transaction ID
            booking.transactionId = client_txn_id;
            booking.paymentDetails = response.data.data; // Store response for reference
            await booking.save();

            // ENTERPRISE FIX: Prioritize bhim_link for direct app opening (Direct Intent)
            // This skips the browser redirect and opens UPI apps directly when scanned.
            let finalUpiUrl = "";
            const intent = response.data.data.upi_intent;

            if (intent && intent.bhim_link) {
                finalUpiUrl = intent.bhim_link;
            } else if (intent && (intent.phonepe_link || intent.paytm_link || intent.gpay_link)) {
                // Fallback to any available intent link if bhim_link is missing
                finalUpiUrl = intent.phonepe_link || intent.paytm_link || intent.gpay_link;
            } else {
                // Fallback to website link if no intent is available
                finalUpiUrl = response.data.data.payment_url || response.data.data.upi_url || "";
            }

            return res.json({
                success: true,
                orderData: {
                    ...response.data.data,
                    upi_url: finalUpiUrl, // API service expects 'upi_url'
                    client_txn_id: client_txn_id // Force include our ID
                }
            });
        } else {
            console.error('UPIGateway Error Response:', response.data);
            return res.status(400).json({
                success: false,
                message: response.data.msg || 'FAILED_TO_CREATE_ORDER',
                details: response.data
            });
        }
    } catch (error) {
        console.error('SERVER_PAYMENT_ERROR:', error.message);
        res.status(500).json({
            success: false,
            message: 'INTERNAL_SERVER_ERROR',
            error: error.message
        });
    }
};

exports.checkPaymentStatus = async (req, res) => {
    try {
        const { client_txn_id, txn_date } = req.body; // txn_date format: DD-MM-YYYY

        const payload = {
            key: UPI_GATEWAY_KEY,
            client_txn_id,
            txn_date: txn_date || new Date().toLocaleDateString('en-GB').replace(/\//g, '-')
        };

        const response = await axios.post(CHECK_STATUS_URL, payload);

        if (response.data && response.data.status) {
            const status = response.data.data.status; // success, failure, pending

            const booking = await Booking.findOne({ transactionId: client_txn_id });
            if (booking) {
                if (status === 'success') {
                    booking.paymentStatus = 'Paid';
                } else if (status === 'failure') {
                    booking.paymentStatus = 'Failed';
                }
                await booking.save();
            }

            return res.json({
                success: true,
                status: status,
                data: response.data.data
            });
        } else {
            return res.status(400).json({
                success: false,
                message: response.data.msg || 'Failed to check payment status'
            });
        }
    } catch (error) {
        console.error('Status Check Error:', error.message);
        res.status(500).json({ success: false, message: 'Internal server error during status check' });
    }
};

// Webhook / Callback handler
exports.paymentWebhook = async (req, res) => {
    try {
        const { client_txn_id, status, remark } = req.body;
        console.log(`Payment Webhook Received: ${client_txn_id} - ${status}`);

        const booking = await Booking.findOne({ transactionId: client_txn_id });
        if (booking) {
            if (status === 'success') {
                booking.paymentStatus = 'Paid';
            } else if (status === 'failure') {
                booking.paymentStatus = 'Failed';
            }
            booking.paymentDetails = { ...booking.paymentDetails, webhookResponse: req.body };
            await booking.save();

            // Notify via Socket.io if available
            const io = req.app.get('io');
            if (io) {
                io.emit('payment_update', {
                    bookingId: booking._id,
                    status: status,
                    client_txn_id: client_txn_id
                });
            }
        }

        res.status(200).send('OK');
    } catch (error) {
        console.error('Webhook Error:', error.message);
        res.status(500).send('Error');
    }
};
