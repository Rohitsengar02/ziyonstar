import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme.dart';
import '../responsive.dart';
import '../widgets/navbar.dart';
import '../widgets/app_drawer.dart';
import '../widgets/footer.dart';

class ReturnRefundPage extends StatefulWidget {
  const ReturnRefundPage({super.key});

  @override
  State<ReturnRefundPage> createState() => _ReturnRefundPageState();
}

class _ReturnRefundPageState extends State<ReturnRefundPage> {
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
                'Return & Refund',
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
                    LucideIcons.rotateCcw,
                    size: 64,
                    color: AppColors.primaryButton,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Return & Refund Policy',
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
                    'Our Commitment',
                    'At Ziyonstar, we stand behind the quality of our repair services. If you\'re not completely satisfied with our service, we\'re here to help with our return and refund policy.',
                  ),
                  _buildSection(
                    'Eligibility for Refunds',
                    'You are eligible for a refund if:\n\n• The repair was not performed as agreed\n• The device has the same issue within warranty period\n• Service was cancelled more than 2 hours before appointment\n• We were unable to complete the repair\n• Genuine parts were not used (contrary to agreement)',
                  ),
                  _buildSection(
                    'Refund Process',
                    'To request a refund:\n\n1. Contact our customer service within 7 days of service\n2. Provide your booking ID and details\n3. Explain the reason for refund request\n4. Our team will review within 2-3 business days\n5. Approved refunds processed within 5-7 business days',
                  ),
                  _buildSection(
                    'Refund Methods',
                    'Refunds will be issued through the original payment method:\n\n• Cash payments: Bank transfer or cash refund\n• Card payments: Credited to original card\n• UPI payments: Returned to source account\n• Online banking: Account credit',
                  ),
                  _buildSection(
                    'Non-Refundable Services',
                    'The following are NOT eligible for refunds:\n\n• Diagnostic charges after diagnosis completion\n• Services explicitly acknowledged as satisfactory\n• Cancellations within 2 hours of appointment\n• Customer-caused damage after service\n• Services older than warranty period',
                  ),
                  _buildSection(
                    'Warranty Claims',
                    'If the same issue occurs within our 1-year warranty period:\n\n• We will re-repair at no additional cost\n• If issue persists, full refund available\n• Warranty covers parts and labor\n• Original receipt/invoice required',
                  ),
                  _buildSection(
                    'Replacement Parts Return',
                    'Defective replacement parts can be returned within warranty period:\n\n• Must be unused or minimally used\n• In original condition\n• With proof of purchase\n• Replacement or refund provided',
                  ),
                  _buildSection(
                    'Partial Refunds',
                    'In certain situations, partial refunds may be granted:\n\n• Minor service issues\n• Delayed service completion\n• Quality concerns not meeting full refund criteria',
                  ),
                  _buildSection(
                    'Dispute Resolution',
                    'If you\'re not satisfied with our refund decision:\n\n• Request escalation to senior management\n• Provide additional documentation\n• We aim to resolve within 7 business days\n• Final decision communicated in writing',
                  ),
                  _buildSection(
                    'Contact for Refunds',
                    'To initiate a refund request:\n\nEmail: refunds@ziyonstar.com\nPhone: +1 (555) 123-4567\nCustomer Service Hours: Mon-Fri 9 AM - 6 PM\n\nPlease have your booking ID ready.',
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
