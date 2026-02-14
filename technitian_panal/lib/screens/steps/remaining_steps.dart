import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/api_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../login_screen.dart';

// Helper for Card Selection
class SelectionCard extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  const SelectionCard({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey.shade200,
            width: 1.5,
          ),
          boxShadow: [
            if (!isSelected)
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.black,
                size: 22,
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                LucideIcons.checkCircle,
                color: Colors.white,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

// SCREEN: Service Type
class ServiceTypeStep extends StatefulWidget {
  final VoidCallback onNext;
  const ServiceTypeStep({super.key, required this.onNext});
  @override
  State<ServiceTypeStep> createState() => _ServiceTypeStepState();
}

class _ServiceTypeStepState extends State<ServiceTypeStep> {
  bool doorStep = true;
  bool walkIn = false;
  bool pickup = false;
  bool _isLoading = false;

  Future<void> _handleNext() async {
    final List<String> types = [];
    if (doorStep) types.add('Doorstep Repair');
    if (walkIn) types.add('Walk-in / Store');
    if (pickup) types.add('Pickup & Drop');

    if (types.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one service type'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await ApiService().updateTechnicianProfile(
          firebaseUid: user.uid,
          data: {'serviceTypes': types},
        );
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
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Service Type',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'How do you want to provide your services?',
                  style: GoogleFonts.inter(color: Colors.grey),
                ),
                const SizedBox(height: 32),
                _buildChoiceCard(
                  'Doorstep Repair',
                  'Travel to customer location',
                  LucideIcons.home,
                  doorStep,
                  () => setState(() => doorStep = !doorStep),
                ),
                const SizedBox(height: 16),
                _buildChoiceCard(
                  'Walk-in / Store',
                  'Customer comes to your shop',
                  LucideIcons.store,
                  walkIn,
                  () => setState(() => walkIn = !walkIn),
                ),
                const SizedBox(height: 16),
                _buildChoiceCard(
                  'Pickup & Drop',
                  'Collect, repair & deliver back',
                  LucideIcons.truck,
                  pickup,
                  () => setState(() => pickup = !pickup),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
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
        ),
      ],
    );
  }

  Widget _buildChoiceCard(
    String title,
    String sub,
    IconData icon,
    bool selected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: selected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? Colors.black : Colors.grey.shade200,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withOpacity(0.1)
                    : Colors.grey[50],
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: selected ? Colors.white : Colors.black,
                size: 26,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      color: selected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    sub,
                    style: GoogleFonts.inter(
                      color: selected ? Colors.white70 : Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(
                LucideIcons.checkCircle,
                color: Colors.white,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}

// SCREEN: Coverage Area (MULTIPLE CITIES & PINCODES)
class CoverageStep extends StatefulWidget {
  final VoidCallback onNext;
  const CoverageStep({super.key, required this.onNext});
  @override
  State<CoverageStep> createState() => _CoverageStepState();
}

class _CoverageStepState extends State<CoverageStep> {
  final List<String> _cities = [];
  final List<String> _siteCodes = [];
  final TextEditingController _cityCtrl = TextEditingController();
  final TextEditingController _pinCtrl = TextEditingController();
  bool _isLoading = false;

  void _addCity() {
    if (_cityCtrl.text.isNotEmpty && !_cities.contains(_cityCtrl.text)) {
      setState(() {
        _cities.add(_cityCtrl.text);
        _cityCtrl.clear();
      });
    }
  }

  void _addPin() {
    if (_pinCtrl.text.isNotEmpty && !_siteCodes.contains(_pinCtrl.text)) {
      setState(() {
        _siteCodes.add(_pinCtrl.text);
        _pinCtrl.clear();
      });
    }
  }

  Future<void> _handleNext() async {
    final allCoverage = [..._cities, ..._siteCodes];
    if (allCoverage.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one city or pincode'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await ApiService().updateTechnicianProfile(
          firebaseUid: user.uid,
          data: {'coverageAreas': allCoverage},
        );
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
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Service Coverage',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Define the areas where you can provide service.',
                  style: GoogleFonts.inter(color: Colors.grey),
                ),
                const SizedBox(height: 32),

                Text(
                  'Cities You Cover',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _cityCtrl,
                  decoration: InputDecoration(
                    hintText: 'Add a city...',
                    prefixIcon: const Icon(LucideIcons.map),
                    suffixIcon: IconButton(
                      icon: const Icon(
                        LucideIcons.plusCircle,
                        color: Colors.black,
                      ),
                      onPressed: _addCity,
                    ),
                  ),
                  onSubmitted: (_) => _addCity(),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _cities
                      .map(
                        (city) => Chip(
                          label: Text(
                            city,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          backgroundColor: Colors.black,
                          deleteIcon: const Icon(
                            LucideIcons.x,
                            size: 14,
                            color: Colors.white,
                          ),
                          onDeleted: () => setState(() => _cities.remove(city)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      )
                      .toList(),
                ),

                const SizedBox(height: 32),

                Text(
                  'Pincodes / Zipcodes',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _pinCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Add a pincode...',
                    prefixIcon: const Icon(LucideIcons.navigation),
                    suffixIcon: IconButton(
                      icon: const Icon(
                        LucideIcons.plusCircle,
                        color: Colors.black,
                      ),
                      onPressed: _addPin,
                    ),
                  ),
                  onSubmitted: (_) => _addPin(),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: _siteCodes
                      .map(
                        (pin) => Chip(
                          label: Text(pin),
                          backgroundColor: Colors.grey[100],
                          deleteIcon: const Icon(LucideIcons.x, size: 14),
                          onDeleted: () =>
                              setState(() => _siteCodes.remove(pin)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
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
        ),
      ],
    );
  }
}

// SCREEN: Bank Details
class BankStep extends StatefulWidget {
  final VoidCallback onNext;
  const BankStep({super.key, required this.onNext});
  @override
  State<BankStep> createState() => _BankStepState();
}

class _BankStepState extends State<BankStep> {
  final _holderCtrl = TextEditingController();
  final _accountCtrl = TextEditingController();
  final _ifscCtrl = TextEditingController();
  final _upiCtrl = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleNext() async {
    if (_holderCtrl.text.isEmpty ||
        _accountCtrl.text.isEmpty ||
        _ifscCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill compulsory fields')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await ApiService().updateTechnicianProfile(
          firebaseUid: user.uid,
          data: {
            'accountHolderName': _holderCtrl.text.trim(),
            'accountNumber': _accountCtrl.text.trim(),
            'ifscCode': _ifscCtrl.text.trim(),
            'upiId': _upiCtrl.text.trim(),
            'bankName':
                'Bank Name', // Should ideally allow input or fetch from IFSC
          },
        );

        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'bankDetails': {
            'accountHolderName': _holderCtrl.text.trim(),
            'accountNumber': _accountCtrl.text.trim(),
            'ifscCode': _ifscCtrl.text.trim(),
            'upiId': _upiCtrl.text.trim(),
          },
        }, SetOptions(merge: true));

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
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payout Details',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Where should we send your earnings?',
                  style: GoogleFonts.inter(color: Colors.grey),
                ),
                const SizedBox(height: 32),

                _buildInputGroup(
                  'Account Holder Name',
                  LucideIcons.user,
                  'As per bank records',
                  _holderCtrl,
                ),
                const SizedBox(height: 20),
                _buildInputGroup(
                  'Bank Account Number',
                  LucideIcons.creditCard,
                  '0000 0000 0000 0000',
                  _accountCtrl,
                ),
                const SizedBox(height: 20),
                _buildInputGroup(
                  'IFSC Code',
                  LucideIcons.building,
                  'SBIN0001234',
                  _ifscCtrl,
                ),
                const SizedBox(height: 20),
                _buildInputGroup(
                  'UPI ID (Optional)',
                  LucideIcons.smartphone,
                  'yourname@upi',
                  _upiCtrl,
                ),

                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        LucideIcons.info,
                        size: 18,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'We may send a ₹1 test transaction to verify your account.',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
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
        ),
      ],
    );
  }

  Widget _buildInputGroup(
    String label,
    IconData icon,
    String hint,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
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
          ),
        ),
      ],
    );
  }
}

