import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class PendingApprovalScreen extends StatefulWidget {
  const PendingApprovalScreen({super.key});

  @override
  State<PendingApprovalScreen> createState() => _PendingApprovalScreenState();
}

class _PendingApprovalScreenState extends State<PendingApprovalScreen> {
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
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
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/tswhirt.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          // Overlay Text (ZIYONSTAR and Technician Name)
                          Positioned(
                            top: 70,
                            child: Column(
                              children: [
                                Text(
                                  'ZIYONSTAR',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2,
                                  ),
                                ),
                                Text(
                                  'IOT',
                                  style: GoogleFonts.inter(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 4,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                if (_isLoadingName)
                                  const SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                else
                                  Text(
                                    _techName?.toUpperCase() ?? 'TECHNICIAN',
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
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
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
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
                  child: const Text('Sign Out & Return to Login'),
                ),
              ),
            ),
          ],
        ),
      ),
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
