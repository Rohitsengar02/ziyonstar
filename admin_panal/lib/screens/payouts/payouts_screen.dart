import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'payout_detail_screen.dart';
import '../../theme/app_colors.dart';

class PayoutsScreen extends StatefulWidget {
  const PayoutsScreen({super.key});

  @override
  State<PayoutsScreen> createState() => _PayoutsScreenState();
}

class _PayoutsScreenState extends State<PayoutsScreen> {
  final List<Map<String, dynamic>> _payouts = [
    {
      'id': '#PAY-5521',
      'tech': 'Rahul Kumar',
      'amount': '₹12,450',
      'status': 'Pending',
      'date': 'Oct 12, 2023',
      'bank': 'HDFC Bank (**** 8821)',
    },
    {
      'id': '#PAY-5518',
      'tech': 'Arjun Malhotra',
      'amount': '₹8,200',
      'status': 'Processed',
      'date': 'Oct 10, 2023',
      'bank': 'ICICI Bank (**** 4410)',
    },
    {
      'id': '#PAY-5515',
      'tech': 'Sneha Kapoor',
      'amount': '₹4,500',
      'status': 'Failed',
      'date': 'Oct 08, 2023',
      'bank': 'SBI Bank (**** 1122)',
    },
    {
      'id': '#PAY-5510',
      'tech': 'Vikram Singh',
      'amount': '₹15,000',
      'status': 'Processed',
      'date': 'Oct 05, 2023',
      'bank': 'Axis Bank (**** 0099)',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: Text(
          'Payout Management',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(LucideIcons.download, size: 20),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildPayoutStats(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _payouts.length,
              itemBuilder: (context, index) {
                return _buildPayoutCard(_payouts[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayoutStats() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMiniStat('To Process', '₹42.5k', Colors.orange),
          _buildMiniStat('Processed', '₹1.2M', Colors.green),
          _buildMiniStat('Requests', '12', Colors.blue),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String val, Color color) {
    return Column(
      children: [
        Text(
          val,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _buildPayoutCard(Map<String, dynamic> payout) {
    Color statusColor = payout['status'] == 'Processed'
        ? Colors.green
        : payout['status'] == 'Pending'
        ? Colors.orange
        : Colors.red;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PayoutDetailScreen(payout: payout),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  payout['id'],
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    payout['status'],
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.user, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payout['tech'],
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        payout['bank'],
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  payout['amount'],
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
