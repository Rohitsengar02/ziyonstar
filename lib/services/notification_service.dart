import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static const String _key = 'user_notifications';

  /// Get all stored notifications
  static Future<List<Map<String, dynamic>>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_key);
    if (data == null || data.isEmpty) return [];
    
    try {
      final decoded = jsonDecode(data) as List;
      return decoded.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Add a new notification
  static Future<void> addNotification({
    required String title,
    required String message,
    required String type, // 'success', 'warning', 'error'
    String? bookingId, // Optional booking ID for navigation
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final notifications = await getNotifications();
    
    final newNotif = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'message': message,
      'type': type,
      'time': _formatTime(DateTime.now()),
      'timestamp': DateTime.now().toIso8601String(),
      'seen': false, // Track if notification has been seen
      'bookingId': bookingId,
    };
    
    // Add new notification at the beginning (most recent first)
    notifications.insert(0, newNotif);
    
    // Keep only the last 50 notifications
    if (notifications.length > 50) {
      notifications.removeRange(50, notifications.length);
    }
    
    await prefs.setString(_key, jsonEncode(notifications));
  }

  /// Clear all notifications
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  /// Remove a specific notification by ID
  static Future<void> removeNotification(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final notifications = await getNotifications();
    notifications.removeWhere((n) => n['id'] == id);
    await prefs.setString(_key, jsonEncode(notifications));
  }

  /// Mark a notification as seen
  static Future<void> markAsSeen(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final notifications = await getNotifications();
    
    for (var notif in notifications) {
      if (notif['id'] == id) {
        notif['seen'] = true;
        break;
      }
    }
    
    await prefs.setString(_key, jsonEncode(notifications));
  }

  /// Mark all notifications as seen
  static Future<void> markAllAsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    final notifications = await getNotifications();
    
    for (var notif in notifications) {
      notif['seen'] = true;
    }
    
    await prefs.setString(_key, jsonEncode(notifications));
  }

  /// Get UNSEEN notification count (for badge)
  static Future<int> getUnseenCount() async {
    final notifications = await getNotifications();
    return notifications.where((n) => n['seen'] != true).length;
  }

  /// Get total notification count
  static Future<int> getCount() async {
    final notifications = await getNotifications();
    return notifications.length;
  }

  static String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
