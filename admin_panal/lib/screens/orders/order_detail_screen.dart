import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_colors.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';

class OrderDetailScreen extends StatefulWidget {
  final dynamic order;
  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late dynamic _currentOrder;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
  }

  Future<void> _refreshOrder() async {
    try {
      final updated = await ApiService().getBooking(_currentOrder['_id']);
      setState(() => _currentOrder = updated);
    } catch (e) {
      debugPrint('Error refreshing order: $e');
    }
  }

  Future<void> _updateStatus() async {
    String? selectedStatus;
    final statuses = [
      'Pending_Assignment',
      'Pending_Acceptance',
      'Accepted',
      'On_Way',
      'Arrived',
      'In_Progress',
      'Completed',
      'Cancelled',
      'Rejected',
    ];

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Order Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: statuses
              .map(
                (s) => ListTile(
                  title: Text(s.replaceAll('_', ' ')),
                  onTap: () {
                    selectedStatus = s;
                    Navigator.pop(context);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );

    if (selectedStatus != null) {
      setState(() => _isLoading = true);
      try {
        await ApiService().updateBookingStatus(
          _currentOrder['_id'],
          selectedStatus!,
        );
        await _refreshOrder();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Status updated to ${selectedStatus!.replaceAll('_', ' ')}',
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String bookingId = _currentOrder['_id']
        .toString()
        .substring(_currentOrder['_id'].toString().length - 8)
        .toUpperCase();
    String userName = _currentOrder['userId']?['name'] ?? 'Unknown User';
    String userPhone = _currentOrder['userId']?['phone'] ?? 'N/A';
    String userEmail = _currentOrder['userId']?['email'] ?? 'N/A';

    // Address handling
    String addressStr = 'N/A';
    if (_currentOrder['address'] != null) {
      final addr = _currentOrder['address'];
      addressStr =
          '${addr['houseNumber'] ?? ''}, ${addr['street'] ?? ''}, ${addr['city'] ?? ''}, ${addr['pincode'] ?? ''}'
              .trim();
      if (addressStr.startsWith(','))
        addressStr = addressStr.substring(1).trim();
    } else if (_currentOrder['addressDetails'] != null) {
      addressStr = _currentOrder['addressDetails'];
    }

    String device =
        '${_currentOrder['deviceBrand'] ?? ''} ${_currentOrder['deviceModel'] ?? 'Device'}'
            .trim();

    List<dynamic> issues = _currentOrder['issues'] ?? [];
    String issueStr = issues.isNotEmpty
        ? issues
              .map((i) => (i is Map ? i['issueName'] : i.toString()))
              .join(', ')
        : 'General Repair';

    String status = _currentOrder['status'] ?? 'Pending';
    String dateStr = 'N/A';
    if (_currentOrder['scheduledDate'] != null) {
      try {
        final date = DateTime.parse(_currentOrder['scheduledDate']);
        dateStr = DateFormat('MMM dd, yyyy').format(date);
      } catch (e) {
        dateStr = _currentOrder['scheduledDate'].toString();
      }
    }

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
            onPressed: _refreshOrder,
            icon: const Icon(LucideIcons.refreshCw, size: 20),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                _buildStatusHeader(bookingId, status),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      _buildSectionCard('Customer Information', [
                        _buildInfoRow(LucideIcons.user, 'Name', userName),
                        _buildInfoRow(LucideIcons.phone, 'Phone', userPhone),
                        _buildInfoRow(LucideIcons.mail, 'Email', userEmail),
                        _buildInfoRow(
                          LucideIcons.mapPin,
                          'Address',
                          addressStr,
                        ),
                      ]),
                      const SizedBox(height: 20),
                      _buildSectionCard('Device & Issue', [
                        _buildInfoRow(LucideIcons.smartphone, 'Model', device),
                        _buildInfoRow(
                          LucideIcons.alertCircle,
                          'Problem',
                          issueStr,
                        ),
                        _buildInfoRow(LucideIcons.calendar, 'Date', dateStr),
                        _buildInfoRow(
                          LucideIcons.clock,
                          'Slot',
                          _currentOrder['timeSlot'] ?? 'N/A',
                        ),
                      ]),
                      const SizedBox(height: 20),
                      _buildSectionCard('Assignment', [
                        _buildInfoRow(
                          LucideIcons.hardHat,
                          'Technician',
                          _currentOrder['technicianId']?['name'] ??
                              'Unassigned',
                        ),
                        _buildInfoRow(
                          LucideIcons.phoneCall,
                          'Tech Phone',
                          _currentOrder['technicianId']?['phone'] ?? 'N/A',
                        ),
                      ]),
                      const SizedBox(height: 20),
                      _buildPriceCard(
                        _currentOrder['totalPrice']?.toString() ?? '0',
                      ),
                      const SizedBox(height: 20),
                      _buildTimeline(_currentOrder),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildStatusHeader(String id, String status) {
    Color statusColor = status == 'In_Progress'
        ? Colors.blue
        : status == 'On_Way'
        ? Colors.orange
        : status == 'Arrived'
        ? Colors.teal
        : (status.contains('Pending'))
        ? Colors.amber
        : status == 'Cancelled' || status == 'Rejected'
        ? Colors.red
        : Colors.green;

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      child: Column(
        children: [
          Text(
            '#ORD-$id',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status.replaceAll('_', ' '),
              style: GoogleFonts.inter(
                fontSize: 12,
                color: statusColor,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCard(String total) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          _buildBillRow('Booking Charge', 'Included', Colors.grey),
          const SizedBox(height: 12),
          _buildBillRow('Platform Fee', 'Included', Colors.grey),
          const Divider(color: Colors.white24, height: 32),
          _buildBillRow('Total Amount', '₹$total', Colors.white, isBold: true),
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

  Widget _buildTimeline(dynamic order) {
    String createdAt = order['createdAt'] != null
        ? DateFormat(
            'hh:mm a',
          ).format(DateTime.parse(order['createdAt']).toLocal())
        : '--:--';
    String status = order['status'] ?? '';

    return _buildSectionCard('Order Timeline', [
      _buildTimelineStep(
        'Order Placed',
        'User confirmed booking',
        createdAt,
        true,
      ),
      _buildTimelineStep(
        'Technician Assigned',
        order['technicianId'] != null
            ? 'Technician matched'
            : 'Waiting for assignment',
        '--',
        order['technicianId'] != null,
      ),
      _buildTimelineStep(
        'In Progress',
        status == 'In_Progress' ? 'Work started' : 'Pending start',
        '--',
        status == 'In_Progress' || status == 'Completed',
      ),
      _buildTimelineStep(
        'Completed',
        status == 'Completed' ? 'Repair finished' : 'Pending completion',
        order['completedAt'] != null
            ? DateFormat(
                'hh:mm a',
              ).format(DateTime.parse(order['completedAt']).toLocal())
            : '--:--',
        status == 'Completed',
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
              onPressed: () {
                // Future Implementation: Support Chat
              },
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
              onPressed: _updateStatus,
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
