import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme.dart';
import '../responsive.dart';

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
                      Expanded(child: _buildQuickLinks()),
                      const SizedBox(width: 40),
                      Expanded(child: _buildServices()),
                      const SizedBox(width: 40),
                      Expanded(child: _buildContact()),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBrandSection(),
                      const SizedBox(height: 40),
                      _buildQuickLinks(),
                      const SizedBox(height: 30),
                      _buildServices(),
                      const SizedBox(height: 30),
                      _buildContact(),
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
                        '© 2024 Ziyonstar. All rights reserved.',
                        style: GoogleFonts.manrope(
                          color: Colors.white.withAlpha(180),
                          fontSize: 14,
                        ),
                      ),
                      Row(
                        children: [
                          _buildFooterLink('Privacy Policy'),
                          const SizedBox(width: 24),
                          _buildFooterLink('Terms of Service'),
                          const SizedBox(width: 24),
                          _buildFooterLink('Cookie Policy'),
                        ],
                      ),
                    ],
                  )
                : Column(
                    children: [
                      Text(
                        '© 2024 Ziyonstar. All rights reserved.',
                        style: GoogleFonts.manrope(
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
                          _buildFooterLink('Privacy Policy'),
                          _buildFooterLink('Terms of Service'),
                          _buildFooterLink('Cookie Policy'),
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
              style: GoogleFonts.poppins(
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
          style: GoogleFonts.manrope(
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

  Widget _buildQuickLinks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Links',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        _buildLink('About Us'),
        _buildLink('Our Services'),
        _buildLink('Locations'),
        _buildLink('Careers'),
        _buildLink('Blog'),
      ],
    );
  }

  Widget _buildServices() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Services',
          style: GoogleFonts.poppins(
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
        _buildLink('Warranty Info'),
      ],
    );
  }

  Widget _buildContact() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact Us',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              LucideIcons.phone,
              color: Colors.white.withAlpha(180),
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '+1 (555) 123-4567',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  color: Colors.white.withAlpha(180),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              LucideIcons.mail,
              color: Colors.white.withAlpha(180),
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'support@ziyonstar.com',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  color: Colors.white.withAlpha(180),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              LucideIcons.mapPin,
              color: Colors.white.withAlpha(180),
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '123 Tech Street, Silicon Valley, CA 94025',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  color: Colors.white.withAlpha(180),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLink(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: GoogleFonts.manrope(
          fontSize: 14,
          color: Colors.white.withAlpha(180),
          height: 1.5,
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

  Widget _buildFooterLink(String text) {
    return Text(
      text,
      style: GoogleFonts.manrope(
        color: Colors.white.withAlpha(180),
        fontSize: 14,
      ),
    );
  }
}
