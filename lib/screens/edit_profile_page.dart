import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';
import '../responsive.dart';
import '../widgets/navbar.dart';
import '../widgets/app_drawer.dart';
import '../widgets/footer.dart';
import '../services/api_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  bool _isSaving = false;
  String? _uid;
  String? _currentPhotoUrl; // URL from DB
  XFile? _pickedImage; // Local file picked

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _uid = prefs.getString('user_uid');

      if (_uid != null) {
        final profile = await _apiService.getUser(_uid!);
        if (profile != null) {
          _nameController.text = profile['name'] ?? '';
          _emailController.text = profile['email'] ?? '';
          _phoneController.text = profile['phone'] ?? '';
          _currentPhotoUrl = profile['photoUrl'];
        }
      }
    } catch (e) {
      debugPrint("Error loading profile: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _pickedImage = image;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_uid == null) return;

    setState(() => _isSaving = true);

    try {
      String? photoUrl = _currentPhotoUrl;

      // 1. Upload new image if picked
      if (_pickedImage != null) {
        final String? uploadedUrl = await _apiService.uploadImage(
          _pickedImage!,
        );
        if (uploadedUrl != null) {
          photoUrl = uploadedUrl;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to upload image'),
              backgroundColor: Colors.red,
            ),
          );
          return; // Stop saving
        }
      }

      // 2. Prepare User Data for Upsert
      // Note: We don't change Email or UID.
      // Assuming registerUser updates based on firebaseUid.
      final Map<String, dynamic> updateData = {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'firebaseUid': _uid,
        'email': _emailController
            .text, // Required for uniqueness check/lookup technically?
        // But backend logic update uses firebaseUid to find.
        'photoUrl': photoUrl,
      };

      // 3. Update Backend
      final result = await _apiService.registerUser(updateData);

      if (result != null) {
        // 4. Update Local Prefs
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', _nameController.text.trim());
        await prefs.setString('user_phone', _phoneController.text.trim());
        if (photoUrl != null) await prefs.setString('user_photo', photoUrl);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Return true to trigger refresh
        }
      } else {
        throw Exception('Backend update failed');
      }
    } catch (e) {
      debugPrint("Save error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Save failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveLayout.isDesktop(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Navbar
                  if (isDesktop)
                    Container(
                      color: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 80 : 20,
                        vertical: isDesktop ? 20 : 16,
                      ),
                      child: Navbar(scaffoldKey: _scaffoldKey),
                    ),

                  // Header
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 80 : 20,
                      vertical: isDesktop ? 60 : 40,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            LucideIcons.arrowLeft,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Edit Profile',
                          style: GoogleFonts.poppins(
                            fontSize: isDesktop ? 32 : 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textHeading,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Form
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 80 : 20,
                      vertical: isDesktop ? 0 : 20,
                    ),
                    constraints: BoxConstraints(
                      maxWidth: isDesktop ? 800 : double.infinity,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Avatar Section
                          Center(
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                      width: 4,
                                    ),
                                    image: (_pickedImage != null)
                                        ? (kIsWeb
                                              // On Web we can't use FileImage easily with path?
                                              // Image.network(blobUrl) is better.
                                              // Actually NetworkImage(_pickedImage.path) works on web for blobs.
                                              ? DecorationImage(
                                                  image: NetworkImage(
                                                    _pickedImage!.path,
                                                  ),
                                                  fit: BoxFit.cover,
                                                )
                                              : DecorationImage(
                                                  image: FileImage(
                                                    File(_pickedImage!.path),
                                                  ),
                                                  fit: BoxFit.cover,
                                                ))
                                        : (_currentPhotoUrl != null &&
                                              _currentPhotoUrl!.isNotEmpty)
                                        ? DecorationImage(
                                            image: NetworkImage(
                                              _currentPhotoUrl!,
                                            ),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                    color: Colors.grey.shade200,
                                  ),
                                  child:
                                      (_pickedImage == null &&
                                          (_currentPhotoUrl == null ||
                                              _currentPhotoUrl!.isEmpty))
                                      ? const Icon(
                                          LucideIcons.user,
                                          size: 60,
                                          color: Colors.grey,
                                        )
                                      : null,
                                ),
                                GestureDetector(
                                  onTap: _pickImage,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      color: AppColors.primaryButton,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      LucideIcons.camera,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),
                          Center(
                            child: TextButton.icon(
                              onPressed: _pickImage,
                              icon: const Icon(LucideIcons.upload, size: 18),
                              label: const Text('Change Photo'),
                            ),
                          ),

                          const SizedBox(height: 48),

                          // Fields
                          _buildTextField(
                            controller: _nameController,
                            label: 'Full Name',
                            icon: LucideIcons.user,
                            validator: (v) => v!.isEmpty ? 'Enter Name' : null,
                          ),
                          const SizedBox(height: 24),

                          Opacity(
                            opacity: 0.6,
                            child: _buildTextField(
                              controller: _emailController,
                              label: 'Email (Cannot be changed)',
                              icon: LucideIcons.mail,
                              readOnly: true,
                            ),
                          ),
                          const SizedBox(height: 24),

                          _buildTextField(
                            controller: _phoneController,
                            label: 'Phone Number',
                            icon: LucideIcons.phone,
                            keyboardType: TextInputType.phone,
                          ),

                          const SizedBox(height: 48),

                          // Actions
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 20,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    'Cancel',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _isSaving ? null : _saveProfile,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryButton,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 20,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: _isSaving
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(
                                          'Save Changes',
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                  if (isDesktop) const Footer(),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool readOnly = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primaryButton),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: readOnly ? Colors.grey.shade100 : const Color(0xFFF9FAFB),
      ),
    );
  }
}
