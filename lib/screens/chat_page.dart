import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme.dart';
import '../responsive.dart';
import '../widgets/navbar.dart'; // Assume we might want a navbar on desktop
import '../widgets/app_drawer.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _messages = [
    {
      'sender': 'technician',
      'text':
          'Hi, I received your request for the iPhone 13 Pro screen repair.',
      'time': '10:00 AM',
    },
    {
      'sender': 'user',
      'text': 'Yes, the screen is cracked but touch is working.',
      'time': '10:02 AM',
    },
    {
      'sender': 'technician',
      'text': 'Understood. Is the display flickering or showing lines?',
      'time': '10:03 AM',
    },
    {
      'sender': 'user',
      'text': 'No lines, just the glass is broken.',
      'time': '10:05 AM',
    },
    {
      'sender': 'technician',
      'text':
          'Great! That usually means we can replace just the glass layer. I will be there by 4 PM.',
      'time': '10:06 AM',
    },
  ];

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    setState(() {
      _messages.add({
        'sender': 'user',
        'text': _messageController.text,
        'time': '${TimeOfDay.now().hour}:${TimeOfDay.now().minute}',
      });
      _messageController.clear();
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveLayout.isDesktop(context);

    // On mobile, we might want to return just the chat part in a Scaffold.
    // On desktop, we want a full layout with Navbar maybe, or just the 3-pane split.
    // The prompt implies a full page. I'll stick to the 3-pane content area.

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[50], // Light background for the whole page
      drawer: !isDesktop ? const AppDrawer() : null, // Drawer only on mobile
      body: Column(
        children: [
          // Navbar on Desktop
          if (isDesktop)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              child: Navbar(scaffoldKey: _scaffoldKey),
            )
          else
            // Mobile Header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      LucideIcons.arrowLeft,
                      color: AppColors.textHeading,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const CircleAvatar(
                    backgroundImage: AssetImage(
                      'assets/images/tech_avatar_1.png',
                    ),
                    radius: 20,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rahul Sharma',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textHeading,
                        ),
                      ),
                      Text(
                        'Online',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(
                      LucideIcons.phone,
                      color: AppColors.primaryButton,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

          // Main Content Area
          Expanded(
            child: isDesktop
                ? Row(
                    children: [
                      // LEFT: Technician Profile (Desktop Only)
                      Expanded(flex: 3, child: _buildTechnicianSidebar()),

                      // CENTER: Chat Area
                      Expanded(flex: 6, child: _buildChatArea(isDesktop)),

                      // RIGHT: User Data (Desktop Only)
                      Expanded(flex: 3, child: _buildUserSidebar()),
                    ],
                  )
                : _buildChatArea(isDesktop), // Mobile just shows chat
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicianSidebar() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Profile Header
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primaryButton.withOpacity(0.1),
                width: 2,
              ),
            ),
            child: const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/images/tech_avatar_1.png'),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Rahul Sharma',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Expert Technician',
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.textBody),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Available Now',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Stats
          _buildTechDetailRow(LucideIcons.star, 'Rating', '4.8 (120 reviews)'),
          _buildTechDetailRow(LucideIcons.briefcase, 'Experience', '5+ Years'),
          _buildTechDetailRow(
            LucideIcons.award,
            'Certified',
            'Apple & Samsung',
          ),
          _buildTechDetailRow(LucideIcons.mapPin, 'Location', 'Mumbai, India'),

          const Spacer(),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(LucideIcons.user),
              label: const Text('View Full Profile'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
                foregroundColor: AppColors.primaryButton,
                side: const BorderSide(color: AppColors.primaryButton),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.heroBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryButton, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textBody,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textHeading,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserSidebar() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Customer Details',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.heroBg,
                child: Icon(LucideIcons.user, color: AppColors.textHeading),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'John Doe',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Premium Member',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.accentYellow,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 32),

          Text(
            'Device Info',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textBody,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.heroBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(
                  LucideIcons.smartphone,
                  color: AppColors.primaryButton,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'iPhone 13 Pro',
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Broken Screen',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          Text(
            'Shared Files',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textBody,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          _buildFileItem('screenshot_1.jpg', '2.4 MB'),
          _buildFileItem('invoice_2023.pdf', '1.2 MB'),
          _buildFileItem('error_log.txt', '12 KB'),
        ],
      ),
    );
  }

  Widget _buildFileItem(String name, String size) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.file, size: 20, color: Colors.grey.shade400),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  size,
                  style: GoogleFonts.inter(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          Icon(LucideIcons.download, size: 16, color: Colors.grey.shade400),
        ],
      ),
    );
  }

  Widget _buildChatArea(bool isDesktop) {
    return Container(
      margin: isDesktop ? const EdgeInsets.symmetric(vertical: 24) : null,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: isDesktop ? BorderRadius.circular(24) : null,
        boxShadow: isDesktop
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          if (isDesktop)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundImage: AssetImage(
                      'assets/images/tech_avatar_1.png',
                    ),
                    radius: 24,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rahul Sharma',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Technician - Online',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(LucideIcons.search),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(LucideIcons.moreVertical),
                  ),
                ],
              ),
            ),

          // Chat Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(24),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isMe = message['sender'] == 'user';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    mainAxisAlignment: isMe
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (!isMe)
                        const CircleAvatar(
                          radius: 16,
                          backgroundImage: AssetImage(
                            'assets/images/tech_avatar_1.png',
                          ),
                        ),

                      const SizedBox(width: 12),

                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isMe
                                ? AppColors.primaryButton
                                : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(20),
                              topRight: const Radius.circular(20),
                              bottomLeft: isMe
                                  ? const Radius.circular(20)
                                  : const Radius.circular(4),
                              bottomRight: isMe
                                  ? const Radius.circular(4)
                                  : const Radius.circular(20),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message['text'],
                                style: GoogleFonts.inter(
                                  color: isMe
                                      ? Colors.white
                                      : AppColors.textHeading,
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                message['time'],
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: isMe
                                      ? Colors.white.withOpacity(0.7)
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Input Area
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade100)),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(LucideIcons.paperclip, color: Colors.grey),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: AppColors.heroBg,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        border: InputBorder.none,
                        hintStyle: GoogleFonts.inter(color: Colors.grey),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: _sendMessage,
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                      ),
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
        ],
      ),
    );
  }
}
