import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ziyonstar/services/api_service.dart';
import 'package:ziyonstar/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileSetupScreen extends StatefulWidget {
  final String name;
  final String email;
  final String uid;
  final String? photoUrl;

  const ProfileSetupScreen({
    super.key,
    required this.name,
    required this.email,
    required this.uid,
    this.photoUrl,
  });

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final ApiService _apiService = ApiService();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  XFile? _imageFile;
  bool _isLoading = false;
  String? _currentPhotoUrl;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.name;
    _currentPhotoUrl = widget.photoUrl;
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _imageFile = image);
    }
  }

  Future<void> _handleSave() async {
    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mobile number is required')),
      );
      return;
    }

    if (_passwordController.text.trim().length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? finalPhotoUrl = _currentPhotoUrl;

      // 1. Upload new image if picked
      if (_imageFile != null) {
        final uploadedUrl = await _apiService.uploadImage(_imageFile!);
        if (uploadedUrl != null) {
          finalPhotoUrl = uploadedUrl;
        }
      }

      final Map<String, dynamic> userData = {
        'name': _nameController.text.trim(),
        'email': widget.email,
        'firebaseUid': widget.uid,
        'photoUrl': finalPhotoUrl,
        'phone': _phoneController.text.trim(),
        'password': _passwordController.text.trim(), // Save to DB
        'role': 'user',
        'isProfileComplete': true,
      };

      // 2. Update Firebase Auth Password (optional but good for consistency)
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await user.updatePassword(_passwordController.text.trim());
        }
      } catch (e) {
        debugPrint("Could not update Firebase password: $e");
      }

      // 3. Update Backend
      await _apiService.updateUser(widget.uid, userData);

      // 4. Sync to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .set(userData, SetOptions(merge: true));

      // 5. Save locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_onboarded', true);
      await prefs.setString('user_uid', widget.uid);
      await prefs.setString('user_name', _nameController.text.trim());
      await prefs.setString('user_email', widget.email);
      if (finalPhotoUrl != null)
        await prefs.setString('user_photo', finalPhotoUrl);
      await prefs.setString('user_phone', _phoneController.text.trim());

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Profile Setup',
          style: GoogleFonts.outfit(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Just one more step!',
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Complete your profile to get started',
              style: GoogleFonts.inter(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Avatar setup
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
                        image: (_imageFile != null)
                            ? DecorationImage(
                                image: kIsWeb
                                    ? NetworkImage(_imageFile!.path)
                                          as ImageProvider
                                    : FileImage(File(_imageFile!.path)),
                                fit: BoxFit.cover,
                              )
                            : (_currentPhotoUrl != null &&
                                  _currentPhotoUrl!.isNotEmpty)
                            ? DecorationImage(
                                image: NetworkImage(_currentPhotoUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child:
                          (_imageFile == null &&
                              (_currentPhotoUrl == null ||
                                  _currentPhotoUrl!.isEmpty))
                          ? const Icon(
                              LucideIcons.user,
                              size: 60,
                              color: Colors.grey,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFACC15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          LucideIcons.camera,
                          size: 20,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            _buildLabel('Email (Not updatable)'),
            _buildTextField(
              controller: TextEditingController(text: widget.email),
              icon: LucideIcons.mail,
              readOnly: true,
            ),
            const SizedBox(height: 20),

            _buildLabel('Full Name'),
            _buildTextField(
              controller: _nameController,
              icon: LucideIcons.user,
              hint: 'Enter your name',
            ),
            const SizedBox(height: 20),

            _buildLabel('Mobile Number*'),
            _buildTextField(
              controller: _phoneController,
              icon: LucideIcons.phone,
              hint: 'Enter mobile number',
              type: TextInputType.phone,
            ),
            const SizedBox(height: 20),

            _buildLabel('Set Password*'),
            _buildTextField(
              controller: _passwordController,
              icon: LucideIcons.lock,
              hint: 'Create a password',
              isPassword: true,
            ),
            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: _isLoading ? null : _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFACC15),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.black)
                  : Text(
                      'Complete Setup',
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    String? hint,
    bool readOnly = false,
    bool isPassword = false,
    TextInputType type = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: readOnly ? Colors.grey[100] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        obscureText: isPassword,
        keyboardType: type,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.grey[400], size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        style: GoogleFonts.inter(
          color: readOnly ? Colors.grey : Colors.black87,
        ),
      ),
    );
  }
}
