import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/api_service.dart';
import '../../theme.dart';
import '../../responsive.dart';

class PersonalInformationScreen extends StatefulWidget {
  final Map<String, dynamic> technicianData;
  const PersonalInformationScreen({super.key, required this.technicianData});

  @override
  State<PersonalInformationScreen> createState() =>
      _PersonalInformationScreenState();
}

class _PersonalInformationScreenState extends State<PersonalInformationScreen> {
  final _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _dobController;
  late TextEditingController _cityController;
  late TextEditingController _radiusController;

  late String _selectedGender;
  String? _photoUrl;
  XFile? _selectedImage;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.technicianData['name'] ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.technicianData['phone'] ?? '',
    );
    _emailController = TextEditingController(
      text: widget.technicianData['email'] ?? '',
    );
    _dobController = TextEditingController(
      text: widget.technicianData['dob'] != null
          ? widget.technicianData['dob'].toString().split('T')[0]
          : '',
    );
    _cityController = TextEditingController(
      text: widget.technicianData['city'] ?? '',
    );
    _radiusController = TextEditingController(
      text: widget.technicianData['serviceAreaRadius']?.toString() ?? '',
    );
    _selectedGender = widget.technicianData['gender'] ?? 'Male';
    _photoUrl = widget.technicianData['photoUrl'];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _cityController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _selectedImage = image);
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String? finalPhotoUrl = _photoUrl;

        // 1. Upload new image if selected
        if (_selectedImage != null) {
          final uploadedUrl = await _apiService.uploadImage(_selectedImage);
          if (uploadedUrl != null) {
            finalPhotoUrl = uploadedUrl;
          }
        }

        // 2. Update via API
        await _apiService.updateTechnicianProfile(
          firebaseUid: user.uid,
          data: {
            'name': _nameController.text.trim(),
            'phone': _phoneController.text.trim(),
            'dob': _dobController.text.trim(),
            'gender': _selectedGender,
            'city': _cityController.text.trim(),
            'serviceAreaRadius': _radiusController.text.trim(),
            'photoUrl': finalPhotoUrl,
          },
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
          Navigator.pop(context, true); // Return true to trigger refresh
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update profile: $e')));
      }
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
          'Personal Information',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          if (!_isLoading)
            IconButton(
              onPressed: _updateProfile,
              icon: const Icon(
                LucideIcons.check,
                color: AppColors.primaryButton,
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Responsive(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Basic Details'),
                      const SizedBox(height: 20),

                      // Avatar Selection Section
                      Center(
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Stack(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    width: 2,
                                  ),
                                ),
                                child: _selectedImage != null
                                    ? ClipOval(
                                        child: FutureBuilder<Uint8List>(
                                          future: _selectedImage!.readAsBytes(),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              return Image.memory(
                                                snapshot.data!,
                                                fit: BoxFit.cover,
                                                width: 100,
                                                height: 100,
                                              );
                                            }
                                            return const CircularProgressIndicator();
                                          },
                                        ),
                                      )
                                    : (_photoUrl != null &&
                                              _photoUrl!.isNotEmpty
                                          ? ClipOval(
                                              child: Image.network(
                                                _photoUrl!,
                                                fit: BoxFit.cover,
                                                width: 100,
                                                height: 100,
                                                errorBuilder: (c, e, s) =>
                                                    const Icon(
                                                      LucideIcons.user,
                                                    ),
                                              ),
                                            )
                                          : const Icon(
                                              LucideIcons.user,
                                              size: 50,
                                              color: Colors.grey,
                                            )),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Colors.black,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    LucideIcons.camera,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      _buildTextField(
                        controller: _nameController,
                        label: 'Full Name',
                        icon: LucideIcons.user,
                        validator: (v) =>
                            v!.isEmpty ? 'Name is required' : null,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email Address',
                        icon: LucideIcons.mail,
                        enabled: false, // Email usually read-only
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        icon: LucideIcons.phone,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 32),
                      _buildSectionTitle('Additional Info'),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _dobController,
                        label: 'Date of Birth',
                        icon: LucideIcons.calendar,
                        readOnly: true,
                        onTap: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().subtract(
                              const Duration(days: 365 * 20),
                            ),
                            firstDate: DateTime(1960),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(
                              () => _dobController.text = picked
                                  .toString()
                                  .split(' ')[0],
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Gender',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: ['Male', 'Female', 'Other'].map((g) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: ChoiceChip(
                              label: Text(g),
                              selected: _selectedGender == g,
                              onSelected: (val) {
                                if (val) setState(() => _selectedGender = g);
                              },
                              selectedColor: AppColors.primaryButton.withValues(
                                alpha: 0.2,
                              ),
                              labelStyle: GoogleFonts.inter(
                                color: _selectedGender == g
                                    ? AppColors.primaryButton
                                    : Colors.black,
                                fontWeight: _selectedGender == g
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 32),
                      _buildSectionTitle('Location & Service'),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _cityController,
                        label: 'City',
                        icon: LucideIcons.mapPin,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _radiusController,
                        label: 'Service Radius (km)',
                        icon: LucideIcons.navigation,
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _updateProfile,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: AppColors.primaryButton,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
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
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    bool readOnly = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      readOnly: readOnly,
      onTap: onTap,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        filled: !enabled,
        fillColor: !enabled ? Colors.grey[50] : null,
      ),
    );
  }
}
