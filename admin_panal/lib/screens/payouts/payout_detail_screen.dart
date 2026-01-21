import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_colors.dart';

class PayoutDetailScreen extends StatelessWidget {
  final Map<String, dynamic> payout;
  const PayoutDetailScreen({super.key, required this.payout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: Text(
          'Payout Details',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildAmountHeader(),
            const SizedBox(height: 24),
            _buildDetailCard('Recipient Information', [
              _buildInfoRow(
                LucideIcons.user,
                'Technician Name',
                payout['tech'],
              ),
              _buildInfoRow(LucideIcons.mail, 'Email', 'rahul.kumar@email.com'),
              _buildInfoRow(LucideIcons.phone, 'Mobile', '+91 91234 56789'),
            ]),
            const SizedBox(height: 20),
            _buildDetailCard('Bank Details', [
              _buildInfoRow(LucideIcons.landmark, 'Bank Name', 'HDFC Bank Ltd'),
              _buildInfoRow(
                LucideIcons.hash,
                'Account Number',
                '**** **** 8821',
              ),
              _buildInfoRow(LucideIcons.code, 'IFSC Code', 'HDFC0001234'),
            ]),
            const SizedBox(height: 20),
            _buildDetailCard('Transaction Memo', [
              _buildInfoRow(LucideIcons.fileText, 'Payout ID', payout['id']),
              _buildInfoRow(
                LucideIcons.calendar,
                'Requested Date',
                payout['date'],
              ),
              _buildInfoRow(
                LucideIcons.shieldCheck,
                'Verification Status',
                'Verified',
              ),
            ]),
            const SizedBox(height: 32),
            if (payout['status'] == 'Pending') _buildActionStrip(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          Text(
            'Transfer Amount',
            style: GoogleFonts.inter(color: Colors.white60, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            payout['amount'],
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              payout['status'],
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(height: 32),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 13, color: Colors.grey),
          ),
          const Spacer(),
          Text(
            val,
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildActionStrip(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Text(
              'Approve Transfer',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(LucideIcons.x, color: Colors.red, size: 24),
        ),
      ],
    );
  }
}
