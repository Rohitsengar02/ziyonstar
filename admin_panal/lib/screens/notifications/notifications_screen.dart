import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../services/api_service.dart';
import '../disputes/dispute_detail_screen.dart';

class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  State<AdminNotificationsScreen> createState() =>
      _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
  List<dynamic> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    try {
      final notifications = await ApiService().getAdminNotifications();
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching notification: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleNotificationTap(dynamic notification) async {
    // Mark as seen
    if (notification['seen'] == false) {
      await ApiService().markAdminNotificationAsSeen(notification['_id']);
    }

    // Navigate to relevant screen
    if (notification['disputeId'] != null) {
      // We need to fetch the full dispute object or pass enough data
      // For now we navigate to disputes screen or a specific detail if we had it
      // Let's try to navigate to detail if possible
      try {
        final disputes = await ApiService().getDisputes();
        final dispute = disputes.firstWhere(
          (d) => d['_id'] == notification['disputeId'],
          orElse: () => null,
        );

        if (dispute != null && mounted) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DisputeDetailScreen(dispute: dispute),
            ),
          );
          _fetchNotifications(); // Refresh seen status
        }
      } catch (e) {
        debugPrint('Error navigating to dispute: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw),
            onPressed: () {
              setState(() => _isLoading = true);
              _fetchNotifications();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.bellOff, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: GoogleFonts.poppins(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final n = _notifications[index];
                return _buildNotificationCard(n);
              },
            ),
    );
  }

  Widget _buildNotificationCard(dynamic n) {
    bool isSeen = n['seen'] ?? false;
    String type = n['type'] ?? 'info';
    IconData icon;
    Color color;

    switch (type) {
      case 'error':
        icon = LucideIcons.alertCircle;
        color = Colors.red;
        break;
      case 'warning':
        icon = LucideIcons.alertTriangle;
        color = Colors.orange;
        break;
      case 'success':
        icon = LucideIcons.checkCircle;
        color = Colors.green;
        break;
      default:
        icon = LucideIcons.bell;
        color = Colors.blue;
    }

    return GestureDetector(
      onTap: () => _handleNotificationTap(n),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSeen ? Colors.white : Colors.blue.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSeen ? Colors.grey.shade100 : Colors.blue.withOpacity(0.2),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        n['title'] ?? 'Notification',
                        style: GoogleFonts.inter(
                          fontWeight: isSeen
                              ? FontWeight.w600
                              : FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      if (!isSeen)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    n['message'] ?? '',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatTime(n['createdAt']),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr).toLocal();
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 1) return 'Just now';
      if (difference.inHours < 1) return '${difference.inMinutes}m ago';
      if (difference.inDays < 1) return '${difference.inHours}h ago';
      return '${difference.inDays}d ago';
    } catch (e) {
      return '';
    }
  }
}
