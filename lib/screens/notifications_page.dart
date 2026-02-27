import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../services/notification_service.dart';
import '../services/api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? uid;
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        uid = user.uid;
      } else {
        uid = prefs.getString('user_uid') ?? prefs.getString('user_id');
      }

      if (uid != null) {
        final api = ApiService();
        final mongoUser = await api.getUser(uid);

        // 1. Fetch from MongoDB
        List<Map<String, dynamic>> allNotifs = [];
        if (mongoUser != null) {
          final notifications = await api.getUserNotifications(
            mongoUser['_id'],
          );
          allNotifs = List<Map<String, dynamic>>.from(notifications);
        }

        // 2. Fetch from Firestore (Real-time/Sync backup)
        try {
          final fsSnap = await FirebaseFirestore.instance
              .collection('notifications')
              .where('userId', isEqualTo: uid)
              .orderBy('timestamp', descending: true)
              .limit(50)
              .get();

          for (var doc in fsSnap.docs) {
            final data = doc.data();
            // Basic deduplication using mongoId or localId if present
            final mongoId = data['data']?['mongoId'];
            bool exists = allNotifs.any((n) => n['_id'] == mongoId);

            if (!exists) {
              allNotifs.add({
                'id': doc.id,
                'title': data['title'],
                'message': data['body'],
                'type': data['data']?['type'] ?? 'info',
                'createdAt': (data['timestamp'] as Timestamp?)
                    ?.toDate()
                    .toIso8601String(),
                'seen': data['seen'] ?? false,
                'isFirestore': true,
              });
            }
          }

          // Sort merged list by date
          allNotifs.sort((a, b) {
            final dateA =
                DateTime.tryParse(a['createdAt'] ?? '') ?? DateTime(2000);
            final dateB =
                DateTime.tryParse(b['createdAt'] ?? '') ?? DateTime(2000);
            return dateB.compareTo(dateA);
          });
        } catch (e) {
          debugPrint('Error fetching from Firestore: $e');
        }

        setState(() {
          _notifications = allNotifs;
          _isLoading = false;
        });
        return;
      }

      // Fallback to local if no user or error
      final notifications = await NotificationService.getNotifications();
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading notifications: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _removeNotification(String id, int index) async {
    // For now, let's just mark as seen on backend if possible,
    // or just remove locally from UI if deletion not fully implemented in same way
    setState(() {
      _notifications.removeAt(index);
    });
  }

  Future<void> _clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? uid;
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        uid = user.uid;
      } else {
        uid = prefs.getString('user_uid') ?? prefs.getString('user_id');
      }

      if (uid != null) {
        final api = ApiService();
        final mongoUser = await api.getUser(uid);
        if (mongoUser != null) {
          await api.clearNotifications(mongoUser['_id']);
        }
      }

      await NotificationService.clearAll();
      setState(() {
        _notifications = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All notifications cleared')),
      );
    } catch (e) {
      debugPrint('Error clearing notifications: $e');
    }
  }

  /// When notification is tapped, mark as seen and navigate to bookings
  Future<void> _onNotificationTap(Map<String, dynamic> notif) async {
    // Mark this notification as seen on backend
    if (notif['_id'] != null) {
      await ApiService().markNotificationAsSeen(notif['_id']);
    } else if (notif['id'] != null) {
      await NotificationService.markAsSeen(notif['id']);
    }

    // Navigate to My Bookings page
    context.go('/bookings');
  }

  String _formatNotifTime(dynamic notif) {
    if (notif['time'] != null) return notif['time'];
    if (notif['createdAt'] != null) {
      try {
        final dt = DateTime.parse(notif['createdAt']).toLocal();
        final now = DateTime.now();
        final diff = now.difference(dt);

        if (diff.inSeconds < 60) return 'Just now';
        if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
        if (diff.inHours < 24) return '${diff.inHours}h ago';
        if (diff.inDays < 7) return '${diff.inDays}d ago';

        return '${dt.day}/${dt.month}/${dt.year}';
      } catch (e) {
        return 'Recently';
      }
    }
    return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          "Notifications",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_notifications.isNotEmpty)
            IconButton(
              icon: const Icon(LucideIcons.trash2, color: Colors.red),
              onPressed: () => showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Clear All'),
                  content: const Text(
                    'Are you sure you want to clear all notifications?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _clearAll();
                      },
                      child: const Text(
                        'Clear',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
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
                  Icon(LucideIcons.bellOff, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    "No new notifications",
                    style: GoogleFonts.inter(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "You'll be notified when technicians\naccept or reject your bookings",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: Colors.grey[400],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadNotifications,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final notif = _notifications[index];
                  final isSuccess = notif['type'] == 'success';
                  final isWarning = notif['type'] == 'warning';
                  final isError = notif['type'] == 'error';
                  final isSeen = notif['seen'] == true;
                  final notifId =
                      notif['_id'] ?? notif['id'] ?? index.toString();

                  return Dismissible(
                    key: Key(notifId),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      _removeNotification(notifId, index);
                    },
                    background: Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(
                        LucideIcons.trash2,
                        color: Colors.white,
                      ),
                    ),
                    child: GestureDetector(
                      onTap: () => _onNotificationTap(notif),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSeen ? Colors.grey[50] : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border(
                            left: BorderSide(
                              color: isSuccess
                                  ? Colors.green
                                  : isWarning
                                  ? Colors.orange
                                  : isError
                                  ? Colors.red
                                  : Colors.grey,
                              width: 4,
                            ),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(
                                isSeen ? 0.02 : 0.05,
                              ),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: isSuccess
                                    ? Colors.green.withOpacity(0.1)
                                    : isWarning
                                    ? Colors.orange.withOpacity(0.1)
                                    : isError
                                    ? Colors.red.withOpacity(0.1)
                                    : Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                isSuccess
                                    ? LucideIcons.checkCircle
                                    : isWarning
                                    ? LucideIcons.alertCircle
                                    : isError
                                    ? LucideIcons.alertTriangle
                                    : LucideIcons.bell,
                                color: isSuccess
                                    ? Colors.green
                                    : isWarning
                                    ? Colors.orange
                                    : isError
                                    ? Colors.red
                                    : Colors.grey,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          notif['title'] ?? 'Notification',
                                          style: GoogleFonts.inter(
                                            fontWeight: isSeen
                                                ? FontWeight.w500
                                                : FontWeight.bold,
                                            fontSize: 14,
                                            color: isSeen
                                                ? Colors.grey[600]
                                                : Colors.black87,
                                          ),
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
                                    notif['message'] ?? '',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        LucideIcons.clock,
                                        size: 12,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _formatNotifTime(notif),
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          color: Colors.grey[400],
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        'Tap to view →',
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          color: Colors.blue,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
