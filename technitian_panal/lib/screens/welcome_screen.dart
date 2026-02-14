import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'login_screen.dart';
import '../responsive.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Responsive(
        child: Stack(
          children: [
            // Decorative Overflow specific to request (7px overflow attempt)
            Positioned(
              right: -20, // Reduced to visually match "overflowed" feeling
              top: 100,
              child: Opacity(
                opacity: 0.1,
                child: Transform.rotate(
                  angle: 0.2,
                  child: const Icon(
                    LucideIcons.wrench,
                    size: 300,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32.0,
                  vertical: 24.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        LucideIcons.wrench,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 32),
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.poppins(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          height: 1.1,
                        ),
                        children: [
                          const TextSpan(text: 'Join\n'),
                          TextSpan(
                            text: 'ZiyonStar',
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                          const TextSpan(text: '\nPartner Network'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),
                    _buildBenefitRow(
                      LucideIcons.banknote,
                      'Earn daily by repairing phones',
                    ),
                    const SizedBox(height: 24),
                    _buildBenefitRow(
                      LucideIcons.clock,
                      'Flexible timings - Be your own boss',
                    ),
                    const SizedBox(height: 24),
                    _buildBenefitRow(
                      LucideIcons.wallet,
                      'Weekly payouts directly to bank',
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                        child: const Text('Get Started'),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.black, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
