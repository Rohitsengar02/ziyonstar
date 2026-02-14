import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/api_service.dart';
import '../../theme.dart';
import '../../responsive.dart';

class ServiceAreasScreen extends StatefulWidget {
  final Map<String, dynamic> technicianData;
  const ServiceAreasScreen({super.key, required this.technicianData});

  @override
  State<ServiceAreasScreen> createState() => _ServiceAreasScreenState();
}

class _ServiceAreasScreenState extends State<ServiceAreasScreen> {
  final _apiService = ApiService();
  final _radiusController = TextEditingController();
  final _pincodeController = TextEditingController();

  late List<String> _pincodes;
  late List<String> _serviceTypes;
  bool _isLoading = false;

  final List<String> _allServiceTypes = [
    'Home Service',
    'Store Pickup',
    'Mail-in Repair',
    'On-site Repair',
  ];

  @override
  void initState() {
    super.initState();
    _pincodes = List<String>.from(
      (widget.technicianData['coverageAreas'] as List<dynamic>?)?.map(
            (e) => e.toString(),
          ) ??
          [],
    );
    _serviceTypes = List<String>.from(
      (widget.technicianData['serviceTypes'] as List<dynamic>?)?.map(
            (e) => e.toString(),
          ) ??
          [],
    );
    _radiusController.text =
        widget.technicianData['serviceAreaRadius']?.toString() ?? '10';
  }

  @override
  void dispose() {
    _radiusController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _apiService.updateTechnicianProfile(
          firebaseUid: user.uid,
          data: {
            'serviceAreaRadius': _radiusController.text.trim(),
            'coverageAreas': _pincodes,
            'serviceTypes': _serviceTypes,
          },
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Service areas updated successfully')),
          );
          Navigator.pop(context, true);
        }
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

  void _addPincode() {
    final code = _pincodeController.text.trim();
    if (code.isNotEmpty && !_pincodes.contains(code)) {
      setState(() {
        _pincodes.add(code);
        _pincodeController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Service Areas',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          if (!_isLoading)
            IconButton(
              onPressed: _saveChanges,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Service Radius'),
                    const SizedBox(height: 12),
                    _buildRadiusInput(),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Coverage Pincodes'),
                    const SizedBox(height: 12),
                    _buildPincodeInput(),
                    const SizedBox(height: 16),
                    _buildPincodeChips(),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Service Types'),
                    const SizedBox(height: 12),
                    _buildServiceTypeSelection(),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveChanges,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryButton,
                          padding: const EdgeInsets.symmetric(vertical: 16),
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
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildRadiusInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.navigation, size: 20, color: Colors.grey),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: _radiusController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Distance in KM',
                border: InputBorder.none,
                isDense: true,
              ),
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            'KM',
            style: GoogleFonts.inter(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPincodeInput() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _pincodeController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Enter pincode',
              fillColor: Colors.grey[50],
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              isDense: true,
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: _addPincode,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
          child: const Text('Add', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildPincodeChips() {
    if (_pincodes.isEmpty) {
      return Text(
        'No pincodes added yet',
        style: GoogleFonts.inter(color: Colors.grey, fontSize: 13),
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _pincodes.map((p) {
        return Chip(
          label: Text(p, style: const TextStyle(fontSize: 12)),
          onDeleted: () => setState(() => _pincodes.remove(p)),
          deleteIcon: const Icon(LucideIcons.x, size: 14),
          backgroundColor: Colors.grey[100],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          side: BorderSide.none,
        );
      }).toList(),
    );
  }

  Widget _buildServiceTypeSelection() {
    return Column(
      children: _allServiceTypes.map((type) {
        final isSelected = _serviceTypes.contains(type);
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: CheckboxListTile(
            value: isSelected,
            onChanged: (val) {
              setState(() {
                if (val == true) {
                  _serviceTypes.add(type);
                } else {
                  _serviceTypes.remove(type);
                }
              });
            },
            title: Text(
              type,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            activeColor: AppColors.primaryButton,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            tileColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
        );
      }).toList(),
    );
  }
}
