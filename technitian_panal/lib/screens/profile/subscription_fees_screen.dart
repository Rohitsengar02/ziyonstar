import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme.dart';

class SubscriptionFeesScreen extends StatelessWidget {
  final Map<String, dynamic> technicianData;
  const SubscriptionFeesScreen({super.key, required this.technicianData});

  @override
  Widget build(BuildContext context) {
    // These would ideally come from the technician model/backend
    final double commissionRate = 15.0; // Example 15%
    final String subscriptionPlan = 'standard'; // 'free', 'standard', 'premium'

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Subscription & Fees',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCurrentPlanCard(subscriptionPlan),
            const SizedBox(height: 32),
            _buildSectionTitle('Platform Fees'),
            const SizedBox(height: 16),
            _buildFeeItem(
              'Commission Rate',
              '$commissionRate%',
              'Charged on every successful repair',
              LucideIcons.percent,
            ),
            const SizedBox(height: 16),
            _buildFeeItem(
              'Lead Generation Fee',
              '₹0',
              'Fee for receiving new repair leads',
              LucideIcons.users,
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('Payment Cycle'),
            const SizedBox(height: 16),
            _buildPaymentCycleCard(),
            const SizedBox(height: 40),
            _buildUpgradeBanner(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildCurrentPlanCard(String plan) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current Plan',
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryButton,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  plan.toUpperCase(),
                  style: GoogleFonts.inter(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'ZiyonStar Partner',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enjoy full access to repair leads and priority support.',
            style: GoogleFonts.inter(
              color: Colors.white.withOpacity(0.7),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeeItem(String title, String value, String sub, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: Colors.black),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                ),
                Text(
                  sub,
                  style: GoogleFonts.inter(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppColors.primaryButton,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCycleCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildCycleRow('Payout frequency', 'Weekly (Every Monday)'),
          const Divider(height: 24),
          _buildCycleRow('Minimum payout', '₹500'),
          const Divider(height: 24),
          _buildCycleRow('Processing fee', '₹0'),
        ],
      ),
    );
  }

  Widget _buildCycleRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 13),
        ),
        Text(
          value,
          style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildUpgradeBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryButton.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryButton.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.zap, color: AppColors.primaryButton, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Want lower commission?',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Explore premium plans for high-volume partners.',
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text('View Plans'),
          ),
        ],
      ),
    );
  }
}
