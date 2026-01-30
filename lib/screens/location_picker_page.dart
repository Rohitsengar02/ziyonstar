import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../services/location_service.dart';
import '../theme.dart';

class LocationPickerPage extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;

  const LocationPickerPage({
    super.key,
    this.initialLat,
    this.initialLng,
  });

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  double? _currentLat;
  double? _currentLng;
  bool _isLoading = true;
  bool _isLoadingAddress = false;
  String? _errorMessage;
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

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
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Unable to get your location. Please enable location services.';
        // Default to Delhi
        _currentLat = 28.6139;
        _currentLng = 77.2090;
        // Set coordinates as address
        _addressController.text = 'Location: ${28.6139.toStringAsFixed(4)}, ${77.2090.toStringAsFixed(4)}';
      });
    }
  }

  Future<void> _fetchAddressFromCoordinates() async {
    if (_currentLat == null || _currentLng == null) return;

    setState(() => _isLoadingAddress = true);

    try {
      final address = await LocationService.getAddressFromCoordinates(
        _currentLat!,
        _currentLng!,
      );

      if (mounted) {
        if (address != null && address.isNotEmpty) {
          setState(() {
            _addressController.text = address;
            _isLoadingAddress = false;
            _errorMessage = null;
          });
        } else {
          // Fallback: Use coordinates as address
          setState(() {
            _addressController.text = 'Lat: ${_currentLat!.toStringAsFixed(6)}, Lng: ${_currentLng!.toStringAsFixed(6)}';
            _isLoadingAddress = false;
            _errorMessage = 'Address could not be detected. You can edit it below.';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _addressController.text = 'Lat: ${_currentLat!.toStringAsFixed(6)}, Lng: ${_currentLng!.toStringAsFixed(6)}';
          _isLoadingAddress = false;
          _errorMessage = 'Address detection failed. You can edit it below.';
        });
      }
    }
  }

  void _confirmLocation() {
    final finalAddress = _addressController.text.trim();
    
    if (finalAddress.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an address'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_currentLat != null && _currentLng != null) {
      Navigator.pop(context, LocationData(
        latitude: _currentLat!,
        longitude: _currentLng!,
        address: finalAddress,
      ));
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
          'Select Location',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.locateFixed, color: AppColors.primaryButton),
            onPressed: _initLocation,
            tooltip: 'Refresh Location',
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Getting your location...',
                    style: GoogleFonts.inter(color: Colors.grey),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Success/Warning message
                    if (_errorMessage != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(LucideIcons.info, color: Colors.orange.shade700, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: GoogleFonts.inter(fontSize: 13, color: Colors.orange.shade900),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Location Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.green.shade50, Colors.green.shade100],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Column(
                        children: [
                          // Success Icon
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.4),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Icon(
                              LucideIcons.checkCircle,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '📍 Location Captured!',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (_currentLat != null && _currentLng != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(LucideIcons.navigation, size: 14, color: Colors.grey.shade600),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${_currentLat!.toStringAsFixed(4)}, ${_currentLng!.toStringAsFixed(4)}',
                                    style: GoogleFonts.robotoMono(
                                      fontSize: 13,
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (_isLoadingAddress)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.green),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Detecting address...',
                                    style: GoogleFonts.inter(color: Colors.green.shade700, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Address Input Section
                    Row(
                      children: [
                        const Icon(LucideIcons.home, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Delivery Address',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Verify or edit the address below',
                      style: GoogleFonts.inter(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Address Text Field
                    TextField(
                      controller: _addressController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Enter your complete address...',
                        hintStyle: GoogleFonts.inter(color: Colors.grey.shade400),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.primaryButton, width: 2),
                        ),
                      ),
                      style: GoogleFonts.inter(fontSize: 14),
                      onChanged: (_) => setState(() {}), // Rebuild to update button state
                    ),

                    const SizedBox(height: 28),

                    // Confirm Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: (!_isLoadingAddress && _addressController.text.trim().isNotEmpty)
                            ? _confirmLocation
                            : null,
                        icon: const Icon(LucideIcons.check, color: Colors.white),
                        label: Text(
                          'Confirm Location',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          disabledBackgroundColor: Colors.grey.shade300,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Info text
                    Center(
                      child: Text(
                        'Your location will be shared with the technician for service.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
