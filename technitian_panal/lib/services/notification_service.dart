import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<void> initialize() async {
    try {
      // 1. Request Permission
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        criticalAlert: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('Technician granted FCM notification permission');
      }

      // Request Android 13+ permission for local notifications
      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();

      // 2. Local Notifications Setup
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
          debugPrint("Technician Notification clicked: ${details.payload}");
        },
      );

      // Create standard high importance channel
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'technician_high_importance',
        'Technician Notifications',
        description: 'Used for new job alerts and updates.',
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

      // 3. Foreground Listener
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint("Foreground message received");
        showNotification(message);
      });
    } catch (e) {
      debugPrint("Notification init error: $e");
    }
  }

  static Future<void> showNotification(RemoteMessage message) async {
    try {
      debugPrint(
        "Technician: Processing incoming message for notification tray...",
      );

      // Basic re-initialization ensures plugin is ready in background isolate
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

      // prioritize data payload for customized "real" notifications
      String title =
          data['title'] ?? notification?.title ?? 'New Repair Request';
      String body =
          data['body'] ??
          notification?.body ??
          'Click to see details and accept.';

      // Save to Firestore history (backup)
      await saveNotificationToFirestore(title, body, data);

      const String channelId = 'technician_high_importance';

      await _localNotifications.show(
        message.hashCode,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            'Technician Notifications',
            channelDescription: 'Used for new job alerts and updates.',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            color: Color(0xFF1E3A8A),
            enableVibration: true,
            playSound: true,
            fullScreenIntent: true, // Crucial for "Uber/Ola" style alerts
            category: AndroidNotificationCategory
                .call, // Makes it behave like an incoming call/alert
            visibility: NotificationVisibility.public,
            styleInformation: BigTextStyleInformation(''),
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            interruptionLevel: InterruptionLevel.critical,
          ),
        ),
        payload: jsonEncode(data),
      );
      debugPrint("Technician: OS Banner pushed successfully.");
    } catch (e) {
      debugPrint("Error showing notification card: $e");
    }
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
          'role': 'technician',
        });
        debugPrint("Notification saved to Firestore");
      }
    } catch (e) {
      debugPrint("Error saving notification to Firestore: $e");
    }
  }

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
}
