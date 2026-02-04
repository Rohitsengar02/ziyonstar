import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';
import '../services/socket_service.dart';

class ChatScreen extends StatefulWidget {
  final String bookingId;
  final String currentUserId;
  final String otherUserName;
  final String senderRole; // 'technician'

  const ChatScreen({
    super.key,
    required this.bookingId,
    required this.currentUserId,
    required this.otherUserName,
    required this.senderRole,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ApiService _apiService = ApiService();
  final SocketService _socketService = SocketService();
  // Socket handled by service

  List<dynamic> _messages = [];
  String? _chatId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    final chatData = await _apiService.getOrCreateChat(widget.bookingId);
    if (chatData != null) {
      if (mounted) {
        setState(() {
          _chatId = chatData['_id'];
        });
      }

      final history = await _apiService.getChatMessages(_chatId!);
      if (mounted) {
        setState(() {
          _messages = history.map((m) => Map<String, dynamic>.from(m)).toList();
          _isLoading = false;
        });
      }
      _scrollToBottom();

      // Connect/Join via Service
      _socketService.joinChat(_chatId!);

      // Listen for messages
      _socketService.onMessage((data) {
        debugPrint('Technician Received Message: $data');
        if (mounted && data != null) {
          setState(() {
            final newMessage = Map<String, dynamic>.from(data);
            // Simple duplicate check
            bool exists = _messages.any(
              (m) =>
                  m['_id'] == newMessage['_id'] || // Check ID if available
                  (m['text'] == newMessage['text'] &&
                      m['createdAt'] == newMessage['createdAt'] &&
                      m['senderId'] == newMessage['senderId']),
            );
            if (!exists) {
              _messages.add(newMessage);
            }
          });
          _scrollToBottom();
        }
      });
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // _connectSocket removed

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _chatId == null) return;

    final messageText = _messageController.text.trim();
    _messageController.clear();

    final messageData = {
      'chatId': _chatId,
      'senderId': widget.currentUserId,
      'senderRole': widget.senderRole,
      'text': messageText,
      'createdAt': DateTime.now().toIso8601String(),
    };

    // Optimistic Update? The socket broadcast will come back to us too in this setup?
    // Usually socket broadcast is to room. Sender is in room. Sender gets it back.
    // If backend emits to room including sender, we don't need optimistic update or we need to dedup.
    // Backend code: io.to(chatId).emit... this sends to everyone in room including sender.
    // So we rely on the listener.

    if (_socketService.socket != null) {
      _socketService.socket!.emit('send_message', messageData);
    }

    try {
      await _apiService.createMessage(
        _chatId!,
        widget.currentUserId,
        widget.senderRole,
        messageText,
      );
    } catch (e) {
      debugPrint('Error saving message: $e');
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _socketService.offMessage();
    // Do not dispose socket service here as it might be used globally
    // _socketService.leaveChat(_chatId); // Optional if implemented
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.otherUserName,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              'Customer',
              style: GoogleFonts.inter(fontSize: 10, color: Colors.blue),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _chatId == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.messageSquare,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Chat Not Available',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This chat session could not be initialized. Please try again later.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      if (msg == null || msg is! Map) {
                        return const SizedBox.shrink();
                      }

                      final mapMsg = Map<String, dynamic>.from(msg);
                      final senderRole = mapMsg['senderRole']?.toString();
                      if (senderRole == null) return const SizedBox.shrink();

                      final isMe = senderRole == 'technician';
                      return _buildMessageBubble(mapMsg, isMe);
                    },
                  ),
                ),
                _buildMessageInput(),
              ],
            ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg, bool isMe) {
    final text = msg['text']?.toString() ?? '';
    final createdAt = msg['createdAt']?.toString();

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue.shade600 : Colors.grey.shade100,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'Customer',
                  style: GoogleFonts.inter(
                    color: Colors.blue.shade700,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Text(
              text,
              style: GoogleFonts.inter(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              createdAt != null ? _formatTimestamp(createdAt) : 'Just now',
              style: GoogleFonts.inter(
                color: isMe ? Colors.white70 : Colors.grey,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(String timestamp) {
    try {
      return DateFormat('hh:mm a').format(DateTime.parse(timestamp));
    } catch (e) {
      return 'Just now';
    }
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: GoogleFonts.inter(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade600,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.send,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
