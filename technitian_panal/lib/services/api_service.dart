import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  // Use localhost for Android emulator (10.0.2.2) and local IP for real device testing if needed
  // For web, localhost works fine.
  static String get baseUrl {
    if (kIsWeb) {
      return dotenv.env['BACKEND_URL'] ?? 'http://localhost:5001/api';
    } else {
      // Logic for Android Emulator vs Real Device
      // Often better to use computer's local network IP for real devices
      return dotenv.env['BACKEND_URL'] ?? 'http://10.0.2.2:5001/api';
    }
  }

  // Register technician
  Future<Map<String, dynamic>> registerTechnician({
    required String name,
    required String email,
    required String firebaseUid,
    String? photoUrl,
    String? phone,
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
      rethrow;
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
  }) async {
    final url = Uri.parse('$baseUrl/technicians/register'); // Uses upsert logic

    // Add firebaseUid to data if not present, though body must contain it
    final bodyData = Map<String, dynamic>.from(data);
    bodyData['firebaseUid'] = firebaseUid;

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
}
