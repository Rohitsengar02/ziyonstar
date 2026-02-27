import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  // Use localhost for Android emulator (10.0.2.2) and local IP for real device testing if needed
  // For web, localhost works fine.
  static String get baseUrl {
    return dotenv.env['BACKEND_URL'] ?? 'https://ziyonstar.onrender.com/api';
  }

  // Register technician
  Future<Map<String, dynamic>> registerTechnician({
    required String name,
    required String email,
    required String firebaseUid,
    String? photoUrl,
    String? phone,
    String? fcmToken,
  }) async {
    final url = Uri.parse('$baseUrl/technicians/register');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'firebaseUid': firebaseUid,
          'photoUrl': photoUrl,
          'phone': phone,
          'fcmToken': fcmToken,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to register: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error registering technician: $e');
      rethrow;
    }
  }

  // Register User (Generic)
  Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String firebaseUid,
    String? photoUrl,
    String? phone,
    String? role,
    String? fcmToken,
  }) async {
    final url = Uri.parse('$baseUrl/users/register');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'firebaseUid': firebaseUid,
          'photoUrl': photoUrl,
          'phone': phone,
          'role': role,
          'fcmToken': fcmToken,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to register user: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error registering user: $e');
      rethrow;
    }
  }

  // Get Technician
  Future<Map<String, dynamic>?> getTechnician(String firebaseUid) async {
    final url = Uri.parse('$baseUrl/technicians/$firebaseUid');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to get technician: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error getting technician: $e');
      // If error, return null to force Onboarding/Welcome if appropriate,
      // but maybe we should show error?
      // For now, let's allow return null to fall through.
      // But rethrow might cause StreamBuilder to receive error?
      // StreamBuilder doesn't catch FutureBuilder errors.
      // FutureBuilder snapshot will have error.
      // Let's NOT rethrow but return null to be safe for now,
      // OR better: debugPrint is enough.
      return null;
    }
  }

  // Upload Image
  Future<String?> uploadImage(dynamic imageFile) async {
    // imageFile can be File (mobile) or XFile (web/mobile) or Uint8List (web)
    // We'll support XFile or File path if possible.
    // Ideally standardize on XFile from image_picker

    final url = Uri.parse('$baseUrl/upload');
    final request = http.MultipartRequest('POST', url);

    // Determine how to add the file based on platform/type
    // Assuming XFile (cross_file) for modern Flutter
    // You'll need to pass XFile

    try {
      if (imageFile != null) {
        // Get the file name and determine extension for content type
        final String fileName = imageFile.name ?? 'image.jpg';
        final String ext = fileName.split('.').last.toLowerCase();
        String mimeType = 'image/jpeg';
        if (ext == 'png') {
          mimeType = 'image/png';
        } else if (ext == 'gif') {
          mimeType = 'image/gif';
        } else if (ext == 'webp') {
          mimeType = 'image/webp';
        }

        // For web, we might need bytes
        if (kIsWeb) {
          // On web, checking path might not work as expected for MultipartFile.fromPath
          // Better to use bytes
          var bytes = await imageFile.readAsBytes();
          request.files.add(
            http.MultipartFile.fromBytes(
              'file',
              bytes,
              filename: fileName,
              contentType: MediaType.parse(mimeType),
            ),
          );
        } else {
          request.files.add(
            await http.MultipartFile.fromPath(
              'file',
              imageFile.path,
              contentType: MediaType.parse(mimeType),
            ),
          );
        }
      }

      debugPrint('Sending upload request to: $url');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('Upload response status: ${response.statusCode}');
      debugPrint('Upload response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['url'];
      } else {
        debugPrint('Image upload failed: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  // Update Technician Profile (Generic for all steps)
  Future<Map<String, dynamic>> updateTechnicianProfile({
    required String firebaseUid,
    required Map<String, dynamic> data,
    String? fcmToken,
  }) async {
    final url = Uri.parse('$baseUrl/technicians/register'); // Uses upsert logic

    // Add firebaseUid to data if not present, though body must contain it
    final bodyData = Map<String, dynamic>.from(data);
    bodyData['firebaseUid'] = firebaseUid;
    if (fcmToken != null) bodyData['fcmToken'] = fcmToken;

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(bodyData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to update profile: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error updating profile: $e');
      rethrow;
    }
  }

  // Update Technician Online Status
  Future<void> updateTechnicianOnlineStatus(
    String firebaseUid,
    bool isOnline,
  ) async {
    final url = Uri.parse('$baseUrl/technicians/register');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'firebaseUid': firebaseUid, 'isOnline': isOnline}),
      );

      debugPrint('Status Update Response: ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to update status: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error updating online status: $e');
      rethrow;
    }
  }

  // Fetch Brands
  Future<List<dynamic>> getBrands() async {
    final url = Uri.parse('$baseUrl/brands');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching brands: $e');
      return [];
    }
  }

  // Fetch Issues (for repair expertise)
  Future<List<dynamic>> getIssues() async {
    final url = Uri.parse('$baseUrl/issues');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching issues: $e');
      return [];
    }
  }

  // Submit expertise request
  Future<Map<String, dynamic>> submitExpertiseRequest({
    required String technicianId,
    required List<String> brandExpertise,
    required List<String> repairExpertise,
  }) async {
    final url = Uri.parse('$baseUrl/expertise/request');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'technicianId': technicianId,
          'brandExpertise': brandExpertise,
          'repairExpertise': repairExpertise,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to submit request: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error submitting expertise request: $e');
      rethrow;
    }
  }

  // Verify OTP and Start Job
  Future<Map<String, dynamic>> verifyOtp(String bookingId, String otp) async {
    final url = Uri.parse('$baseUrl/bookings/$bookingId/verify-otp');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'otp': otp}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return data;
      } else {
        throw data['message'] ?? 'Failed to verify OTP';
      }
    } catch (e) {
      debugPrint('Error verifying OTP: $e');
      rethrow;
    }
  }

  // Fetch Technician Bookings
  Future<List<dynamic>> getTechnicianBookings(String technicianId) async {
    final url = Uri.parse('$baseUrl/bookings/technician/$technicianId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching bookings: $e');
      return [];
    }
  }

  // Respond to Booking
  Future<Map<String, dynamic>> respondToBooking(
    String bookingId,
    String action, {
    String? reason,
  }) async {
    final url = Uri.parse('$baseUrl/bookings/$bookingId/respond');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'action': action, 'reason': reason}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to respond to booking: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error responding to booking: $e');
      rethrow;
    }
  }

  // Get Booking by ID
  Future<Map<String, dynamic>?> getBookingById(String bookingId) async {
    final url = Uri.parse('$baseUrl/bookings/$bookingId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching booking: $e');
      return null;
    }
  }

  // Update Booking Status
  Future<Map<String, dynamic>> updateBookingStatus(
    String bookingId,
    String status,
  ) async {
    final url = Uri.parse('$baseUrl/bookings/$bookingId/status');
    debugPrint('Updating booking status: $bookingId -> $status');
    debugPrint('URL: $url');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': status}),
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to update status: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error updating booking status: $e');
      rethrow;
    }
  }

  // Get Technician Wallet Stats
  Future<Map<String, dynamic>?> getTechnicianWallet(String technicianId) async {
    final url = Uri.parse('$baseUrl/bookings/technician/$technicianId/wallet');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching wallet stats: $e');
      return null;
    }
  }

  // ===== CHAT APIs =====
  Future<Map<String, dynamic>?> getOrCreateChat(String bookingId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat/get-or-create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'bookingId': bookingId}),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting or creating chat: $e');
      return null;
    }
  }

  Future<List<dynamic>> getChatMessages(String chatId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chat/messages/$chatId'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching chat messages: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> createMessage(
    String chatId,
    String senderId,
    String senderRole,
    String text,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat/messages'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'chatId': chatId,
          'senderId': senderId,
          'senderRole': senderRole,
          'text': text,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Error creating message: $e');
      return null;
    }
  }

  // Confirm Pickup
  Future<Map<String, dynamic>> confirmPickup({
    required String bookingId,
    required List<String> images,
    required String deliveryTime,
  }) async {
    final url = Uri.parse('$baseUrl/bookings/$bookingId/pickup');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'images': images, 'deliveryTime': deliveryTime}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to confirm pickup: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error confirming pickup: $e');
      rethrow;
    }
  }

  // Test Notification
  Future<void> triggerTestNotification(String firebaseUid) async {
    final url = Uri.parse('$baseUrl/notifications/test');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'firebaseUid': firebaseUid}),
      );
      if (response.statusCode != 200) {
        throw Exception('Server error: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error triggering test notification: $e');
      rethrow;
    }
  }
}
