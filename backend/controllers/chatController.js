const Chat = require('../models/Chat');
const Message = require('../models/Message');
const Booking = require('../models/Booking');
const Notification = require('../models/Notification');

// Get or Create Chat for a booking
exports.getOrCreateChat = async (req, res) => {
    try {
        const { bookingId } = req.body;
        console.log(`[CHAT] getOrCreateChat request for bookingId: ${bookingId}`);

        // Find the booking to get user and technician IDs
        const booking = await Booking.findById(bookingId);
        if (!booking) {
            console.log(`[CHAT] Booking not found: ${bookingId}`);
            return res.status(404).json({ msg: 'Booking not found' });
        }

        if (!booking.technicianId) {
            console.log(`[CHAT] Technician not assigned for booking: ${bookingId}`);
            return res.status(400).json({ msg: 'Technician not assigned to this booking yet' });
        }

        let chat = await Chat.findOne({ bookingId });

        if (!chat) {
            console.log(`[CHAT] Creating new chat session for booking: ${bookingId}`);
            chat = new Chat({
                bookingId,
                userId: booking.userId,
                technicianId: booking.technicianId
            });
            await chat.save();
            console.log(`[CHAT] New chat created: ${chat._id}`);
        } else {
            console.log(`[CHAT] Existing chat found: ${chat._id}`);
        }

        res.json(chat);
    } catch (err) {
        console.error('[CHAT ERROR] getOrCreateChat:', err);
        res.status(500).send('Server Error');
    }
};

// Get messages for a chat
exports.getChatMessages = async (req, res) => {
    try {
        console.log(`[CHAT] Fetching messages for chatId: ${req.params.chatId}`);
        const messages = await Message.find({ chatId: req.params.chatId })
            .sort({ createdAt: 1 });
        res.json(messages);
    } catch (err) {
        console.error('[CHAT ERROR] getChatMessages:', err);
        res.status(500).send('Server Error');
    }
};

// Send a message
exports.sendMessage = async (req, res) => {
    try {
        const { chatId, senderId, senderRole, text } = req.body;
        console.log(`[CHAT] sendMessage from ${senderRole} (${senderId}) in chat ${chatId}`);

        const newMessage = new Message({
            chatId,
            senderId,
            senderRole,
            text
        });

        const savedMessage = await newMessage.save();
        console.log(`[CHAT] Message saved: ${savedMessage._id}`);

        // Update last message in Chat
        // Update last message in Chat
        const chat = await Chat.findByIdAndUpdate(chatId, {
            lastMessage: {
                text,
                senderId,
                timestamp: Date.now()
            },
            updatedAt: Date.now()
        }, { new: true }); // Get updated doc? Not strictly needed for logic but good practice

        // --- Socket.IO Emission for Realtime Chat ---
        const io = req.app.get('io');
        if (io) {
            io.to(chatId).emit('receive_message', savedMessage);
            console.log(`[SOCKET] Emitted receive_message to room ${chatId}`);
        }

        // --- Notification Logic ---
        let recipientId = null;
        if (senderRole === 'user') {
            recipientId = chat.technicianId ? chat.technicianId.toString() : null;
        } else {
            recipientId = chat.userId ? chat.userId.toString() : null;
        }

        if (recipientId) {
            // Create in-app notification
            const notification = new Notification({
                userId: recipientId,
                title: 'New Message',
                message: text,
                type: 'info',
                bookingId: chat.bookingId,
                seen: false
            });
            await notification.save();

            // Emit notification event to recipient's room
            if (io) {
                io.to(recipientId).emit('new_notification', notification);
                console.log(`[SOCKET] Emitted new_notification to user ${recipientId}`);
            }
        }

        res.json(savedMessage);
    } catch (err) {
        console.error('[CHAT ERROR] sendMessage:', err);
        res.status(500).send('Server Error');
    }
};
