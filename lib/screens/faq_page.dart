import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme.dart';
import '../responsive.dart';
import '../widgets/navbar.dart';
import '../widgets/app_drawer.dart';
import '../widgets/footer.dart';

class FaqPage extends StatefulWidget {
  const FaqPage({super.key});

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
                  'FAQs',
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
              _buildFAQList(isDesktop),
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
        vertical: 60,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryButton.withOpacity(0.05),
      ),
      child: Column(
        children: [
          Icon(
            LucideIcons.helpCircle,
            size: 64,
            color: AppColors.primaryButton,
          ),
          const SizedBox(height: 24),
          Text(
            'Frequently Asked Questions',
            style: GoogleFonts.poppins(
              fontSize: isDesktop ? 48 : 32,
              fontWeight: FontWeight.bold,
              color: AppColors.textHeading,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Everything you need to know about Ziyonstar services.',
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

  Widget _buildFAQList(bool isDesktop) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : 20,
        vertical: 40,
      ),
      constraints: BoxConstraints(maxWidth: isDesktop ? 900 : double.infinity),
      child: Column(
        children: [
          _buildFAQItem(
            'How do I book a repair?',
            'Simply select your device type (Mobile, Laptop, etc.), choose your brand and model, select the issue, and pick a convenient time slot. Our technician will reach your doorstep.',
          ),
          _buildFAQItem(
            'Is there a warranty on repairs?',
            'Yes, we provide a 1-year warranty on all repairs using genuine parts. This covers any defects in workmanship or part failure.',
          ),
          _buildFAQItem(
            'What payment methods are accepted?',
            'We accept Cash, Credit/Debit cards, UPI, and Online banking. Payment is only required after the service is successfully completed.',
          ),
          _buildFAQItem(
            'Can I cancel my booking?',
            'Yes, you can cancel your booking through the "My Bookings" section at least 2 hours before the scheduled time without any charges.',
          ),
          _buildFAQItem(
            'Are the replacement parts original?',
            'Yes, we only use genuine and high-quality parts for all repairs to ensure your device performs at its best.',
          ),
          _buildFAQItem(
            'What if the issue persists after repair?',
            'Contact us immediately via our Help Center. Our technician will re-examine the device, and if the issue is service-related, we will fix it for free under warranty.',
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ExpansionTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          question,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: AppColors.textHeading,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              answer,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textBody,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
