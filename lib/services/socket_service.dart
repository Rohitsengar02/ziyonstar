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

  void onTechnicianStatusUpdate(Function(Map<String, dynamic>) callback) {
    if (socket == null) connect();
    socket!.on('technicianStatusUpdate', (data) {
      if (data is Map<String, dynamic>) {
        callback(data);
      } else if (data != null) {
        callback(Map<String, dynamic>.from(data));
      }
    });
  }

  void onJobStarted(Function(Map<String, dynamic>) callback) {
    if (socket == null) connect();
    socket!.on('job_started', (data) {
      if (data is Map<String, dynamic>) {
        callback(data);
      } else if (data != null) {
        callback(Map<String, dynamic>.from(data));
      }
    });
  }

  void dispose() {
    socket?.disconnect();
    socket?.dispose();
    socket = null;
  }
}