// SCREEN: Agreement
class AgreementStep extends StatefulWidget {
  final VoidCallback onNext;
  const AgreementStep({super.key, required this.onNext});
  @override
  State<AgreementStep> createState() => _AgreementStepState();
}

class _AgreementStepState extends State<AgreementStep> {
  bool _agreed = false;
  bool _isLoading = false;

  Future<void> _handleNext() async {
    if (!_agreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept terms and conditions')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await ApiService().updateTechnicianProfile(
          firebaseUid: user.uid,
          data: {'agreedToTerms': true},
        );
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
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Final Terms',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Review and sign the technician agreement.',
                  style: GoogleFonts.inter(color: Colors.grey),
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SingleChildScrollView(
                        child: Text(
                          'ZiyonStar Technician Agreement\n\n'
                          '1. Service Standards: Technicians must maintain high quality and punctuality.\n'
                          '2. Payment: Weekly payouts on Tuesdays.\n'
                          '3. Commission: 15% platform fee applies to all bookings.\n'
                          '4. Professionalism: Use of platform for personal deals is strictly prohibited.\n'
                          '5. Safety: Technicians are responsible for their own insurance.\n\n'
                          'I hereby confirm that all information provided is true and accurate to the best of my knowledge.',
                          style: GoogleFonts.inter(
                            height: 1.8,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SelectionCard(
                  title: 'I accept all terms & conditions',
                  isSelected: _agreed,
                  onTap: () => setState(() => _agreed = !_agreed),
                  icon: LucideIcons.fileSignature,
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
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
        ),
      ],
    );
  }
}

class StatusStep extends StatefulWidget {
  final VoidCallback onNext;
  const StatusStep({super.key, required this.onNext});

