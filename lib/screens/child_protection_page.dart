import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme.dart';
import '../responsive.dart';
import '../widgets/navbar.dart';
import '../widgets/app_drawer.dart';
import '../widgets/footer.dart';

class ChildProtectionPage extends StatefulWidget {
  const ChildProtectionPage({super.key});

  @override
  State<ChildProtectionPage> createState() => _ChildProtectionPageState();
}

class _ChildProtectionPageState extends State<ChildProtectionPage> {
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
                    LucideIcons.heart,
                    size: 64,
                    color: AppColors.primaryButton,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Child Protection Policy',
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
                    'Our Commitment to Child Safety',
                    'Ziyonstar is committed to protecting children and ensuring their safety in all aspects of our service delivery. We have zero tolerance for child abuse and are dedicated to creating a safe environment for all.',
                  ),
                  _buildSection(
                    'Age Restrictions',
                    'Our services have the following age-related policies:\n\n• Users must be 18 years or older to book services\n• Parental consent required for users 13-17 years\n• We do not collect data from children under 13\n• Children must be supervised during service visits',
                  ),
                  _buildSection(
                    'Data Protection for Minors',
                    'We take extra precautions to protect children\'s information:\n\n• No collection of personal data from children under 13\n• Parental consent required for teen accounts\n• Limited data collection for minors\n• Secure storage of all minor-related information\n• Right to delete minor\'s data upon request',
                  ),
                  _buildSection(
                    'Technician Background Checks',
                    'All our technicians undergo:\n\n• Comprehensive background verification\n• Criminal record checks\n• Reference verification\n• Child safety training\n• Regular re-certification',
                  ),
                  _buildSection(
                    'Service Delivery Standards',
                    'When providing doorstep services:\n\n• Technicians maintain professional boundaries\n• Services performed in common areas when possible\n• Parent/guardian presence recommended for minors\n• Professional conduct at all times\n• Immediate reporting of concerns',
                  ),
                  _buildSection(
                    'Reporting Concerns',
                    'If you have concerns about child safety:\n\n• Contact us immediately at safety@ziyonstar.com\n• All reports investigated promptly and confidentially\n• Appropriate authorities notified when necessary\n• Zero retaliation policy for reporters\n• Regular updates on investigation status',
                  ),
                  _buildSection(
                    'Content Monitoring',
                    'We monitor content on devices under repair:\n\n• Respect for privacy maintained\n• Illegal content reported to authorities\n• Child exploitation material - immediate action\n• Cooperation with law enforcement\n• Transparent reporting procedures',
                  ),
                  _buildSection(
                    'Parental Controls',
                    'We can assist with setting up:\n\n• Device parental controls\n• App restrictions\n• Screen time limits\n• Content filtering\n• Safe browsing settings',
                  ),
                  _buildSection(
                    'Training and Awareness',
                    'Our staff receives regular training on:\n\n• Child protection policies\n• Recognizing signs of abuse\n• Appropriate conduct with minors\n• Reporting procedures\n• Legal obligations',
                  ),
                  _buildSection(
                    'Third-Party Partnerships',
                    'We only work with partners who:\n\n• Share our commitment to child safety\n• Have their own child protection policies\n• Undergo background verification\n• Comply with child safety regulations',
                  ),
                  _buildSection(
                    'Emergency Contacts',
                    'For child safety concerns:\n\nImmediate Safety Issues:\nEmergency: 911\n\nZiyonstar Safety Team:\nEmail: safety@ziyonstar.com\nPhone: +1 (555) 123-4567 (24/7 Hotline)\n\nNational Child Safety Resources:\nChildhelp National Hotline: 1-800-422-4453',
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
