import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationService {
  /// Get user's current location
  static Future<Position?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled.');
        return null;
      }

      // Check and request permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permissions are denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permissions are permanently denied');
        return null;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      return position;
    } catch (e) {
      debugPrint('Error getting location: $e');
      return null;
    }
  }

  /// Get address from coordinates using Nominatim (OpenStreetMap) - works on web!
  static Future<String?> getAddressFromCoordinates(
    double lat,
    double lng,
  ) async {
    try {
      // Use Nominatim reverse geocoding (free and works on web)
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1',
      );

      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'ZiyonStarApp/1.0',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['display_name'] != null) {
          return data['display_name'] as String;
        }

        // Try building from address parts if display_name is not available
        if (data['address'] != null) {
          final addr = data['address'];
          List<String> parts = [];

          if (addr['road'] != null) parts.add(addr['road']);
          if (addr['suburb'] != null) parts.add(addr['suburb']);
          if (addr['city'] != null) parts.add(addr['city']);
          if (addr['state'] != null) parts.add(addr['state']);
          if (addr['postcode'] != null) parts.add(addr['postcode']);

          if (parts.isNotEmpty) {
            return parts.join(', ');
          }
        }
      }

      debugPrint('Nominatim response: ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('Error getting address from Nominatim: $e');
      return null;
    }
  }

  /// Get coordinates from address (forward geocoding) using Nominatim
  static Future<LocationCoords?> getCoordinatesFromAddress(
    String address,
  ) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?format=json&q=${Uri.encodeComponent(address)}&limit=1',
      );

      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'ZiyonStarApp/1.0',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          return LocationCoords(
            latitude: double.parse(data[0]['lat']),
            longitude: double.parse(data[0]['lon']),
          );
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error geocoding address: $e');
      return null;
    }
  }

  /// Get structured address from coordinates
  static Future<Map<String, String>?> getStructuredAddressFromCoordinates(
    double lat,
    double lng,
  ) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1',
      );

      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'ZiyonStarApp/1.0',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final addr = data['address'];
        if (addr != null) {
          return {
            'full': data['display_name'] ?? '',
            'road': addr['road'] ?? '',
            'city': addr['city'] ?? addr['town'] ?? addr['village'] ?? '',
            'state': addr['state'] ?? '',
            'postcode': addr['postcode'] ?? '',
            'suburb': addr['suburb'] ?? '',
          };
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error getting structured address: $e');
      return null;
    }
  }
}

/// Simple coordinates class
class LocationCoords {
  final double latitude;
  final double longitude;

  LocationCoords({required this.latitude, required this.longitude});
}

/// Simple location data class with address
class LocationData {
  final double latitude;
  final double longitude;
  final String? address;

  LocationData({required this.latitude, required this.longitude, this.address});
}