  @override
  State<StatusStep> createState() => _StatusStepState();
}

class _StatusStepState extends State<StatusStep> {
  String? _techName;
  bool _isLoadingName = true;

  @override
  void initState() {
    super.initState();
    _fetchTechName();
  }

  Future<void> _fetchTechName() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final techData = await ApiService().getTechnician(user.uid);
        if (techData != null) {
          setState(() {
            _techName = techData['name'];
            _isLoadingName = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching tech name: $e');
      setState(() => _isLoadingName = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Branded T-Shirt Section
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // T-Shirt Image (Black T-shirt on white background)
                      Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Image.asset(
                          'assets/tswhirt.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_isLoadingName)
                    const SizedBox(height: 20)
                  else
                    Text(
                      _techName?.toUpperCase() ?? 'TECHNICIAN',
                      style: GoogleFonts.inter(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                  const SizedBox(height: 32),
                  Text(
                    'Evaluating Profile',
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your documents are being verified by our team.\nWe will notify you once you are "On Duty".',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: Colors.grey,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 40),
                  _statusTile(
                    'KYC Documents',
                    'Under Review',
                    LucideIcons.files,
                    Colors.orange,
                  ),
                  const SizedBox(height: 12),
                  _statusTile(
                    'Service Areas',
                    'Active',
                    LucideIcons.map,
                    Colors.green,
                  ),
                  const SizedBox(height: 12),
                  _statusTile(
                    'Bank Details',
                    'Verified',
                    LucideIcons.checkCircle,
                    Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  _statusTile(
                    'Official T-Shirt',
                    'Pending Delivery',
                    LucideIcons.shirt,
                    Colors.red,
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Application is pending only'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _statusTile(String title, String status, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: GoogleFonts.inter(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
