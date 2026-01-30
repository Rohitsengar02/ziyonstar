import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/location_service.dart';
import '../services/api_service.dart';
import '../theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AddAddressPage extends StatefulWidget {
  const AddAddressPage({super.key});

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final ApiService _apiService = ApiService();
  final MapController _mapController = MapController();
  LatLng _selectedLocation = const LatLng(28.6139, 77.2090); // Default to Delhi
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isMapReady = false;

  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController(text: 'Home');
  final _addressController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    _labelController.dispose();
    _addressController.dispose();
    _landmarkController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    // If it's the first load, keep the full loader.
    // If it's a refresh from the button, maybe don't show the full spinner to avoid the "not rendered" error.
    final isFirstLoad = _isLoading;

    final position = await LocationService.getCurrentLocation();
    if (position != null) {
      final newLoc = LatLng(position.latitude, position.longitude);

      if (mounted) {
        setState(() {
          _selectedLocation = newLoc;
          if (isFirstLoad) {
            _isLoading = false;
          }
        });
      }

      // If map is already ready, move it. If not, initialCenter will handle it.
      if (_isMapReady) {
        _mapController.move(newLoc, 15);
      }

      await _fetchAddressFromCoords(newLoc);
    } else {
      if (mounted && isFirstLoad) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchAddressFromCoords(LatLng coords) async {
    final structured =
        await LocationService.getStructuredAddressFromCoordinates(
          coords.latitude,
          coords.longitude,
        );

    if (structured != null) {
      setState(() {
        _addressController.text = structured['full'] ?? '';
        _cityController.text = structured['city'] ?? '';
        _stateController.text = structured['state'] ?? '';
        _pincodeController.text = structured['postcode'] ?? '';
      });
    }
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      String? uid;
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        uid = user.uid;
      } else {
        uid = prefs.getString('user_uid') ?? prefs.getString('user_id');
      }

      if (uid == null) throw 'User not authenticated';

      final userData = await _apiService.getUser(uid);
      if (userData == null) throw 'User data not found';

      final result = await _apiService.addAddress(
        userId: userData['_id'],
        label: _labelController.text,
        fullAddress: _addressController.text,
        landmark: _landmarkController.text,
        city: _cityController.text,
        state: _stateController.text,
        pincode: _pincodeController.text,
        phone: _phoneController.text,
        latitude: _selectedLocation.latitude,
        longitude: _selectedLocation.longitude,
        isDefault: _isDefault,
      );

      if (result != null) {
        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Address added successfully')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error saving address: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
          'Add New Address',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    // Map Section
                    Container(
                      height: 280,
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        children: [
                          FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              onMapReady: () {
                                setState(() {
                                  _isMapReady = true;
                                });
                              },
                              initialCenter: _selectedLocation,
                              initialZoom: 15,
                              onPositionChanged: (pos, hasGesture) {
                                if (hasGesture) {
                                  setState(() {
                                    _selectedLocation = pos.center;
                                  });
                                }
                              },
                              onMapEvent: (event) {
                                if (event is MapEventMoveEnd) {
                                  _fetchAddressFromCoords(_selectedLocation);
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
                          // Static Pin in Center
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 40),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      'Move map to pick',
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ).animate().fade().scale().moveY(
                                    begin: -10,
                                    end: 0,
                                  ),
                                  const SizedBox(height: 8),
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Pulsing shadow
                                      Container(
                                            width: 12,
                                            height: 12,
                                            decoration: BoxDecoration(
                                              color: Colors.red.withOpacity(
                                                0.3,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                          )
                                          .animate(onPlay: (c) => c.repeat())
                                          .scale(
                                            begin: const Offset(1, 1),
                                            end: const Offset(4, 4),
                                            duration: 1000.ms,
                                          )
                                          .fade(begin: 1.0, end: 0.0),

                                      const Icon(
                                            LucideIcons.mapPin,
                                            color: Colors.red,
                                            size: 40,
                                          )
                                          .animate(
                                            onPlay: (controller) => controller
                                                .repeat(reverse: true),
                                          )
                                          .moveY(
                                            begin: -5,
                                            end: 0,
                                            duration: 800.ms,
                                            curve: Curves.easeInOut,
                                          ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Premium Shadow for the bottom of map
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.white.withOpacity(0),
                                    Colors.white.withOpacity(0.8),
                                    Colors.white,
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Gradient Overlay for depth
                          IgnorePointer(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.white.withOpacity(0.2),
                                    Colors.transparent,
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.1),
                                  ],
                                  stops: const [0, 0.4, 0.6, 1],
                                ),
                              ),
                            ),
                          ),
                          // Float Card for Current Address Preview
                          Positioned(
                            top: 20,
                            left: 20,
                            right: 20,
                            child:
                                Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.9),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.1,
                                            ),
                                            blurRadius: 10,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            LucideIcons.map,
                                            size: 18,
                                            color: AppColors.primaryButton,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              _addressController.text.isEmpty
                                                  ? 'Finding location...'
                                                  : _addressController.text,
                                              style: GoogleFonts.inter(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                    .animate(
                                      target: _addressController.text.isEmpty
                                          ? 0
                                          : 1,
                                    )
                                    .fade(duration: 400.ms)
                                    .slideY(begin: -0.2, end: 0),
                          ),
                          // Current Location Button
                          Positioned(
                            right: 20,
                            bottom: 60,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child:
                                  FloatingActionButton(
                                        mini: true,
                                        onPressed: _initLocation,
                                        backgroundColor: Colors.white,
                                        child: const Icon(
                                          LucideIcons.locateFixed,
                                          color: AppColors.primaryButton,
                                        ),
                                      )
                                      .animate(
                                        onPlay: (c) => c.repeat(reverse: true),
                                      )
                                      .scale(
                                        begin: const Offset(1, 1),
                                        end: const Offset(1.1, 1.1),
                                        duration: 2000.ms,
                                      ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fade(duration: 500.ms).slideY(begin: -0.1, end: 0),
                    // Form Section
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Address Details',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textHeading,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _labelController,
                                label: 'Address Label (e.g. Home, Office)',
                                icon: LucideIcons.tag,
                                validator: (v) =>
                                    v!.isEmpty ? 'Enter label' : null,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _addressController,
                                label: 'Full Address',
                                icon: LucideIcons.mapPin,
                                maxLines: 3,
                                validator: (v) =>
                                    v!.isEmpty ? 'Enter address' : null,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _cityController,
                                      label: 'City',
                                      icon: LucideIcons.building2,
                                      validator: (v) =>
                                          v!.isEmpty ? 'Enter city' : null,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _stateController,
                                      label: 'State',
                                      icon: LucideIcons.map,
                                      validator: (v) =>
                                          v!.isEmpty ? 'Enter state' : null,
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
                                validator: (v) =>
                                    v!.isEmpty ? 'Enter pincode' : null,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _landmarkController,
                                label: 'Landmark (Optional)',
                                icon: LucideIcons.landmark,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _phoneController,
                                label: 'Contact Phone',
                                icon: LucideIcons.phone,
                                keyboardType: TextInputType.phone,
                                validator: (v) =>
                                    v!.isEmpty ? 'Enter phone' : null,
                              ),
                              const SizedBox(height: 16),
                              SwitchListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  'Set as Default Address',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                value: _isDefault,
                                onChanged: (v) =>
                                    setState(() => _isDefault = v),
                                activeColor: AppColors.primaryButton,
                              ),
                              const SizedBox(height: 32),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isSaving ? null : _saveAddress,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryButton,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 18,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 2,
                                  ),
                                  child: _isSaving
                                      ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                      : Text(
                                          'Save Address',
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
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
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(
          color: Colors.grey.shade600,
          fontSize: 13,
        ),
        prefixIcon: Icon(icon, size: 20, color: Colors.grey.shade400),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.primaryButton,
            width: 2,
          ),
        ),
      ),
      style: GoogleFonts.inter(fontSize: 14),
    );
  }
}
