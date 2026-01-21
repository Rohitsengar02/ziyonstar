import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_colors.dart';

class OrderDetailScreen extends StatelessWidget {
  final Map<String, dynamic> order;
  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: Text(
          'Order Details',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(LucideIcons.moreVertical, size: 20),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildStatusHeader(),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  _buildSectionCard('Customer Information', [
                    _buildInfoRow(LucideIcons.user, 'Name', order['user']),
                    _buildInfoRow(
                      LucideIcons.phone,
                      'Phone',
                      '+91 98765 43210',
                    ),
                    _buildInfoRow(
                      LucideIcons.mapPin,
                      'Address',
                      'Sector 62, Noida, UP',
                    ),
                  ]),
                  const SizedBox(height: 20),
                  _buildSectionCard('Device & Issue', [
                    _buildInfoRow(
                      LucideIcons.smartphone,
                      'Model',
                      order['device'],
                    ),
                    _buildInfoRow(
                      LucideIcons.alertCircle,
                      'Problem',
                      order['issue'],
                    ),
                    _buildInfoRow(LucideIcons.calendar, 'Date', order['date']),
                  ]),
                  const SizedBox(height: 20),
                  _buildSectionCard('Assignment', [
                    _buildInfoRow(
                      LucideIcons.hardHat,
                      'Technician',
                      order['tech'],
                    ),
                    _buildInfoRow(
                      LucideIcons.clock,
                      'Arrival Window',
                      '12:00 PM - 02:00 PM',
                    ),
                  ]),
                  const SizedBox(height: 20),
                  _buildPriceCard(),
                  const SizedBox(height: 20),
                  _buildTimeline(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildStatusHeader() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      child: Column(
        children: [
          Text(
            order['id'],
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              order['status'],
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
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
              color: Colors.black,
            ),
          ),
          const Divider(height: 32),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
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
            value,
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          _buildBillRow('Service Charge', '₹3,500', Colors.grey),
          const SizedBox(height: 12),
          _buildBillRow('Spare Parts', '₹800', Colors.grey),
          const SizedBox(height: 12),
          _buildBillRow('Platform Fee', '₹200', Colors.grey),
          const Divider(color: Colors.white24, height: 32),
          _buildBillRow(
            'Total Amount',
            order['amount'],
            Colors.white,
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildBillRow(
    String label,
    String val,
    Color color, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(color: color, fontSize: 13)),
        Text(
          val,
          style: GoogleFonts.poppins(
            color: color,
            fontSize: isBold ? 18 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeline() {
    return _buildSectionCard('Order Timeline', [
      _buildTimelineStep(
        'Order Placed',
        'User confirmed booking',
        '10:15 AM',
        true,
      ),
      _buildTimelineStep(
        'Technician Assigned',
        'Rahul Kumar matched',
        '10:25 AM',
        true,
      ),
      _buildTimelineStep(
        'Out for Repair',
        'Tech is on the way',
        '11:00 AM',
        false,
      ),
      _buildTimelineStep(
        'Completed',
        'Pending technician action',
        '--:--',
        false,
      ),
    ]);
  }

  Widget _buildTimelineStep(
    String title,
    String sub,
    String time,
    bool isDone,
  ) {
    return Row(
      children: [
        Column(
          children: [
            Icon(
              isDone ? LucideIcons.checkCircle2 : LucideIcons.circle,
              size: 16,
              color: isDone ? Colors.green : Colors.grey.shade300,
            ),
            Container(width: 2, height: 20, color: Colors.grey.shade100),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDone ? Colors.black : Colors.grey,
                ),
              ),
              Text(
                sub,
                style: GoogleFonts.inter(fontSize: 11, color: Colors.grey),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
        Text(time, style: GoogleFonts.inter(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF1F1F1))),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Support Chat',
                style: GoogleFonts.inter(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                'Update Status',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
