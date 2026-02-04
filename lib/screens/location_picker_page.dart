import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_map/flutter_map.dart';

import '../services/location_service.dart';
import '../theme.dart';

class LocationPickerPage extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;

  const LocationPickerPage({super.key, this.initialLat, this.initialLng});

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  double? _currentLat;
  double? _currentLng;
  bool _isLoading = true;
  bool _isLoadingAddress = false;
  String? _errorMessage;

  // Form Controllers
  final TextEditingController _fullAddressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();

  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    _fullAddressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // If initial coordinates provided, use them
      if (widget.initialLat != null && widget.initialLng != null) {
        setState(() {
          _currentLat = widget.initialLat;
          _currentLng = widget.initialLng;
          _isLoading = false;
        });
        _fetchAddressFromCoordinates();
        return;
      }

      // Otherwise, get current location
      final position = await LocationService.getCurrentLocation();

      if (position != null) {
        setState(() {
          _currentLat = position.latitude;
          _currentLng = position.longitude;
          _isLoading = false;
        });
        _fetchAddressFromCoordinates();

        // Move map to current location
        _mapController.move(LatLng(_currentLat!, _currentLng!), 15);
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Unable to get your location. Please enable location services.';
          // Default to Delhi
          _currentLat = 28.6139;
          _currentLng = 77.2090;
        });
        _fetchAddressFromCoordinates();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'An error occurred while getting location.';
        _currentLat = 28.6139;
        _currentLng = 77.2090;
      });
    }
  }

  Future<void> _fetchAddressFromCoordinates() async {
    if (_currentLat == null || _currentLng == null) return;

    setState(() => _isLoadingAddress = true);

    try {
      final structuredData =
          await LocationService.getStructuredAddressFromCoordinates(
            _currentLat!,
            _currentLng!,
          );

      if (mounted) {
        if (structuredData != null) {
          setState(() {
            _fullAddressController.text = structuredData['full'] ?? '';
            _cityController.text = structuredData['city'] ?? '';
            _stateController.text = structuredData['state'] ?? '';
            _pincodeController.text = structuredData['postcode'] ?? '';
            _isLoadingAddress = false;
          });
        } else {
          // Fallback
          setState(() {
            _fullAddressController.text =
                'Lat: ${_currentLat!.toStringAsFixed(6)}, Lng: ${_currentLng!.toStringAsFixed(6)}';
            _isLoadingAddress = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingAddress = false);
      }
    }
  }

  void _confirmLocation() {
    final fullAddress = _fullAddressController.text.trim();
    if (fullAddress.isEmpty) return;

    if (_currentLat != null && _currentLng != null) {
      Navigator.pop(
        context,
        LocationData(
          latitude: _currentLat!,
          longitude: _currentLng!,
          address: fullAddress,
          // We could return more structured data but let's stick to what's expected
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Confirm Location',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Map Section
                Expanded(
                  flex: 3,
                  child: Stack(
                    children: [
                      FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: LatLng(
                            _currentLat ?? 28.6139,
                            _currentLng ?? 77.2090,
                          ),
                          initialZoom: 15,
                          onPositionChanged: (position, hasGesture) {
                            if (hasGesture) {
                              setState(() {
                                _currentLat = position.center.latitude;
                                _currentLng = position.center.longitude;
                              });
                            }
                          },
                          onMapEvent: (event) {
                            if (event is MapEventMoveEnd) {
                              _fetchAddressFromCoordinates();
                            }
                          },
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.ziyonstar.app',
                          ),
                        ],
                      ),
                      // Center Marker (Fixed Pin)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 40),
                          child: Icon(
                            LucideIcons.mapPin,
                            color: AppColors.accentRed,
                            size: 40,
                          ),
                        ),
                      ),
                      // Floating Refresh Button
                      Positioned(
                        right: 16,
                        bottom: 16,
                        child: FloatingActionButton(
                          mini: true,
                          backgroundColor: Colors.white,
                          onPressed: _initLocation,
                          child: const Icon(
                            LucideIcons.locateFixed,
                            color: AppColors.primaryButton,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Form Section
                Expanded(
                  flex: 4,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, -5),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_errorMessage != null)
                            Container(
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    LucideIcons.alertCircle,
                                    color: Colors.red.shade700,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: Colors.red.shade900,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(LucideIcons.x, size: 16),
                                    onPressed: () =>
                                        setState(() => _errorMessage = null),
                                  ),
                                ],
                              ),
                            ),

                          Row(
                            children: [
                              Text(
                                'Delivery Address',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              if (_isLoadingAddress)
                                const Padding(
                                  padding: EdgeInsets.only(left: 12),
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          _buildTextField(
                            controller: _fullAddressController,
                            label: 'Building/Street/Area',
                            maxLines: 2,
                            icon: LucideIcons.home,
                          ),
                          const SizedBox(height: 16),

                          _buildTextField(
                            controller: _landmarkController,
                            label: 'Landmark (Optional)',
                            icon: LucideIcons.mapPin,
                          ),
                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _cityController,
                                  label: 'City',
                                  icon: LucideIcons.building,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildTextField(
                                  controller: _stateController,
                                  label: 'State',
                                  icon: LucideIcons.map,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          _buildTextField(
                            controller: _pincodeController,
                            label: 'Pincode',
                            icon: LucideIcons.hash,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 32),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoadingAddress
                                  ? null
                                  : _confirmLocation,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryButton,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                'Confirm and Save',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: GoogleFonts.inter(fontSize: 14),
          decoration: InputDecoration(
            isDense: true,
            prefixIcon: Icon(icon, size: 18, color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryButton),
            ),
          ),
        ),
      ],
    );
  }
}
