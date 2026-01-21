import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/api_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

class ProfileStep extends StatefulWidget {
  final VoidCallback onNext;
  const ProfileStep({super.key, required this.onNext});

  @override
  State<ProfileStep> createState() => _ProfileStepState();
}

class _ProfileStepState extends State<ProfileStep> {
  final _dobController = TextEditingController();
  final _cityController = TextEditingController();
  final _radiusController = TextEditingController();

  XFile? _profileImage;

  String? _selectedGender;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _profileImage = image);
    }
  }

  Future<void> _handleNext() async {
    // Validate
    if (_selectedGender == null ||
        _cityController.text.isEmpty ||
        _radiusController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
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

        await ApiService().updateTechnicianProfile(
          firebaseUid: user.uid,
          data: {
            'gender': _selectedGender,
            'city': _cityController.text.trim(),
            'serviceAreaRadius': _radiusController.text.trim(),
            'dob': _dobController.text.trim(),
            if (photoUrl != null) 'photoUrl': photoUrl,
          },
        );

        // Sync to Firestore
        final firestoreData = {
          'gender': _selectedGender,
          'city': _cityController.text.trim(),
          'serviceAreaRadius': _radiusController.text.trim(),
          'dob': _dobController.text.trim(),
        };
        if (photoUrl != null) firestoreData['photoUrl'] = photoUrl;

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set(firestoreData, SetOptions(merge: true));

        widget.onNext();
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
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
            'YYYY-MM-DD',
            controller: _dobController,
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
            'City',
            LucideIcons.mapPin,
            'Enter your city',
            controller: _cityController,
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
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20),
            fillColor: const Color(0xFFF9FAFB),
            filled: true,
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
