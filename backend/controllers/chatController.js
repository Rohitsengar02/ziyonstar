const Chat = require('../models/Chat');
const Message = require('../models/Message');
const Booking = require('../models/Booking');

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
        await Chat.findByIdAndUpdate(chatId, {
            lastMessage: {
                text,
                senderId,
                timestamp: Date.now()
            },
            updatedAt: Date.now()
        });

        res.json(savedMessage);
    } catch (err) {
        console.error('[CHAT ERROR] sendMessage:', err);
        res.status(500).send('Server Error');
    }
};
