import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/api_service.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProfileStep extends StatefulWidget {
  final VoidCallback onNext;
  const ProfileStep({super.key, required this.onNext});

  @override
  State<ProfileStep> createState() => _ProfileStepState();
}

class _ProfileStepState extends State<ProfileStep> {
  final _dobController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _radiusController = TextEditingController();

  XFile? _profileImage;
  DateTime? _selectedDob;

  String? _selectedGender;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _profileImage = image);
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.black,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDob = picked;
        _dobController.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied';
      }

      Position? position;
      if (!kIsWeb) {
        position = await Geolocator.getLastKnownPosition();
      }

      if (position == null) {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 15),
        );
      }

      if (kIsWeb) {
        // Geocoding package doesn't support web, use OpenStreetMap (Nominatim)
        final url = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}&zoom=18&addressdetails=1',
        );
        final response = await http.get(url);
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final displayName = data['display_name'] ?? 'Address found';
          setState(() {
            _cityController.text = displayName;
          });
        } else {
          throw 'Failed to reverse geocode on Web';
        }
      } else {
        // Native Platforms
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          final address = [
            place.street,
            place.subLocality,
            place.locality,
            place.postalCode,
            place.administrativeArea,
          ].where((e) => e != null && e.isNotEmpty).join(', ');

          setState(() {
            _cityController.text = address;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMsg = e.toString();
        if (errorMsg.contains('kCLErrorLocationUnknown') ||
            errorMsg.contains('error 1')) {
          errorMsg =
              "Unable to find location. If using a Simulator, go to Features > Location and set a location (e.g. Apple).";
        } else if (errorMsg.contains('Timeout')) {
          errorMsg =
              "Location request timed out. Please check your GPS signal.";
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(label: 'OK', onPressed: () {}),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleNext() async {
    // Validate
    if (_profileImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add your profile image')),
      );
      return;
    }

    if (_selectedGender == null ||
        _phoneController.text.trim().isEmpty ||
        _cityController.text.isEmpty ||
        _radiusController.text.isEmpty ||
        _dobController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    if (_phoneController.text.trim().length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 10-digit mobile number'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String? photoUrl;
        if (_profileImage != null) {
          photoUrl = await ApiService().uploadImage(_profileImage);
        }

        final profileData = {
          'gender': _selectedGender,
          'phone': _phoneController.text.trim(),
          'city': _cityController.text.trim(),
          'serviceAreaRadius': _radiusController.text.trim(),
          'dob': _selectedDob?.toIso8601String(),
        };
        if (photoUrl != null) profileData['photoUrl'] = photoUrl;

        await ApiService().updateTechnicianProfile(
          firebaseUid: user.uid,
          data: profileData,
        );

        // Sync to Firestore
        final firestoreData = {
          'gender': _selectedGender,
          'phone': _phoneController.text.trim(),
          'city': _cityController.text.trim(),
          'serviceAreaRadius': _radiusController.text.trim(),
          'dob': _selectedDob?.toIso8601String(),
        };
        if (photoUrl != null) firestoreData['photoUrl'] = photoUrl;

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set(firestoreData, SetOptions(merge: true));

        widget.onNext();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Complete Your Profile',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your details to help us verify your account faster.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),

          // Avatar Selection
          Center(
            child: GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.black.withOpacity(0.1),
                        width: 2,
                      ),
                    ),
                    child: _profileImage != null
                        ? ClipOval(
                            child: FutureBuilder<Uint8List>(
                              future: _profileImage!.readAsBytes(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                        ConnectionState.done &&
                                    snapshot.data != null) {
                                  return Image.memory(
                                    snapshot.data!,
                                    fit: BoxFit.cover,
                                    width: 120,
                                    height: 120,
                                  );
                                } else {
                                  return const Padding(
                                    padding: EdgeInsets.all(40.0),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  );
                                }
                              },
                            ),
                          )
                        : const Icon(
                            LucideIcons.user,
                            size: 60,
                            color: Colors.grey,
                          ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        LucideIcons.camera,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),

          // Note: Name/Email are usually pre-filled or readonly if coming from Auth
          // We focus on new fields here.
          _buildFieldSection(
            'Date of Birth',
            LucideIcons.calendar,
            'DD/MM/YYYY',
            controller: _dobController,
            readOnly: true,
            onTap: _selectDate,
          ),
          const SizedBox(height: 20),
          _buildFieldSection(
            'Mobile Number',
            LucideIcons.phone,
            'Enter your mobile number',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 20),

          // Gender Selection
          const Text(
            'Gender',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildGenderChip('Male'),
              const SizedBox(width: 12),
              _buildGenderChip('Female'),
              const SizedBox(width: 12),
              _buildGenderChip('Other'),
            ],
          ),
          const SizedBox(height: 24),

          _buildFieldSection(
            'Address',
            LucideIcons.mapPin,
            'Enter your address',
            controller: _cityController,
            suffixIcon: IconButton(
              icon: const Icon(LucideIcons.locateFixed, color: Colors.blue),
              onPressed: _getCurrentLocation,
            ),
          ),
          const SizedBox(height: 20),
          _buildFieldSection(
            'Service Area / Radius',
            LucideIcons.navigation,
            'e.g. 10km',
            controller: _radiusController,
          ),

          const SizedBox(height: 40),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleNext,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldSection(
    String label,
    IconData icon,
    String hint, {
    TextEditingController? controller,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20),
            suffixIcon: suffixIcon,
            fillColor: const Color(0xFFF9FAFB),
            filled: true,
            counterText: "", // Hide character counter
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderChip(String label) {
    final bool isSelected = _selectedGender == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
