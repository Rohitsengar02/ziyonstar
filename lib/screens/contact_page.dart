import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme.dart';
import '../responsive.dart';
import '../widgets/navbar.dart';
import '../widgets/app_drawer.dart';
import '../widgets/footer.dart';
import '../services/api_service.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _companyInfo;

  @override
  void initState() {
    super.initState();
    _fetchCompanyInfo();
  }

  Future<void> _fetchCompanyInfo() async {
    final info = await _apiService.getCompanyInfo();
    if (mounted && info != null) {
      setState(() => _companyInfo = info);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveLayout.isDesktop(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.go('/profile');
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        appBar: isDesktop
            ? null
            : AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(LucideIcons.arrowLeft, color: Colors.black),
                  onPressed: () => context.go('/profile'),
                ),
                title: Text(
                  'Contact Us',
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
              if (isDesktop)
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 80 : 20,
                    vertical: isDesktop ? 20 : 16,
                  ),
                  child: Navbar(scaffoldKey: _scaffoldKey),
                ),
              _buildHeroSection(isDesktop),
              _buildContactOptions(isDesktop),
              _buildAboutSection(isDesktop),
              if (isDesktop) const Footer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : 20,
        vertical: 80,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryButton.withOpacity(0.05),
      ),
      child: Column(
        children: [
          Text(
            'Connect with Us',
            style: GoogleFonts.poppins(
              fontSize: isDesktop ? 48 : 36,
              fontWeight: FontWeight.bold,
              color: AppColors.textHeading,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Our support team is available mon-fri to help you with any queries.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: AppColors.textBody,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactOptions(bool isDesktop) {
    final phone = _companyInfo?['phone'] ?? '+1 (555) 123-4567';
    final email = _companyInfo?['email'] ?? 'support@ziyonstar.com';

    return Container(
      padding: EdgeInsets.all(isDesktop ? 80 : 20),
      child: isDesktop
          ? Row(
              children: [
                Expanded(
                  child: _buildContactCard(
                    LucideIcons.phone,
                    'Call Support',
                    phone,
                    'Talk to our expert technicians',
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _buildContactCard(
                    LucideIcons.mail,
                    'Email Support',
                    email,
                    'Get a response within 24 hours',
                    Colors.orange,
                  ),
                ),
              ],
            )
          : Column(
              children: [
                _buildContactCard(
                  LucideIcons.phone,
                  'Call Support',
                  phone,
                  'Talk to our expert technicians',
                  Colors.blue,
                ),
                const SizedBox(height: 16),
                _buildContactCard(
                  LucideIcons.mail,
                  'Email Support',
                  email,
                  'Get a response within 24 hours',
                  Colors.orange,
                ),
              ],
            ),
    );
  }

  Widget _buildContactCard(
    IconData icon,
    String title,
    String value,
    String subtitle,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textHeading,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(bool isDesktop) {
    final hours =
        _companyInfo?['workingHours'] ?? 'Monday - Friday: 9:00 AM - 6:00 PM';
    final address =
        _companyInfo?['address'] ?? '123 Tech Street, Silicon Valley, CA 94025';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : 20,
        vertical: 60,
      ),
      color: const Color(0xFFF9FAFB),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Visit our Headquarters',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textHeading,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.mapPin, color: Colors.redAccent, size: 20),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  address,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: AppColors.textBody,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.clock, color: Colors.green, size: 20),
              const SizedBox(width: 12),
              Text(
                hours,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: AppColors.textBody,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
