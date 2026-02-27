import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static String get baseUrl {
    return dotenv.env['BACKEND_URL'] ?? 'https://ziyonstar.onrender.com/api';
  }

  Future<List<dynamic>> getIssues() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/issues'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch issues');
      }
    } catch (e) {
      debugPrint('Error fetching issues: $e');
      return [];
    }
  }

  Future<List<dynamic>> getBrands() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/brands'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch brands');
      }
    } catch (e) {
      debugPrint('Error fetching brands: $e');
      return [];
    }
  }

  Future<List<dynamic>> getModels(String brandId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/models/$brandId'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load models');
      }
    } catch (e) {
      debugPrint('Error fetching models: $e');
      return [];
    }
  }

  Future<List<dynamic>> getTechnicians() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/technicians'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch technicians');
      }
    } catch (e) {
      debugPrint('Error fetching technicians: $e');
      return [];
    }
  }

  Future<List<dynamic>> getTechnicianReviews(String technicianId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reviews/technician/$technicianId'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching technician reviews: $e');
      return [];
    }
  }

  // ===== ADDRESS APIs =====

  /// Get all addresses for a user
  Future<List<dynamic>> getAddresses(String userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/addresses/$userId'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch addresses');
      }
    } catch (e) {
      debugPrint('Error fetching addresses: $e');
      return [];
    }
  }

  /// Add a new address for a user
  Future<Map<String, dynamic>?> addAddress({
    required String userId,
    required String label,
    required String fullAddress,
    String? landmark,
    String? city,
    String? state,
    String? pincode,
    String? phone,
    double? latitude,
    double? longitude,
    bool isDefault = false,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/addresses/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'label': label,
          'fullAddress': fullAddress,
          'landmark': landmark,
          'city': city,
          'state': state,
          'pincode': pincode,
          'phone': phone,
          'latitude': latitude,
          'longitude': longitude,
          'isDefault': isDefault,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        debugPrint('Failed to add address: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error adding address: $e');
      return null;
    }
  }

  /// Update an existing address
  Future<Map<String, dynamic>?> updateAddress({
    required String addressId,
    String? label,
    String? fullAddress,
    String? landmark,
    String? city,
    String? state,
    String? pincode,
    String? phone,
    bool? isDefault,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/addresses/$addressId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'label': label,
          'fullAddress': fullAddress,
          'landmark': landmark,
          'city': city,
          'state': state,
          'pincode': pincode,
          'phone': phone,
          'isDefault': isDefault,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        debugPrint('Failed to update address: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error updating address: $e');
      return null;
    }
  }

  /// Delete an address
  Future<bool> deleteAddress(String addressId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/addresses/$addressId'),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error deleting address: $e');
      return false;
    }
  }

  /// Set an address as default
  Future<bool> setDefaultAddress(String addressId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/addresses/$addressId/default'),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error setting default address: $e');
      return false;
    }
  }
  // ===== USER APIs =====

  Future<Map<String, dynamic>?> registerUser(
    Map<String, dynamic> userData, {
    String? fcmToken,
  }) async {
    final url = Uri.parse('$baseUrl/users/register');
    debugPrint('ApiService: Registering user at $url');
    try {
      final reqBody = Map<String, dynamic>.from(userData);
      if (fcmToken != null) reqBody['fcmToken'] = fcmToken;

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(reqBody),
      );

      debugPrint('ApiService: Register response code: ${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw 'Failed to register: ${response.statusCode} - ${response.body}';
      }
    } catch (e) {
      debugPrint('ApiService: Error registering user: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getUser(String firebaseUid) async {
    final url = Uri.parse('$baseUrl/users/$firebaseUid');
    debugPrint('ApiService: Getting user from $url');
    try {
      final response = await http.get(url);
      debugPrint('ApiService: GetUser response code: ${response.statusCode}');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw 'Failed to get user: ${response.statusCode}';
      }
    } catch (e) {
      debugPrint('ApiService: Error getting user: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> updateUser(
    String firebaseUid,
    Map<String, dynamic> userData, {
    String? fcmToken,
  }) async {
    final url = Uri.parse('$baseUrl/users/register'); // Upsert logic
    debugPrint('ApiService: Updating user at $url');
    try {
      final data = Map<String, dynamic>.from(userData);
      data['firebaseUid'] = firebaseUid;
      if (fcmToken != null) data['fcmToken'] = fcmToken;
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw 'Failed to update user: ${response.body}';
      }
    } catch (e) {
      debugPrint('ApiService: Error updating user: $e');
      rethrow;
    }
  }

  // ===== UPLOAD API =====
  Future<String?> uploadImage(XFile file) async {
    try {
      var uri = Uri.parse('$baseUrl/upload');
      var request = http.MultipartRequest('POST', uri);

      if (kIsWeb) {
        final bytes = await file.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes('file', bytes, filename: file.name),
        );
      } else {
        request.files.add(await http.MultipartFile.fromPath('file', file.path));
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        final json = jsonDecode(respStr);
        return json['url'];
      } else {
        debugPrint('Upload failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }
  // ===== BOOKING APIs =====

  Future<Map<String, dynamic>?> createBooking(
    Map<String, dynamic> bookingData,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/bookings'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(bookingData),
      );
      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      }
      throw Exception('Failed to create booking: ${response.body}');
    } catch (e) {
      debugPrint('Error creating booking: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> getUserBookings(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/bookings/user/$userId'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      debugPrint('Error getting user bookings: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> reassignBooking(String bookingId) async {
    final url = Uri.parse('$baseUrl/bookings/$bookingId/reassign');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to reassign: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error reassigning: $e');
      return null;
    }
  }

  // ===== NOTIFICATION APIs =====

  Future<List<dynamic>> getUserNotifications(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notifications/user/$userId'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      debugPrint('Error getting user notifications: $e');
      return [];
    }
  }

  Future<bool> markNotificationAsSeen(String notificationId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/notifications/$notificationId/seen'),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error marking notification as seen: $e');
      return false;
    }
  }

  Future<bool> clearNotifications(String userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/notifications/user/$userId'),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error clearing notifications: $e');
      return false;
    }
  }

  // ===== DISPUTE APIs =====
  Future<Map<String, dynamic>?> createDispute({
    required String bookingId,
    required String userId,
    required String reason,
    String? description,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/disputes'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'bookingId': bookingId,
          'userId': userId,
          'reason': reason,
          'description': description,
        }),
      );
      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Error creating dispute: $e');
      return null;
    }
  }

  Future<bool> submitReview({
    required String bookingId,
    required int rating,
    String? reviewText,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/bookings/$bookingId/review'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'rating': rating, 'reviewText': reviewText ?? ''}),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error submitting review: $e');
      return false;
    }
  }

  // ===== CONTACT API =====
  Future<bool> submitContactForm({
    required String name,
    required String email,
    required String phone,
    required String message,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/contact'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'phone': phone,
          'message': message,
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      debugPrint('Error submitting contact form: $e');
      return false;
    }
  }

  // ===== SETTINGS API =====
  Future<Map<String, dynamic>?> getCompanyInfo() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/settings/contact-info'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching company info: $e');
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

  // ===== PAYMENT APIs =====
  Future<Map<String, dynamic>?> createPaymentOrder({
    required String bookingId,
    required double amount,
    required String customerName,
    String? customerEmail,
    required String customerMobile,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/payments/create-order'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'bookingId': bookingId,
          'amount': amount,
          'customerName': customerName,
          'customerEmail': customerEmail,
          'customerMobile': customerMobile,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 400) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Error creating payment order: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> checkPaymentStatus(String txnId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/payments/check-status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'client_txn_id': txnId}),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Error checking payment status: $e');
      return null;
    }
  }
}
