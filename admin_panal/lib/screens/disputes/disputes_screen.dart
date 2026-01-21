import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dispute_detail_screen.dart';
import '../../theme/app_colors.dart';

class DisputesScreen extends StatefulWidget {
  const DisputesScreen({super.key});

  @override
  State<DisputesScreen> createState() => _DisputesScreenState();
}

class _DisputesScreenState extends State<DisputesScreen> {
  final List<Map<String, dynamic>> _disputes = [
    {
      'id': '#DISP-102',
      'order_id': '#ORD-8750',
      'user': 'Karan Mehta',
      'tech': 'Rahul Kumar',
      'reason': 'Screen flickering after repair',
      'status': 'Open',
      'priority': 'High',
      'date': '2 hours ago',
    },
    {
      'id': '#DISP-98',
      'order_id': '#ORD-8690',
      'user': 'Ananya Singh',
      'tech': 'Arjun Malhotra',
      'reason': 'Excessive delay in return',
      'status': 'Under Review',
      'priority': 'Medium',
      'date': 'Yesterday',
    },
    {
      'id': '#DISP-95',
      'order_id': '#ORD-8600',
      'user': 'Mohit Jha',
      'tech': 'Suresh Raina',
      'reason': 'Rude behavior by technician',
      'status': 'Resolved',
      'priority': 'Low',
      'date': '3 days ago',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: Text(
          'Dispute Resolutions',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _disputes.length,
        itemBuilder: (context, index) {
          return _buildDisputeCard(_disputes[index]);
        },
      ),
    );
  }

  Widget _buildDisputeCard(Map<String, dynamic> dispute) {
    Color priorityColor = dispute['priority'] == 'High'
        ? Colors.red
        : dispute['priority'] == 'Medium'
        ? Colors.orange
        : Colors.blue;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dispute['id'],
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: priorityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${dispute['priority']} Priority',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: priorityColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            dispute['reason'],
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Order ID: ${dispute['order_id']}',
            style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
          ),
          const Divider(height: 24),
          Row(
            children: [
              _buildActorInfo('User', dispute['user'], LucideIcons.user),
              const Spacer(),
              _buildActorInfo('Tech', dispute['tech'], LucideIcons.hardHat),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dispute['status'],
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DisputeDetailScreen(dispute: dispute),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Investigate',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActorInfo(String role, String name, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              role,
              style: GoogleFonts.inter(fontSize: 10, color: Colors.grey),
            ),
            Text(
              name,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
