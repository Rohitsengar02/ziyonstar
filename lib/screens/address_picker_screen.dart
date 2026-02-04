import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../theme.dart';
import '../responsive.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/navbar.dart';

class AddressPickerScreen extends StatefulWidget {
  final String userId;
  const AddressPickerScreen({super.key, required this.userId});

  @override
  State<AddressPickerScreen> createState() => _AddressPickerScreenState();
}

class _AddressPickerScreenState extends State<AddressPickerScreen> {
  final MapController _mapController = MapController();
  LatLng _selectedLocation = const LatLng(28.6139, 77.2090); // Default: Delhi
  String _currentAddress = 'Fetching address...';
  final TextEditingController _labelController = TextEditingController(
    text: 'Home',
  );
  final TextEditingController _detailController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isFetchingAddress = false;
  bool _isSaving = false;
  DateTime? _lastFetchTime;
  List<dynamic> _savedAddresses = [];
  bool _isLoadingSavedAddresses = false;

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _fetchSavedAddresses();
  }

  Future<void> _fetchSavedAddresses() async {
    setState(() => _isLoadingSavedAddresses = true);
    try {
      final apiService = ApiService();
      final addresses = await apiService.getAddresses(widget.userId);
      if (mounted) {
        setState(() {
          _savedAddresses = addresses;
          _isLoadingSavedAddresses = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching saved addresses: $e');
      if (mounted) setState(() => _isLoadingSavedAddresses = false);
    }
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _selectedLocation = LatLng(position.latitude, position.longitude);
      _mapController.move(_selectedLocation, 15);
    });
    _getAddressFromLatLng(_selectedLocation);
  }

  Future<void> _getAddressFromLatLng(LatLng location) async {
    // Basic debounce to respect Nominatim usage policy (max 1 request/sec)
    final now = DateTime.now();
    if (_lastFetchTime != null &&
        now.difference(_lastFetchTime!).inMilliseconds < 1000) {
      return;
    }
    _lastFetchTime = now;

    setState(() => _isFetchingAddress = true);
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=${location.latitude}&lon=${location.longitude}&zoom=18&addressdetails=1',
      );

      final response = await http.get(
        url,
        headers: {'User-Agent': 'ZiyonstarApp/1.0'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'] ?? {};
        final displayName = data['display_name'] ?? '';

        setState(() {
          _currentAddress = displayName;
          _detailController.text = displayName;

          // Granular auto-fill
          _landmarkController.text =
              address['suburb'] ??
              address['neighbourhood'] ??
              address['road'] ??
              '';
          _cityController.text =
              address['city'] ??
              address['town'] ??
              address['village'] ??
              address['county'] ??
              '';
          _stateController.text = address['state'] ?? '';
          _pincodeController.text = address['postcode'] ?? '';

          _isFetchingAddress = false;
        });
      } else {
        setState(() => _isFetchingAddress = false);
      }
    } catch (e) {
      debugPrint("Error fetching address: $e");
      setState(() => _isFetchingAddress = false);
    }
  }

  Future<void> _saveAddress() async {
    if (_detailController.text.isEmpty) return;
    setState(() => _isSaving = true);

    final apiService = ApiService();
    final result = await apiService.addAddress(
      userId: widget.userId,
      label: _labelController.text,
      fullAddress: _detailController.text,
      landmark: _landmarkController.text,
      city: _cityController.text,
      state: _stateController.text,
      pincode: _pincodeController.text,
      phone: _phoneController.text,
      latitude: _selectedLocation.latitude,
      longitude: _selectedLocation.longitude,
    );

    setState(() => _isSaving = false);
    if (result != null) {
      // Set as the globally selected location
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_location_label', result['label']);
      await prefs.setString(
        'selected_location_address',
        result['fullAddress'] ?? result['addressDetails'] ?? '',
      );
      await prefs.setString('selected_location_id', result['_id']);

      // Notify Navbar to refresh its location display
      Navbar.locationRefreshNotifier.value =
          !Navbar.locationRefreshNotifier.value;

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result['label']} saved and selected'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, result);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to save address')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveLayout.isDesktop(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Select Service Location',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        Expanded(flex: 3, child: _buildMap()),
        Expanded(flex: 2, child: _buildAddressForm()),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: _buildAddressForm(),
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(flex: 2, child: _buildMap()),
      ],
    );
  }

  Widget _buildMap() {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _selectedLocation,
            initialZoom: 15.0,
            onPositionChanged: (position, hasGesture) {
              if (hasGesture) {
                setState(() {
                  _selectedLocation = position.center;
                });
              }
            },
            onMapEvent: (event) {
              if (event is MapEventMoveEnd) {
                _getAddressFromLatLng(_selectedLocation);
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
              subdomains: const ['a', 'b', 'c', 'd'],
              userAgentPackageName: 'com.ziyonstar.app',
            ),
          ],
        ),
        const Center(
          child: Padding(
            padding: EdgeInsets.only(bottom: 40),
            child: Icon(
              LucideIcons.mapPin,
              size: 40,
              color: AppColors.accentRed,
            ),
          ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            mini: true,
            backgroundColor: Colors.white,
            onPressed: _determinePosition,
            child: const Icon(
              LucideIcons.crosshair,
              color: AppColors.primaryButton,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isLoadingSavedAddresses)
            const Center(child: LinearProgressIndicator())
          else if (_savedAddresses.isNotEmpty) ...[
            Text(
              'Your Saved Addresses',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textHeading,
              ),
            ),
            const SizedBox(height: 16),
            ..._savedAddresses.map((addr) => _buildSavedAddressCard(addr)),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Divider(),
            ),
          ],
          Text(
            'Address Details',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textHeading,
            ),
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _labelController,
            label: 'Save as (e.g. Home, Office)',
            icon: LucideIcons.tag,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _landmarkController,
            label: 'Landmark / Building Name',
            icon: LucideIcons.building,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _detailController,
            label: 'Complete Address',
            icon: LucideIcons.mapPin,
            maxLines: 2,
            isLoading: _isFetchingAddress,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _cityController,
                  label: 'City',
                  icon: LucideIcons.map,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _pincodeController,
                  label: 'Pincode',
                  icon: LucideIcons.hash,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _stateController,
            label: 'State',
            icon: LucideIcons.flag,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _phoneController,
            label: 'Contact Number',
            icon: LucideIcons.phone,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveAddress,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryButton,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Save & Continue',
                      style: GoogleFonts.inter(
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    bool isLoading = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: GoogleFonts.inter(fontSize: 15),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18, color: Colors.grey[600]),
            suffixIcon: isLoading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSavedAddressCard(Map<String, dynamic> addr) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // Return the selected address as if it was just saved/picked
          Navigator.pop(context, addr);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                addr['label'] == 'Home'
                    ? LucideIcons.home
                    : addr['label'] == 'Work'
                    ? LucideIcons.briefcase
                    : LucideIcons.mapPin,
                color: AppColors.primaryButton,
                size: 20,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      addr['label'] ?? 'Unknown',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.textHeading,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      addr['fullAddress'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                LucideIcons.chevronRight,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
