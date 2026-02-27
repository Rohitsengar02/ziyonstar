import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  static const String _key = 'user_notifications';
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Initialize Push Notifications
  static Future<void> initialize() async {
    // 1. Request Permission
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted notification permission');
    }

    // 2. Local Notifications Setup (for foreground banners)
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification click when app is in foreground
        debugPrint("Notification clicked: ${details.payload}");
      },
    );

    // Create High Importance Channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    // 3. Listen for Foreground Messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      debugPrint(
        "Message received in foreground: ${message.notification?.title}",
      );

      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      Map<String, dynamic> data = message.data;

      String title = notification?.title ?? data['title'] ?? "New Notification";
      String body = notification?.body ?? data['body'] ?? "";

      // Save to Firestore history
      await saveNotificationToFirestore(title, body, data);

      if (!kIsWeb) {
        _localNotifications.show(
          notification.hashCode,
          title,
          body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: android?.smallIcon,
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
          payload: jsonEncode(data),
        );
      }

      // Save to local list for the notification screen
      addNotification(title: title, message: body, type: 'info');
    });

    // 4. Handle Background Clicks (when app is opened from notification)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("App opened from notification: ${message.data}");
    });
  }

  static Future<void> saveNotificationToFirestore(
    String title,
    String body,
    Map<String, dynamic> data,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('notifications').add({
          'userId': user.uid,
          'receiverId': user.uid,
          'title': title,
          'body': body,
          'data': data,
          'timestamp': FieldValue.serverTimestamp(),
          'seen': false,
          'role': 'user',
        });
        debugPrint("User notification saved to Firestore");
      }
    } catch (e) {
      debugPrint("Error saving user notification to Firestore: $e");
    }
  }

  static Future<void> showNotification(RemoteMessage message) async {
    try {
      debugPrint("User: Processing incoming message for notification tray...");

      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      await _localNotifications.initialize(
        const InitializationSettings(
          android: androidSettings,
          iOS: DarwinInitializationSettings(),
        ),
      );

      RemoteNotification? notification = message.notification;
      Map<String, dynamic> data = message.data;

      String title = data['title'] ?? notification?.title ?? "New Alert";
      String body = data['body'] ?? notification?.body ?? "";

      await saveNotificationToFirestore(title, body, data);

      await _localNotifications.show(
        message.hashCode,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription:
                'This channel is used for important notifications.',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            enableVibration: true,
            playSound: true,
            visibility: NotificationVisibility.public,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: jsonEncode(data),
      );
    } catch (e) {
      debugPrint("Error showing user notification: $e");
    }
  }

  /// Get FCM Token for this device
  static Future<String?> getToken() async {
    try {
      if (kIsWeb) {
        return await _messaging.getToken(
          vapidKey:
              'BN2EVbxicFWSR0pqm12eGK0F2DZcMhY2w3DUQWKJbc3-ldd1R0Nb_vwQabM4cXbjd96c0FMY3Hnc2Mo8OMDKMK0',
        );
      }
      return await _messaging.getToken();
    } catch (e) {
      debugPrint("Error getting FCM token: $e");
      return null;
    }
  }

  /// Get all stored notifications
  static Future<List<Map<String, dynamic>>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_key);
    if (data == null || data.isEmpty) return [];

    try {
      final decoded = jsonDecode(data) as List;
      return decoded
          .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Add a new notification manually
  static Future<void> addNotification({
    required String title,
    required String message,
    required String type, // 'success', 'warning', 'error', 'info'
    String? bookingId,
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
      'seen': false,
      'bookingId': bookingId,
    };

    notifications.insert(0, newNotif);
    if (notifications.length > 50) {
      notifications.removeRange(50, notifications.length);
    }

    await prefs.setString(_key, jsonEncode(notifications));

    // Also persist to Firestore for cross-device syncing
    await saveNotificationToFirestore(title, message, {
      'type': type,
      'bookingId': bookingId,
      'localId': newNotif['id'],
    });
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

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

  static Future<int> getUnseenCount() async {
    final notifications = await getNotifications();
    return notifications.where((n) => n['seen'] == false).length;
  }

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
