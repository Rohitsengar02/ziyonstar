import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/api_service.dart';
import '../../theme.dart';
import '../../responsive.dart';

class BankDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> technicianData;
  const BankDetailsScreen({super.key, required this.technicianData});

  @override
  State<BankDetailsScreen> createState() => _BankDetailsScreenState();
}

class _BankDetailsScreenState extends State<BankDetailsScreen> {
  final _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _bankNameController;
  late TextEditingController _holderNameController;
  late TextEditingController _accNumberController;
  late TextEditingController _ifscController;
  late TextEditingController _upiIdController;

  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _bankNameController = TextEditingController(
      text: widget.technicianData['bankName'] ?? '',
    );
    _holderNameController = TextEditingController(
      text: widget.technicianData['accountHolderName'] ?? '',
    );
    _accNumberController = TextEditingController(
      text: widget.technicianData['accountNumber'] ?? '',
    );
    _ifscController = TextEditingController(
      text: widget.technicianData['ifscCode'] ?? '',
    );
    _upiIdController = TextEditingController(
      text: widget.technicianData['upiId'] ?? '',
    );
  }

  @override
  void dispose() {
    _bankNameController.dispose();
    _holderNameController.dispose();
    _accNumberController.dispose();
    _ifscController.dispose();
    _upiIdController.dispose();
    super.dispose();
  }

  Future<void> _saveDetails() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _apiService.updateTechnicianProfile(
          firebaseUid: user.uid,
          data: {
            'bankName': _bankNameController.text.trim(),
            'accountHolderName': _holderNameController.text.trim(),
            'accountNumber': _accNumberController.text.trim(),
            'ifscCode': _ifscController.text.toUpperCase().trim(),
            'upiId': _upiIdController.text.trim(),
          },
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bank details updated successfully')),
          );
          setState(() => _isEditing = false);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Bank Details',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          if (!_isLoading)
            IconButton(
              onPressed: () {
                if (_isEditing) {
                  _saveDetails();
                } else {
                  setState(() => _isEditing = true);
                }
              },
              icon: Icon(
                _isEditing ? LucideIcons.check : LucideIcons.edit3,
                color: AppColors.primaryButton,
                size: 20,
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
                    children: [
                      _buildBankCard(),
                      const SizedBox(height: 32),
                      _buildTextField(
                        _bankNameController,
                        'Bank Name',
                        LucideIcons.landmark,
                        enabled: _isEditing,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        _holderNameController,
                        'Account Holder Name',
                        LucideIcons.user,
                        enabled: _isEditing,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        _accNumberController,
                        'Account Number',
                        LucideIcons.hash,
                        enabled: _isEditing,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        _ifscController,
                        'IFSC Code',
                        LucideIcons.code,
                        enabled: _isEditing,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        _upiIdController,
                        'UPI ID',
                        LucideIcons.atSign,
                        enabled: _isEditing,
                      ),
                      const SizedBox(height: 48),
                      _buildDisclaimer(),
                      if (_isEditing) ...[
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _saveDetails,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryButton,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Save Bank Details',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildBankCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black, Colors.grey[900]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(LucideIcons.landmark, color: Colors.white, size: 24),
              Text(
                'PRIMARY ACCOUNT',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: Colors.white.withOpacity(0.5),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            _accNumberController.text.isEmpty
                ? '•••• •••• ••••'
                : _accNumberController.text,
            style: GoogleFonts.inter(
              fontSize: 22,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCardInfo(
                'ACCOUNT HOLDER',
                _holderNameController.text.isEmpty
                    ? 'N/A'
                    : _holderNameController.text,
              ),
              _buildCardInfo(
                'IFSC CODE',
                _ifscController.text.isEmpty
                    ? 'N/A'
                    : _ifscController.text.toUpperCase(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool enabled = true,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      validator: (v) => v!.isEmpty ? '$label is required' : null,
      onChanged: (v) => setState(() {}),
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

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.shieldCheck, color: Colors.amber, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your bank details are encrypted and safe. These details will be used for all your platform payouts.',
              style: GoogleFonts.inter(fontSize: 12, color: Colors.amber[900]),
            ),
          ),
        ],
      ),
    );
  }
}
