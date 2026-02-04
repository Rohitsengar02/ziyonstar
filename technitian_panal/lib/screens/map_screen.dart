import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';

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
  List<LatLng> _routePoints = [];
  Map<String, dynamic>? _bookingData;
  bool _isLoading = true;
  Timer? _locationTimer;
  double? _estimatedDistance;
  String? _estimatedTime;
  String? _destinationName;
  bool _isSheetVisible = true;

  // 6 New LIVE Features State
  double _currentSpeed = 0; // Speedometer
  double _tripProgress = 0; // Progress bar (0.0 to 1.0)
  String _nextInstruction = "Drive to destination"; // TBT Guidance
  bool _isFollowMeMode = true; // Auto-follow camera
  bool _isNearDestination = false; // Proximity pulse
  List<Map<String, dynamic>> _trafficSegments = []; // Traffic intensity

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
      final booking = await _apiService.getBookingById(widget.orderId);

      setState(() {
        _bookingData = booking;
        if (booking != null) {
          final addressData = booking['address'];
          _destinationName = addressData is Map
              ? addressData['fullAddress']
              : widget.destination;

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

      await _updateTechnicianLocation();
      await _fetchRoute();

      if (_technicianLocation != null && _userLocation != null) {
        _fitBounds();
      }
    } catch (e) {
      debugPrint('Error initializing navigation: $e');
      setState(() => _isLoading = false);
    }
  }

  void _startLocationTracking() {
    _locationTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _updateTechnicianLocation();
    });
  }

  Future<void> _updateTechnicianLocation() async {
    try {
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
        final double speedKph = (position.speed * 3.6).clamp(0, 120);
        _currentSpeed = speedKph;
        _technicianLocation = LatLng(position.latitude, position.longitude);

        if (_userLocation != null) {
          _updateTripProgress();
          _fetchRoute();

          if (_isFollowMeMode) {
            _mapController.move(
              _technicianLocation!,
              _mapController.camera.zoom,
            );
          }
        }
      });
    } catch (e) {
      debugPrint('Error getting technician location: $e');
    }
  }

  Future<void> _fetchRoute() async {
    if (_technicianLocation == null || _userLocation == null) return;

    try {
      final url =
          'https://router.project-osrm.org/route/v1/driving/'
          '${_technicianLocation!.longitude},${_technicianLocation!.latitude};'
          '${_userLocation!.longitude},${_userLocation!.latitude}'
          '?overview=full&geometries=geojson';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> coordinates =
            data['routes'][0]['geometry']['coordinates'];

        setState(() {
          _routePoints = coordinates
              .map((coord) => LatLng(coord[1].toDouble(), coord[0].toDouble()))
              .toList();

          final distanceInMeters = data['routes'][0]['distance'].toDouble();
          final durationInSeconds = data['routes'][0]['duration'].toDouble();

          _estimatedDistance = distanceInMeters / 1000;
          _estimatedTime = _formatTime((durationInSeconds / 60).round());

          // FEATURE 1: Traffic Intensity Simulation (Segmenting route by traffic)
          _generateTrafficSegments();

          // FEATURE 2: Extract Next Direction
          if (data['routes'][0].containsKey('legs') &&
              data['routes'][0]['legs'][0]['steps'].isNotEmpty) {
            final firstStep = data['routes'][0]['legs'][0]['steps'][0];
            _nextInstruction =
                firstStep['maneuver']['instruction'] ?? "Proceed to the route";
          }
        });
      }
    } catch (e) {
      debugPrint('Error fetching route: $e');
      setState(() {
        _routePoints = [_technicianLocation!, _userLocation!];
      });
    }
  }

  void _updateTripProgress() {
    if (_technicianLocation == null || _userLocation == null) return;
    double remaining = const Distance().as(
      LengthUnit.Meter,
      _technicianLocation!,
      _userLocation!,
    );
    double initial = (_estimatedDistance ?? 1.0) * 1000;
    setState(() {
      _tripProgress = (1.0 - (remaining / initial)).clamp(0.0, 1.0);
      _isNearDestination = remaining < 500; // Pulse if < 500m
    });
  }

  void _generateTrafficSegments() {
    _trafficSegments.clear();
    if (_routePoints.length < 2) return;

    for (int i = 0; i < _routePoints.length - 1; i++) {
      // Simulate traffic based on segments (Real apps use API data here)
      // We'll vary it for visual effect
      final color = i % 15 == 0
          ? Colors
                .red // Heavily Slow
          : (i % 8 == 0
                ? Colors.orange
                : const Color(0xFF3B82F6)); // Medium/Normal

      _trafficSegments.add({
        'points': [_routePoints[i], _routePoints[i + 1]],
        'color': color,
      });
    }
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

    Future.delayed(const Duration(milliseconds: 500), () {
      final bounds = LatLngBounds.fromPoints([
        _technicianLocation!,
        _userLocation!,
      ]);
      _mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(100)),
      );
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
              icon: const Icon(
                LucideIcons.chevronLeft,
                color: Colors.black,
                size: 24,
              ),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
            ),
          ),
        ),
        title: Column(
          children: [
            Text(
              'Job Navigation',
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            if (_destinationName != null)
              Text(
                _destinationName!.split(',').first,
                style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 12),
              ),
          ],
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                _buildMap(),

                // Top controls row
                Positioned(
                  top: 100,
                  right: 16,
                  child: Column(
                    children: [
                      _buildMapActionButton(
                        icon: _isFollowMeMode
                            ? LucideIcons.navigation
                            : LucideIcons.navigation2,
                        onTap: () =>
                            setState(() => _isFollowMeMode = !_isFollowMeMode),
                        tooltip: 'Follow Me Mode',
                        isActive: _isFollowMeMode,
                      ),
                      const SizedBox(height: 12),
                      _buildMapActionButton(
                        icon: LucideIcons.maximize2,
                        onTap: () {
                          setState(() {
                            _isSheetVisible = !_isSheetVisible;
                          });
                        },
                        tooltip: 'Toggle Full Map',
                      ),
                      const SizedBox(height: 12),
                      _buildMapActionButton(
                        icon: LucideIcons.plus,
                        onTap: () {
                          _mapController.move(
                            _mapController.camera.center,
                            _mapController.camera.zoom + 1,
                          );
                        },
                        tooltip: 'Zoom In',
                      ),
                      const SizedBox(height: 12),
                      _buildMapActionButton(
                        icon: LucideIcons.minus,
                        onTap: () {
                          _mapController.move(
                            _mapController.camera.center,
                            _mapController.camera.zoom - 1,
                          );
                        },
                        tooltip: 'Zoom Out',
                      ),
                      const SizedBox(height: 12),
                      _buildMapActionButton(
                        icon: LucideIcons.locateFixed,
                        onTap: _fitBounds,
                        tooltip: 'Recenter View',
                      ),
                    ],
                  ),
                ),

                // FEATURE 4: Live Speedometer
                if (_isSheetVisible)
                  Positioned(bottom: 320, left: 20, child: _buildSpeedometer()),

                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 120,
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withOpacity(0.8),
                            Colors.white.withOpacity(0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (_isSheetVisible) _buildNavigationSheet(),
              ],
            ),
    );
  }

  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _technicianLocation ?? const LatLng(28.6139, 77.2090),
        initialZoom: 14.0,
      ),
      children: [
        TileLayer(
          urlTemplate:
              'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
          userAgentPackageName: 'com.ziyonstar.technician',
          subdomains: const ['a', 'b', 'c', 'd'],
        ),
        if (_routePoints.isNotEmpty)
          PolylineLayer(
            polylines: _trafficSegments.isEmpty
                ? [
                    Polyline(
                      points: _routePoints,
                      strokeWidth: 5.0,
                      color: const Color(0xFF3B82F6),
                      borderStrokeWidth: 2.0,
                      borderColor: const Color(0xFF2563EB).withOpacity(0.5),
                    ),
                  ]
                : _trafficSegments.map((seg) {
                    return Polyline(
                      points: seg['points'] as List<LatLng>,
                      strokeWidth: 6.0,
                      color: (seg['color'] as Color).withOpacity(0.8),
                    );
                  }).toList(),
          ),
        MarkerLayer(
          markers: [
            if (_technicianLocation != null)
              Marker(
                point: _technicianLocation!,
                width: 60,
                height: 60,
                child: _buildLocationMarker(const Color(0xFF3B82F6), true),
              ),
            if (_userLocation != null)
              Marker(
                point: _userLocation!,
                width: 100,
                height: 100,
                child: _buildProximityPulseMarker(const Color(0xFF10B981)),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildMapActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
    bool isActive = false,
  }) {
    return FloatingActionButton.small(
      onPressed: onTap,
      backgroundColor: isActive ? const Color(0xFF3B82F6) : Colors.white,
      foregroundColor: isActive ? Colors.white : Colors.black,
      heroTag: null,
      tooltip: tooltip,
      child: Icon(icon, size: 18),
    );
  }

  Widget _buildSpeedometer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _currentSpeed.toStringAsFixed(0),
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'km/h',
            style: GoogleFonts.inter(color: Colors.white54, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildProximityPulseMarker(Color color) {
    return TweenAnimationBuilder(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(seconds: 2),
      builder: (context, double value, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            if (_isNearDestination)
              Container(
                width: 100 * value,
                height: 100 * value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color.withOpacity(1 - value),
                    width: 2,
                  ),
                ),
              ),
            _buildLocationMarker(color, false),
          ],
        );
      },
      onEnd:
          () {}, // Handled by loop if we used animation controller, but this pulses once per rebuild
    );
  }

  Widget _buildLocationMarker(Color color, bool isCurrent) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ],
    );
  }

  Widget _buildNavigationSheet() {
    final user = _bookingData?['userId'];
    final customerName = user is Map
        ? (user['name'] ?? 'Customer')
        : 'Customer';
    final customerImage = user is Map ? user['photoUrl'] : null;

    return DraggableScrollableSheet(
      initialChildSize: 0.35,
      minChildSize: 0.2,
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 20, spreadRadius: 5),
            ],
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Customer Brief
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage:
                                (customerImage != null &&
                                    customerImage.isNotEmpty)
                                ? NetworkImage(customerImage)
                                : null,
                            child:
                                (customerImage == null || customerImage.isEmpty)
                                ? const Icon(LucideIcons.user, size: 20)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            customerName,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Travel time',
                                style: GoogleFonts.inter(
                                  color: Colors.grey[500],
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                _estimatedTime ?? '--',
                                style: GoogleFonts.poppins(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Distance',
                                style: GoogleFonts.inter(
                                  color: Colors.grey[500],
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                _estimatedDistance != null
                                    ? '${_estimatedDistance!.toStringAsFixed(1)} km'
                                    : '-- km',
                                style: GoogleFonts.poppins(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // FEATURE 5: Live Progress Bar
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Route Progress',
                                style: GoogleFonts.inter(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                '${(_tripProgress * 100).toStringAsFixed(0)}%',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: _tripProgress,
                              minHeight: 6,
                              backgroundColor: Colors.grey[100],
                              valueColor: const AlwaysStoppedAnimation(
                                Color(0xFF3B82F6),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),
                      _buildRouteTimeline(),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 60,
                              child: ElevatedButton(
                                onPressed: () async {
                                  final user = _bookingData?['userId'];
                                  final phone = user is Map
                                      ? user['phone']
                                      : null;
                                  if (phone != null && phone.isNotEmpty) {
                                    final Uri launchUri = Uri(
                                      scheme: 'tel',
                                      path: phone,
                                    );
                                    if (await canLaunchUrl(launchUri)) {
                                      await launchUrl(launchUri);
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Customer phone number not available',
                                        ),
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF97316),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(LucideIcons.phone, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'CALL CUSTOMER',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                LucideIcons.share2,
                                color: Color(0xFF10B981),
                              ),
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRouteTimeline() {
    return Column(
      children: [
        Row(
          children: [
            _buildTimelineMarker(const Color(0xFF3B82F6), true),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Location',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Current position',
                    style: GoogleFonts.inter(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Container(width: 2, height: 40, color: Colors.grey[200]),
            ),
          ],
        ),
        Row(
          children: [
            _buildTimelineMarker(const Color(0xFF10B981), false),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _destinationName?.split(',').first ?? 'Customer Address',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _destinationName?.split(',').skip(1).join(',').trim() ??
                        'Destination',
                    style: GoogleFonts.inter(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimelineMarker(Color color, bool isStart) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
    );
  }
}
