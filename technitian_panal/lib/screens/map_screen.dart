import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../services/api_service.dart';
import 'dart:math' show cos, sqrt, asin;

class MapScreen extends StatefulWidget {
  final String orderId;
  final String destination;

  const MapScreen({
    super.key,
    required this.orderId,
    required this.destination,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final ApiService _apiService = ApiService();

  LatLng? _technicianLocation;
  LatLng? _userLocation;
  Map<String, dynamic>? _bookingData;
  bool _isLoading = true;
  Timer? _locationTimer;
  double? _estimatedDistance; // in kilometers
  String? _estimatedTime; // formatted time string

  @override
  void initState() {
    super.initState();
    _initializeNavigation();
    _startLocationTracking();
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeNavigation() async {
    try {
      // Fetch booking details
      final booking = await _apiService.getBookingById(widget.orderId);

      setState(() {
        _bookingData = booking;

        // Get user address location
        if (booking != null) {
          final addressData = booking['address'];
          if (addressData is Map) {
            _userLocation = LatLng(
              addressData['latitude']?.toDouble() ?? 28.6139,
              addressData['longitude']?.toDouble() ?? 77.2090,
            );
          } else {
            _userLocation = LatLng(
              booking['addressLat']?.toDouble() ?? 28.6139,
              booking['addressLng']?.toDouble() ?? 77.2090,
            );
          }
        }

        _isLoading = false;
      });

      // Get technician's current location
      await _updateTechnicianLocation();

      // Center map to show both markers
      if (_technicianLocation != null && _userLocation != null) {
        _fitBounds();
      }
    } catch (e) {
      debugPrint('Error initializing navigation: $e');
      setState(() => _isLoading = false);
    }
  }

  void _startLocationTracking() {
    // Update technician location every 10 seconds
    _locationTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _updateTechnicianLocation();
    });
  }

  Future<void> _updateTechnicianLocation() async {
    try {
      // Get current location from device
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        await Geolocator.requestPermission();
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      setState(() {
        _technicianLocation = LatLng(position.latitude, position.longitude);
        if (_userLocation != null) {
          _calculateDistanceAndTime();
        }
      });
    } catch (e) {
      debugPrint('Error getting technician location: $e');
      // Fallback to default location
      setState(() {
        _technicianLocation = const LatLng(28.6129, 77.2295);
        if (_userLocation != null) {
          _calculateDistanceAndTime();
        }
      });
    }
  }

  void _calculateDistanceAndTime() {
    if (_technicianLocation == null || _userLocation == null) return;

    // Calculate distance using Haversine formula
    final distance = _calculateDistance(
      _technicianLocation!.latitude,
      _technicianLocation!.longitude,
      _userLocation!.latitude,
      _userLocation!.longitude,
    );

    setState(() {
      _estimatedDistance = distance;
      // Assuming average speed of 30 km/h in city
      final hours = distance / 30;
      final minutes = (hours * 60).round();
      _estimatedTime = _formatTime(minutes);
    });
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const p = 0.017453292519943295; // Pi/180
    final a =
        0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }

  String _formatTime(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    } else {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      return mins > 0 ? '${hours}h ${mins}m' : '${hours}h';
    }
  }

  void _fitBounds() {
    if (_technicianLocation == null || _userLocation == null) return;

    Future.delayed(const Duration(milliseconds: 100), () {
      // Center map to show both markers
      _mapController.move(_technicianLocation!, 13.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
            ),
          ),
        ),
        title: Text(
          'Order',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Real Map with markers and route
                _buildMap(),

                // Bottom detail card
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildCustomerCard(),
                ),
              ],
            ),
    );
  }

  Widget _buildMap() {
    if (_technicianLocation == null || _userLocation == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _technicianLocation!,
        initialZoom: 13.0,
        minZoom: 5.0,
        maxZoom: 18.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.ziyonstar.technician',
        ),

        // Route line between technician and user
        PolylineLayer(
          polylines: [
            Polyline(
              points: [_technicianLocation!, _userLocation!],
              strokeWidth: 4.0,
              color: const Color(0xFF4A7C59),
              borderStrokeWidth: 8.0,
              borderColor: Color.fromRGBO(74, 124, 89, 0.3),
            ),
          ],
        ),

        // Markers
        MarkerLayer(
          markers: [
            // Technician location marker
            Marker(
              point: _technicianLocation!,
              width: 80,
              height: 80,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'You',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A7C59),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      LucideIcons.wrench,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            // User location marker
            Marker(
              point: _userLocation!,
              width: 80,
              height: 80,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Customer',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      LucideIcons.home,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomerCard() {
    final user = _bookingData?['userId'];
    final customerName = user is Map
        ? (user['name'] ?? 'Customer')
        : 'Customer';
    final customerImage = user is Map ? user['photoUrl'] : null;
    final deviceInfo =
        '${_bookingData?['deviceBrand'] ?? 'Unknown'} ${_bookingData?['deviceModel'] ?? ''}';

    // Get address details
    final addressData = _bookingData?['address'];
    String fullAddress = widget.destination;
    if (addressData is Map) {
      fullAddress = addressData['fullAddress'] ?? widget.destination;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF4A7C59),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Customer info row
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundImage:
                    (customerImage != null && customerImage.isNotEmpty)
                    ? NetworkImage(customerImage)
                    : const AssetImage('assets/images/avatar_placeholder.png')
                          as ImageProvider,
                backgroundColor: Colors.grey[200],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$customerName (client)',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      deviceInfo,
                      style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Action buttons
              Row(
                children: [
                  _buildActionButton(
                    icon: LucideIcons.messageSquare,
                    color: Colors.white.withValues(alpha: 0.2),
                    onTap: () {
                      // TODO: Open chat
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildActionButton(
                    icon: LucideIcons.phone,
                    color: Colors.white.withValues(alpha: 0.2),
                    onTap: () {
                      // TODO: Make call
                    },
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Estimate delivery time section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      LucideIcons.clock,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Estimate Arrival Time',
                      style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _estimatedTime ?? 'Calculating...',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_estimatedDistance != null)
                  Text(
                    '${_estimatedDistance!.toStringAsFixed(1)} km away',
                    style: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Order status progress
          Row(
            children: [
              _buildStatusItem(
                'Order Accepted',
                LucideIcons.checkCircle2,
                true,
              ),
              _buildStatusConnector(true),
              _buildStatusItem('On Way', LucideIcons.navigation, false),
              _buildStatusConnector(false),
              _buildStatusItem('Done', LucideIcons.checkCheck, false),
            ],
          ),

          const SizedBox(height: 20),

          // View Details button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Show full booking details
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF4A7C59),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'View Details',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildStatusItem(String label, IconData icon, bool isCompleted) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isCompleted
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isCompleted
                  ? const Color(0xFF4A7C59)
                  : Colors.white.withValues(alpha: 0.5),
              size: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              color: isCompleted
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.5),
              fontSize: 10,
              fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusConnector(bool isCompleted) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 20),
        color: isCompleted ? Colors.white : Colors.white.withValues(alpha: 0.2),
      ),
    );
  }
}
