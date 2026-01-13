import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme.dart';
import '../responsive.dart';
import '../widgets/navbar.dart';
import '../widgets/app_drawer.dart';
import '../widgets/footer.dart';

class TermsConditionsPage extends StatefulWidget {
  const TermsConditionsPage({super.key});

  @override
  State<TermsConditionsPage> createState() => _TermsConditionsPageState();
}

class _TermsConditionsPageState extends State<TermsConditionsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveLayout.isDesktop(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 80 : 20,
                vertical: isDesktop ? 20 : 16,
              ),
              child: Navbar(scaffoldKey: _scaffoldKey),
            ),

            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 80 : 20,
                vertical: isDesktop ? 80 : 60,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryButton.withOpacity(0.05),
                    Colors.white,
                  ],
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    LucideIcons.fileText,
                    size: 64,
                    color: AppColors.primaryButton,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Terms & Conditions',
                    style: GoogleFonts.poppins(
                      fontSize: isDesktop ? 48 : 36,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textHeading,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Last updated: January 13, 2026',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textBody,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 80 : 20,
                vertical: isDesktop ? 60 : 40,
              ),
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 900 : double.infinity,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    'Acceptance of Terms',
                    'By accessing and using Ziyonstar\'s services, you accept and agree to be bound by these Terms and Conditions. If you do not agree to these terms, please do not use our services.',
                  ),
                  _buildSection(
                    'Service Description',
                    'Ziyonstar provides device repair services including but not limited to:\n\n• Mobile phone repairs\n• Laptop repairs\n• Tablet repairs\n• Doorstep repair services\n• Walk-in repair services',
                  ),
                  _buildSection(
                    'Service Warranty',
                    'We provide a 1-year warranty on all repairs using genuine parts. The warranty covers:\n\n• Defects in workmanship\n• Replacement parts malfunction\n• Service-related issues\n\nWarranty does not cover physical damage, liquid damage, or unauthorized modifications.',
                  ),
                  _buildSection(
                    'Payment Terms',
                    'Payment is required upon completion of service unless otherwise agreed. We accept:\n\n• Cash\n• Credit/Debit cards\n• UPI payments\n• Online banking\n\nAll prices are subject to applicable taxes.',
                  ),
                  _buildSection(
                    'Cancellation Policy',
                    'You may cancel your booking up to 2 hours before the scheduled appointment without any charges. Cancellations made within 2 hours of the appointment may incur a cancellation fee.',
                  ),
                  _buildSection(
                    'Liability Limitations',
                    'While we take utmost care in handling your devices, Ziyonstar is not liable for:\n\n• Data loss during repair\n• Pre-existing damage not disclosed\n• Damage due to external factors\n• Delays beyond our control\n\nWe recommend backing up your data before service.',
                  ),
                  _buildSection(
                    'Customer Responsibilities',
                    'As a customer, you agree to:\n\n• Provide accurate device information\n• Disclose all known issues\n• Remove personal data when possible\n• Pay for services as agreed\n• Comply with our policies',
                  ),
                  _buildSection(
                    'Intellectual Property',
                    'All content, trademarks, and intellectual property on our website and app belong to Ziyonstar. Unauthorized use is prohibited.',
                  ),
                  _buildSection(
                    'Dispute Resolution',
                    'Any disputes arising from these terms will be resolved through arbitration in accordance with local laws. The venue for arbitration shall be Silicon Valley, California.',
                  ),
                  _buildSection(
                    'Modifications',
                    'We reserve the right to modify these terms at any time. Continued use of our services constitutes acceptance of the modified terms.',
                  ),
                  _buildSection(
                    'Contact Information',
                    'For questions about these Terms & Conditions:\n\nEmail: legal@ziyonstar.com\nPhone: +1 (555) 123-4567\nAddress: 123 Tech Street, Silicon Valley, CA 94025',
                  ),
                ],
              ),
            ),

            const Footer(),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textHeading,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: AppColors.textBody,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}
