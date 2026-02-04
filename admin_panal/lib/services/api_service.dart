import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static String get baseUrl {
    return dotenv.env['BACKEND_URL'] ?? 'https://ziyonstar.onrender.com/api';
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    print('ApiService: Resolved baseUrl is $baseUrl');
    print('ApiService: Attempting login at $baseUrl/auth/login');
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['msg'] ?? 'Login failed');
    }
  }

  Future<void> register(
    String name,
    String email,
    String password,
    String dept,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'role':
            'admin', // department can be added to user model later if needed
      }),
    );

    if (response.statusCode != 201) {
      throw Exception(
        jsonDecode(response.body)['msg'] ?? 'Registration failed',
      );
    }
  }

  Future<void> createBrand(
    String title,
    String description,
    String icon,
    XFile imageFile, // Changed from File to XFile
  ) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/brands'));

    request.fields['title'] = title;
    request.fields['description'] = description;
    request.fields['icon'] = icon;

    final bytes = await imageFile.readAsBytes(); // Read bytes from XFile
    final mimeTypeData = lookupMimeType(
      imageFile.path,
      headerBytes: bytes,
    )?.split('/'); // Updated lookupMimeType

    request.files.add(
      http.MultipartFile.fromBytes(
        // Changed from fromPath to fromBytes
        'image',
        bytes, // Pass bytes
        filename: imageFile.name, // Added filename
        contentType: mimeTypeData != null
            ? MediaType(mimeTypeData[0], mimeTypeData[1])
            : null,
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print('Create Brand Response: ${response.statusCode}');
    print('Create Brand Body: ${response.body}');

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'Failed to create brand: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<List<dynamic>> getBrands() async {
    final response = await http.get(Uri.parse('$baseUrl/brands'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch brands');
    }
  }

  Future<List<dynamic>> getModels(String brandId) async {
    final response = await http.get(Uri.parse('$baseUrl/models/$brandId'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load models');
    }
  }

  Future<void> createModel(String brandId, String name, String price) async {
    final response = await http.post(
      Uri.parse('$baseUrl/models'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'brandId': brandId, 'name': name, 'price': price}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to create model: ${response.body}');
    }
  }

  // Update and Delete Brand
  Future<void> updateBrand(
    String id,
    String title,
    String description,
    String icon,
    XFile? imageFile,
  ) async {
    var request = http.MultipartRequest(
      'PUT',
      Uri.parse('$baseUrl/brands/$id'),
    );
    request.fields['title'] = title;
    request.fields['description'] = description;
    request.fields['icon'] = icon;

    if (imageFile != null) {
      final bytes = await imageFile.readAsBytes();
      final mimeTypeData = lookupMimeType(
        imageFile.path,
        headerBytes: bytes,
      )?.split('/');
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: imageFile.name,
          contentType: mimeTypeData != null
              ? MediaType(mimeTypeData[0], mimeTypeData[1])
              : null,
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(
      streamedResponse,
    ); // Await stream response

    if (response.statusCode != 200)
      throw Exception('Failed to update brand: ${response.body}');
  }

  Future<void> deleteBrand(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/brands/$id'));
    if (response.statusCode != 200) throw Exception('Failed to delete brand');
  }

  // Update and Delete Model
  Future<void> updateModel(
    String id,
    String name,
    String price, {
    List<dynamic>? repairPrices,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/models/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'price': price,
        if (repairPrices != null) 'repairPrices': repairPrices,
      }),
    );
    if (response.statusCode != 200) throw Exception('Failed to update model');
  }

  Future<void> deleteModel(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/models/$id'));
    if (response.statusCode != 200) throw Exception('Failed to delete model');
  }

  // Issues APIs
  Future<List<dynamic>> getIssues() async {
    final response = await http.get(Uri.parse('$baseUrl/issues'));
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load issues');
  }

  Future<void> createIssue(
    String name,
    String category,
    String basePrice,
    String icon,
    XFile? imageFile,
  ) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/issues'));
    request.fields['name'] = name;
    request.fields['category'] = category;
    request.fields['base_price'] = basePrice;
    request.fields['icon'] = icon;

    if (imageFile != null) {
      final bytes = await imageFile.readAsBytes();
      final mimeTypeData = lookupMimeType(
        imageFile.path,
        headerBytes: bytes,
      )?.split('/');
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: imageFile.name,
          contentType: mimeTypeData != null
              ? MediaType(mimeTypeData[0], mimeTypeData[1])
              : null,
        ),
      );
    }

    final response = await request.send();
    if (response.statusCode != 200) throw Exception('Failed to create issue');
  }

  Future<void> updateIssue(
    String id,
    String name,
    String category,
    String basePrice,
    String icon,
    XFile? imageFile,
  ) async {
    var request = http.MultipartRequest(
      'PUT',
      Uri.parse('$baseUrl/issues/$id'),
    );
    request.fields['name'] = name;
    request.fields['category'] = category;
    request.fields['base_price'] = basePrice;
    request.fields['icon'] = icon;

    if (imageFile != null) {
      final bytes = await imageFile.readAsBytes();
      final mimeTypeData = lookupMimeType(
        imageFile.path,
        headerBytes: bytes,
      )?.split('/');
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: imageFile.name,
          contentType: mimeTypeData != null
              ? MediaType(mimeTypeData[0], mimeTypeData[1])
              : null,
        ),
      );
    }

    final response = await request.send();
    if (response.statusCode != 200) throw Exception('Failed to update issue');
  }

  Future<void> deleteIssue(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/issues/$id'));
    if (response.statusCode != 200) throw Exception('Failed to delete issue');
  }

  // Promo APIs
  Future<List<dynamic>> getPromos() async {
    final response = await http.get(Uri.parse('$baseUrl/promos'));
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load promos');
  }

  Future<void> createPromo(Map<String, dynamic> promoData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/promos'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(promoData),
    );
    if (response.statusCode != 201) {
      throw Exception(
        jsonDecode(response.body)['msg'] ?? 'Failed to create promo',
      );
    }
  }

  Future<void> updatePromo(String id, Map<String, dynamic> promoData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/promos/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(promoData),
    );
    if (response.statusCode != 200) {
      throw Exception(
        jsonDecode(response.body)['msg'] ?? 'Failed to update promo',
      );
    }
  }

  Future<void> deletePromo(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/promos/$id'));
    if (response.statusCode != 200) throw Exception('Failed to delete promo');
  }

  // Commission APIs
  Future<List<dynamic>> getCommissions() async {
    final response = await http.get(Uri.parse('$baseUrl/commissions'));
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load commissions');
  }

  Future<void> setCommission(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/commissions'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to set commission');
    }
  }

  Future<void> deleteCommission(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/commissions/$id'));
    if (response.statusCode != 200)
      throw Exception('Failed to delete commission');
  }

  // Technician APIs
  Future<List<dynamic>> getTechnicians() async {
    final response = await http.get(Uri.parse('$baseUrl/technicians'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load technicians');
    }
  }

  Future<void> deleteTechnician(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/technicians/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete technician');
    }
  }

  Future<void> updateTechnician(String id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/technicians/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update technician');
    }
  }

  // Admin Management APIs
  Future<List<Map<String, dynamic>>> getPendingAdmins() async {
    final response = await http.get(Uri.parse('$baseUrl/auth/pending'));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    throw Exception('Failed to fetch pending admins');
  }

  Future<List<Map<String, dynamic>>> getApprovedAdmins() async {
    final response = await http.get(Uri.parse('$baseUrl/auth/approved'));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    throw Exception('Failed to fetch approved admins');
  }

  Future<void> approveAdmin(String id) async {
    final response = await http.put(Uri.parse('$baseUrl/auth/approve/$id'));
    if (response.statusCode != 200) throw Exception('Failed to approve admin');
  }

  Future<void> deleteAdmin(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/auth/remove/$id'));
    if (response.statusCode != 200) throw Exception('Failed to remove admin');
  }

  Future<void> updateAdmin(String id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/auth/update/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode != 200) throw Exception('Failed to update admin');
  }

  // Expertise Request APIs
  Future<List<dynamic>> getPendingExpertiseRequests() async {
    final response = await http.get(
      Uri.parse('$baseUrl/expertise/requests/pending'),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load expertise requests');
  }

  Future<void> updateExpertiseRequestStatus(
    String id,
    String status, {
    String? adminComment,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/expertise/requests/$id/status'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'status': status,
        if (adminComment != null) 'adminComment': adminComment,
      }),
    );
    if (response.statusCode != 200)
      throw Exception('Failed to update request status');
  }

  // Dispute APIs
  Future<List<dynamic>> getDisputes() async {
    final response = await http.get(Uri.parse('$baseUrl/disputes'));
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load disputes');
  }

  Future<void> updateDisputeStatus(
    String id,
    String status, {
    String? adminNotes,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/disputes/$id/status'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'status': status,
        if (adminNotes != null) 'adminNotes': adminNotes,
      }),
    );
    if (response.statusCode != 200)
      throw Exception('Failed to update dispute status');
  }

  // Admin Notification APIs
  Future<List<dynamic>> getAdminNotifications() async {
    final response = await http.get(Uri.parse('$baseUrl/admin-notifications'));
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load admin notifications');
  }

  Future<void> markAdminNotificationAsSeen(String id) async {
    final response = await http.put(
      Uri.parse('$baseUrl/admin-notifications/$id/seen'),
    );
    if (response.statusCode != 200)
      throw Exception('Failed to mark notification as seen');
  }

  // Booking/Order APIs
  Future<List<dynamic>> getBookings() async {
    final response = await http.get(Uri.parse('$baseUrl/bookings'));
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load bookings');
  }

  Future<Map<String, dynamic>> getBooking(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/bookings/$id'));
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load booking details');
  }

  Future<void> updateBookingStatus(String id, String status) async {
    final response = await http.post(
      Uri.parse('$baseUrl/bookings/$id/status'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': status}),
    );
    if (response.statusCode != 200)
      throw Exception('Failed to update booking status');
  }

  // Analytics APIs
  Future<Map<String, dynamic>> getAnalytics() async {
    final response = await http.get(Uri.parse('$baseUrl/analytics'));
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load analytics');
  }

  // Users API
  Future<List<dynamic>> getUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/users'));
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load users');
  }

  // Support/Contact APIs
  Future<List<dynamic>> getContacts() async {
    final response = await http.get(Uri.parse('$baseUrl/contact'));
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load contact messages');
  }

  Future<void> updateContactReply(
    String id,
    String reply,
    String status,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/contact/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'adminReply': reply, 'status': status}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update contact message');
    }
  }

  // Settings/Company Info APIs
  Future<Map<String, dynamic>> getCompanyInfo() async {
    final response = await http.get(
      Uri.parse('$baseUrl/settings/contact-info'),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load company info');
  }

  Future<void> updateCompanyInfo(Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/settings/contact-info'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update company info');
    }
  }

  // ===== ADMIN PROFILE APIs =====
  Future<Map<String, dynamic>> getAdminProfile(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/admin/$id'));
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load profile');
  }

  Future<Map<String, dynamic>> updateAdminProfile(
    String id,
    String name,
    XFile? imageFile,
  ) async {
    var request = http.MultipartRequest('PUT', Uri.parse('$baseUrl/admin/$id'));

    request.fields['name'] = name;

    if (imageFile != null) {
      final bytes = await imageFile.readAsBytes();
      final mimeTypeData = lookupMimeType(
        imageFile.path,
        headerBytes: bytes,
      )?.split('/');

      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: imageFile.name,
          contentType: mimeTypeData != null
              ? MediaType(mimeTypeData[0], mimeTypeData[1])
              : null,
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update profile: ${response.body}');
    }
  }

  Future<void> changeAdminPassword(
    String id,
    String currentPassword,
    String newPassword,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/admin/$id/password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      throw Exception(body['msg'] ?? 'Failed to update password');
    }
  }
}
