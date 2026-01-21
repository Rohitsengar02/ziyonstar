import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../responsive.dart';
import '../screens/about_page.dart';
import '../screens/contact_page.dart';
import '../screens/my_bookings_screen.dart';
import '../screens/repair_page.dart';
import '../screens/privacy_policy_page.dart';
import '../screens/terms_conditions_page.dart';
import '../screens/return_refund_page.dart';
import '../screens/child_protection_page.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveLayout.isDesktop(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF1F2937), const Color(0xFF111827)],
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 24,
              vertical: isDesktop ? 80 : 60,
            ),
            child: isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: _buildBrandSection()),
                      const SizedBox(width: 60),
                      Expanded(child: _buildQuickLinks(context)),
                      const SizedBox(width: 40),
                      Expanded(child: _buildServices()),
                      const SizedBox(width: 40),
                      Expanded(child: _buildLegalSection(context)),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBrandSection(),
                      const SizedBox(height: 40),
                      _buildQuickLinks(context),
                      const SizedBox(height: 30),
                      _buildServices(),
                      const SizedBox(height: 30),
                      _buildLegalSection(context),
                    ],
                  ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.white.withAlpha(20), width: 1),
              ),
            ),
            child: isDesktop
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '© 2026 Ziyonstar. All rights reserved.',
                        style: GoogleFonts.inter(
                          color: Colors.white.withAlpha(180),
                          fontSize: 14,
                        ),
                      ),
                      Row(
                        children: [
                          _buildFooterLink(
                            context,
                            'Privacy Policy',
                            const PrivacyPolicyPage(),
                          ),
                          const SizedBox(width: 24),
                          _buildFooterLink(
                            context,
                            'Terms & Conditions',
                            const TermsConditionsPage(),
                          ),
                          const SizedBox(width: 24),
                          _buildFooterLink(
                            context,
                            'Return & Refund',
                            const ReturnRefundPage(),
                          ),
                        ],
                      ),
                    ],
                  )
                : Column(
                    children: [
                      Text(
                        '© 2026 Ziyonstar. All rights reserved.',
                        style: GoogleFonts.inter(
                          color: Colors.white.withAlpha(180),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          _buildFooterLink(
                            context,
                            'Privacy',
                            const PrivacyPolicyPage(),
                          ),
                          _buildFooterLink(
                            context,
                            'Terms',
                            const TermsConditionsPage(),
                          ),
                          _buildFooterLink(
                            context,
                            'Refund',
                            const ReturnRefundPage(),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Icon(
                  LucideIcons.smartphone,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Ziyonstar',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'Your trusted partner for professional device repair services. Quality repairs, expert technicians, and customer satisfaction guaranteed.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.white.withAlpha(180),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            _buildSocialIcon(LucideIcons.facebook),
            const SizedBox(width: 12),
            _buildSocialIcon(LucideIcons.twitter),
            const SizedBox(width: 12),
            _buildSocialIcon(LucideIcons.instagram),
            const SizedBox(width: 12),
            _buildSocialIcon(LucideIcons.linkedin),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickLinks(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Links',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        _buildClickableLink(context, 'Home', null),
        _buildClickableLink(context, 'Repair Services', const RepairPage()),
        _buildClickableLink(context, 'About Us', const AboutPage()),
        _buildClickableLink(context, 'My Bookings', const MyBookingsScreen()),
        _buildClickableLink(context, 'Contact Us', const ContactPage()),
      ],
    );
  }

  Widget _buildServices() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Services',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        _buildLink('Screen Repair'),
        _buildLink('Battery Replacement'),
        _buildLink('Water Damage'),
        _buildLink('Data Recovery'),
        _buildLink('Doorstep Service'),
      ],
    );
  }

  Widget _buildLegalSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Legal',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        _buildClickableLink(
          context,
          'Privacy Policy',
          const PrivacyPolicyPage(),
        ),
        _buildClickableLink(
          context,
          'Terms & Conditions',
          const TermsConditionsPage(),
        ),
        _buildClickableLink(
          context,
          'Return & Refund',
          const ReturnRefundPage(),
        ),
        _buildClickableLink(
          context,
          'Child Protection',
          const ChildProtectionPage(),
        ),
      ],
    );
  }

  Widget _buildLink(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 14,
          color: Colors.white.withAlpha(180),
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildClickableLink(BuildContext context, String text, Widget? page) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          if (page != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => page),
            );
          }
        },
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.white.withAlpha(180),
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(child: Icon(icon, color: Colors.white, size: 18)),
    );
  }

  Widget _buildFooterLink(BuildContext context, String text, Widget page) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
      child: Text(
        text,
        style: GoogleFonts.inter(
          color: Colors.white.withAlpha(180),
          fontSize: 14,
        ),
      ),
    );
  }
}
