import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../responsive.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Privacy Policy',
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
                'Last Updated: February 2026',
                style: GoogleFonts.inter(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 24),
              _buildSection(
                '1. Information We Collect',
                'We collect information you provide directly to us, such as when you create or modify your account. This may include your name, email address, phone number, profile picture, and banking details for payouts.',
              ),
              _buildSection(
                '2. Use of Information',
                'We may use the information we collect to provide, maintain, and improve our services, including to facilitate payments, send receipts, provide customer support, and communicate with you about products, services, offers, and events.',
              ),
              _buildSection(
                '3. Location Data',
                'As a technician, we collect your precise or approximate location data from your mobile device when the ZiyonStar app is running in the foreground or background. This is necessary for job assignment and tracking.',
              ),
              _buildSection(
                '4. Data Sharing',
                'We may share the information we collect with vendors, consultants, and other service providers who need access to such information to carry out work on our behalf, or with customers involved in your jobs.',
              ),
              _buildSection(
                '5. Security',
                'We take reasonable measures to help protect information about you from loss, theft, misuse and unauthorized access, disclosure, alteration and destruction.',
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
