import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme.dart';
import '../responsive.dart';
import '../widgets/navbar.dart';
import '../widgets/app_drawer.dart';
import '../widgets/footer.dart';

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveLayout.isDesktop(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: isDesktop
          ? null
          : AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(LucideIcons.arrowLeft, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'Privacy Policy',
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
            ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
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

            // Hero Section
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
                    LucideIcons.shield,
                    size: 64,
                    color: AppColors.primaryButton,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Privacy Policy',
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

            // Content
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
                    'Introduction',
                    'At Ziyonstar, we are committed to protecting your privacy and ensuring the security of your personal information. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our device repair services.',
                  ),
                  _buildSection(
                    'Information We Collect',
                    'We collect information that you provide directly to us, including:\n\n• Personal identification information (name, email address, phone number)\n• Device information and repair details\n• Payment and billing information\n• Service address and location data\n• Communication preferences',
                  ),
                  _buildSection(
                    'How We Use Your Information',
                    'We use the information we collect to:\n\n• Provide, maintain, and improve our repair services\n• Process your transactions and send related information\n• Send you technical notices and support messages\n• Respond to your comments and questions\n• Monitor and analyze trends and usage\n• Detect, prevent, and address technical issues',
                  ),
                  _buildSection(
                    'Information Sharing',
                    'We do not sell, trade, or rent your personal information to third parties. We may share your information only in the following circumstances:\n\n• With service providers who assist in our operations\n• To comply with legal obligations\n• To protect our rights and prevent fraud\n• With your consent or at your direction',
                  ),
                  _buildSection(
                    'Data Security',
                    'We implement appropriate technical and organizational measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction. However, no method of transmission over the internet is 100% secure.',
                  ),
                  _buildSection(
                    'Your Rights',
                    'You have the right to:\n\n• Access your personal information\n• Correct inaccurate data\n• Request deletion of your data\n• Opt-out of marketing communications\n• Withdraw consent at any time',
                  ),
                  _buildSection(
                    'Cookies and Tracking',
                    'We use cookies and similar tracking technologies to track activity on our website and store certain information. You can instruct your browser to refuse all cookies or to indicate when a cookie is being sent.',
                  ),
                  _buildSection(
                    'Children\'s Privacy',
                    'Our services are not intended for children under 13 years of age. We do not knowingly collect personal information from children under 13.',
                  ),
                  _buildSection(
                    'Changes to This Policy',
                    'We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last updated" date.',
                  ),
                  _buildSection(
                    'Contact Us',
                    'If you have questions about this Privacy Policy, please contact us at:\n\nEmail: privacy@ziyonstar.com\nPhone: +1 (555) 123-4567\nAddress: 123 Tech Street, Silicon Valley, CA 94025',
                  ),
                ],
              ),
            ),

            if (isDesktop) const Footer(),
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
