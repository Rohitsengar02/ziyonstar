import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../responsive.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Terms & Conditions',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Responsive(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Last Updated: January 2026',
                style: GoogleFonts.inter(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 24),
              _buildSection(
                '1. Acceptance of Terms',
                'By registering as a technician on ZiyonStar, you agree to abide by these terms and conditions. If you do not agree, please do not use the platform.',
              ),
              _buildSection(
                '2. Service Standards',
                'All technicians are expected to maintain professional behavior, use genuine parts where applicable, and provide accurate timelines to customers.',
              ),
              _buildSection(
                '3. Payouts & Commissions',
                'ZiyonStar charges a commission on every successful repair. Payouts are processed weekly after deducting applicable taxes and fees.',
              ),
              _buildSection(
                '4. Privacy Policy',
                'We value your privacy. Please read our detailed privacy policy on our website to understand how we handle your data.',
              ),
              _buildSection(
                '5. Termination',
                'ZiyonStar reserves the right to suspend or terminate accounts that violate platform policies or receive consistently low customer ratings.',
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.inter(color: Colors.grey[800], height: 1.5),
          ),
        ],
      ),
    );
  }
}
