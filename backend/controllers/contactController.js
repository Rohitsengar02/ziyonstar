const Contact = require('../models/Contact');
const AdminNotification = require('../models/AdminNotification');

// Create new contact message
exports.createContact = async (req, res) => {
    try {
        const { name, email, phone, message } = req.body;

        const newContact = new Contact({
            name,
            email,
            phone,
            message
        });

        await newContact.save();

        // Create Admin Notification
        try {
            const notification = new AdminNotification({
                title: 'New Support Message',
                message: `New message from ${name}: "${message.substring(0, 30)}..."`,
                type: 'info'
            });
            await notification.save();
        } catch (notifError) {
            console.error('Failed to create admin notification:', notifError);
            // Don't fail the request if notification fails
        }

        res.status(201).json(newContact);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};

// Get all contact messages (for Admin)
exports.getAllContacts = async (req, res) => {
    try {
        const contacts = await Contact.find().sort({ createdAt: -1 });
        res.json(contacts);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};

// Update contact status/reply (for Admin)
exports.updateContact = async (req, res) => {
    try {
        const { status, adminReply } = req.body;
        const contact = await Contact.findById(req.params.id);

        if (!contact) {
            return res.status(404).json({ msg: 'Contact message not found' });
        }

        if (status) contact.status = status;
        if (adminReply) {
            contact.adminReply = adminReply;
            contact.replyDate = Date.now();
        }

        await contact.save();
        res.json(contact);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};

// Delete contact message
exports.deleteContact = async (req, res) => {
    try {
        const contact = await Contact.findById(req.params.id);
        if (!contact) {
            return res.status(404).json({ msg: 'Contact not found' });
        }

        await Contact.deleteOne({ _id: req.params.id });
        res.json({ msg: 'Contact message removed' });
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};
