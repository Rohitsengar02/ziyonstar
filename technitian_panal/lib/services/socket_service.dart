import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart';
import 'api_service.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? socket;

  void connect() {
    if (socket != null && socket!.connected) return;

    // Use ApiService.baseUrl to get the base URL and remove '/api' suffix
    String socketUrl = ApiService.baseUrl.replaceAll('/api', '');

    debugPrint('🔌 Connecting to Socket.io at: $socketUrl');

    socket = IO.io(socketUrl, <String, dynamic>{
      'transports': ['polling', 'websocket'],
      'autoConnect': true,
      'reconnection': true,
      'reconnectionAttempts': 5,
      'reconnectionDelay': 1000,
    });

    socket!.onConnect((_) {
      debugPrint('✅ Connected to Socket.io');
    });

    socket!.onDisconnect((_) {
      debugPrint('❌ Disconnected from Socket.io');
    });

    socket!.onConnectError((err) {
      debugPrint('⚠️ Socket.io connection error: $err');
    });

    socket!.onError((err) {
      debugPrint('🆘 Socket.io error: $err');
    });
  }

  void register(String userId, String role) {
    if (socket == null || !socket!.connected) connect();
    socket!.emit('register', {'userId': userId, 'role': role});
  }

  void joinChat(String chatId) {
    if (socket != null && socket!.connected) {
      socket!.emit('join_chat', {'chatId': chatId});
      debugPrint('Joined chat: $chatId');
    }
  }

  void leaveChat(String chatId) {
    // If backend supports leave_chat, emit it. Currently just join is enough to receive.
    // To stop receiving, client just stops listening or we could implement leave room on backend.
    // For now, no-op or close socket if specific chat focused.
    // Actually socket room joins are persistent until disconnect.
  }

  void onMessage(Function(dynamic) callback) {
    socket?.on('receive_message', (data) {
      debugPrint('📥 New message received: $data');
      callback(data);
    });
  }

  void offMessage() {
    socket?.off('receive_message');
  }

  void onNotification(Function(dynamic) callback) {
    socket?.on('new_notification', (data) {
      debugPrint('🔔 New notification: $data');
      callback(data);
    });
  }

  void dispose() {
    socket?.disconnect();
    socket?.dispose();
    socket = null;
  }
}
