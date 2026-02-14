import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'map_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart';
import '../services/api_service.dart';
import '../responsive.dart';

class JobDetailsScreen extends StatefulWidget {
  final String orderId;

  const JobDetailsScreen({super.key, required this.orderId});

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _booking;
  bool _isLoading = true;
  String? _error;

  final List<Map<String, String>> _usedParts = [];

  @override
  void initState() {
    super.initState();
    _fetchBookingDetails();
  }

  Future<void> _fetchBookingDetails() async {
    try {
      setState(() => _isLoading = true);
      final booking = await _apiService.getBookingById(widget.orderId);
      setState(() {
        _booking = booking;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load booking details';
        _isLoading = false;
      });
    }
  }

  void _addPart(String name, String price) {
    setState(() {
      _usedParts.add({'name': name, 'price': price});
    });
  }

  void _showAddPartDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Add Part Usage',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Part Name',
                labelStyle: GoogleFonts.inter(fontSize: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Selling Price (₹)',
                labelStyle: GoogleFonts.inter(fontSize: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixText: '₹ ',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.inter(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  priceController.text.isNotEmpty) {
                _addPart(nameController.text, priceController.text);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Add Part'),
          ),
        ],
      ),
    );
  }

  double get _totalPartsCost {
    return _usedParts.fold(
      0,
      (sum, item) => sum + double.parse(item['price']!),
    );
  }

  void _copyPhoneNumber(String phoneNumber) {
    Clipboard.setData(ClipboardData(text: phoneNumber));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('📞 Phone copied: $phoneNumber'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'Pending_Acceptance':
        return 'PENDING ACCEPTANCE';
      case 'Accepted':
        return 'ACCEPTED - WAITING TO START';
      case 'In_Progress':
        return 'IN PROGRESS';
      case 'Completed':
        return 'COMPLETED';
      case 'Rejected':
        return 'REJECTED';
      case 'Cancelled':
        return 'CANCELLED';
      case 'On_Way':
        return 'ON THE WAY';
      case 'Arrived':
        return 'ARRIVED AT LOCATION';
      default:
        return 'ACTIVE JOB';
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Completed':
        return Colors.green;
      case 'Rejected':
      case 'Cancelled':
        return Colors.red;
      case 'In_Progress':
        return Colors.blue;
      case 'On_Way':
        return Colors.orange;
      case 'Arrived':
        return Colors.teal;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _booking == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.alertCircle,
                size: 48,
                color: Colors.red.shade300,
              ),
              const SizedBox(height: 16),
              Text(_error ?? 'Booking not found'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchBookingDetails,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Extract booking data
    final status = _booking!['status'] ?? 'Unknown';
    final deviceBrand = _booking!['deviceBrand'] ?? 'Unknown';
    final deviceModel = _booking!['deviceModel'] ?? '';
    final issuesList = (_booking!['issues'] as List?) ?? [];
    final totalPrice = _booking!['totalPrice'] ?? 0;

    // Address Logic
    final addressObj = _booking!['address'];
    String addressDetails =
        _booking!['addressDetails'] ?? 'Address not provided';
    if (addressObj is Map) {
      final full = addressObj['fullAddress'] ?? '';
      final landmark = addressObj['landmark'] ?? '';
      final city = addressObj['city'] ?? '';
      final pincode = addressObj['pincode'] ?? '';

      List<String> parts = [];
      if (full.isNotEmpty) parts.add(full);
      if (landmark.isNotEmpty) parts.add('Landmark: $landmark');
      if (city.isNotEmpty || pincode.isNotEmpty) {
        parts.add('${city}${pincode.isNotEmpty ? " - $pincode" : ""}');
      }
      addressDetails = parts.join('\n');
    }

    final scheduledDate = _booking!['scheduledDate'] ?? '';
    final timeSlot = _booking!['timeSlot'] ?? '';
    final orderId = _booking!['_id']?.toString().substring(0, 8) ?? 'N/A';

    // User info
    final user = _booking!['userId'];
    String customerName = 'Customer';
    String customerPhone = 'N/A';
    if (user is Map) {
      customerName = user['name'] ?? 'Customer';
      customerPhone = user['phone'] ?? user['email'] ?? 'N/A';
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'ORD-#$orderId',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _fetchBookingDetails,
            icon: const Icon(LucideIcons.refreshCw),
          ),
        ],
      ),
      body: Responsive(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                color: _getStatusColor(status),
                child: Center(
                  child: Text(
                    _getStatusText(status),
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Device Info
                    _buildSectionHeader('Device Details'),
                    const SizedBox(height: 16),
                    _buildInfoCard(
                      LucideIcons.smartphone,
                      '$deviceBrand $deviceModel',
                      'Price: ₹$totalPrice',
                    ),
                    if (issuesList.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: issuesList.length,
                          itemBuilder: (context, i) {
                            final rawImg = issuesList[i]['issueImage']
                                ?.toString();
                            final name = issuesList[i]['issueName'] ?? 'Issue';
                            final img = _getIssueImagePath(name, rawImg);

                            return Container(
                              width: 120,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade100),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (img.isNotEmpty)
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        image: DecorationImage(
                                          image: img.startsWith('http')
                                              ? NetworkImage(img)
                                              : AssetImage(
                                                      img.startsWith('assets')
                                                          ? img
                                                          : 'assets/images/issues/$img',
                                                    )
                                                    as ImageProvider,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    )
                                  else
                                    Icon(
                                      LucideIcons.wrench,
                                      size: 30,
                                      color: Colors.grey[400],
                                    ),
                                  const SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    child: Text(
                                      name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Schedule Info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade100),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.calendar,
                            color: Colors.blue.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Scheduled: ${scheduledDate.split('T').first} • $timeSlot',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // 2. Customer Info
                    _buildSectionHeader('Customer Information'),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade100),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundImage:
                                    user is Map &&
                                        user['photoUrl'] != null &&
                                        user['photoUrl'].toString().isNotEmpty
                                    ? NetworkImage(user['photoUrl'])
                                    : const AssetImage(
                                            'assets/images/tech_avatar_1.png',
                                          )
                                          as ImageProvider,
                                backgroundColor: Colors.grey[100],
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      customerName,
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    Text(
                                      'Verified Customer',
                                      style: GoogleFonts.inter(
                                        color: Colors.green,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  final user =
                                      FirebaseAuth.instance.currentUser;
                                  if (user != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChatScreen(
                                          bookingId: widget.orderId,
                                          currentUserId: user.uid,
                                          otherUserName: customerName,
                                          senderRole: 'technician',
                                        ),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('User not authenticated'),
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(
                                  LucideIcons.messageSquare,
                                  color: Colors.blue,
                                ),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.blue.shade50,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _buildContactRow(
                            context,
                            LucideIcons.phone,
                            'Contact Number',
                            customerPhone,
                            onTap: () => _copyPhoneNumber(customerPhone),
                          ),
                          const Divider(height: 32),
                          _buildContactRow(
                            context,
                            LucideIcons.mapPin,
                            'Address',
                            addressDetails,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MapScreen(
                                    orderId: widget.orderId,
                                    destination: addressDetails,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // 3. Timeline
                    _buildSectionHeader('Job Timeline'),
                    const SizedBox(height: 20),
                    _buildTimelineItem(
                      'Order Placed',
                      scheduledDate.isNotEmpty
                          ? scheduledDate.split('T').first
                          : 'N/A',
                      true,
                    ),
                    _buildTimelineItem(
                      'Assigned to You',
                      status != 'Pending_Acceptance' ? 'Accepted' : 'Pending',
                      status != 'Pending_Acceptance',
                    ),
                    _buildTimelineItem(
                      'In Progress',
                      status == 'In_Progress' ||
                              status == 'Completed' ||
                              status == 'On_Way' ||
                              status == 'Arrived'
                          ? 'Started'
                          : 'Upcoming',
                      status == 'In_Progress' ||
                          status == 'Completed' ||
                          status == 'On_Way' ||
                          status == 'Arrived',
                    ),
                    _buildTimelineItem(
                      'Completed',
                      status == 'Completed' ? 'Done' : 'Upcoming',
                      status == 'Completed',
                    ),

                    const SizedBox(height: 32),

                    // 3.5. User Review Section
                    if (_booking!['reviewed'] == true) ...[
                      _buildSectionHeader('Customer Review'),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.amber.shade50, Colors.white],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.amber.shade100),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Row(
                                  children: List.generate(5, (index) {
                                    return Icon(
                                      index < (_booking!['rating'] ?? 0)
                                          ? Icons.star_rounded
                                          : Icons.star_outline_rounded,
                                      color: Colors.amber,
                                      size: 20,
                                    );
                                  }),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '${_booking!['rating']}.0',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber.shade900,
                                  ),
                                ),
                              ],
                            ),
                            if (_booking!['reviewText']
                                    ?.toString()
                                    .isNotEmpty ==
                                true) ...[
                              const SizedBox(height: 12),
                              Text(
                                _booking!['reviewText'],
                                style: GoogleFonts.inter(
                                  height: 1.5,
                                  color: Colors.grey[800],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],

                    const SizedBox(height: 32),

                    // 4. Parts Logged
                    _buildSectionHeader(
                      'Parts & Inventory',
                      trailing: GestureDetector(
                        onTap: _showAddPartDialog,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                LucideIcons.plus,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Add Part',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_usedParts.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'No parts added yet',
                            style: GoogleFonts.inter(color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      ..._usedParts
                          .map(
                            (part) => _buildPartItem(
                              part['name']!,
                              '₹${part['price']}',
                            ),
                          )
                          .toList(),

                    if (_usedParts.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Parts Selling Price',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            '₹${_totalPartsCost.toStringAsFixed(0)}',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildActionPanel(status),
    );
  }

  Widget _buildSectionHeader(String title, {Widget? trailing}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildInfoCard(
    IconData icon,
    String title,
    String sub, {
    String? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  sub,
                  style: GoogleFonts.inter(
                    color: Colors.grey[400],
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (trailing != null)
            Text(
              trailing,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContactRow(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    color: Colors.grey,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (icon == LucideIcons.phone)
            const Icon(LucideIcons.phoneCall, size: 18, color: Colors.green),
          if (icon == LucideIcons.mapPin)
            const Icon(LucideIcons.navigation, size: 18, color: Colors.blue),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    String title,
    String time,
    bool isDone, {
    bool isInteractive = false,
  }) {
    return Row(
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: isDone ? Colors.green : Colors.grey[300],
                shape: BoxShape.circle,
                border: isInteractive
                    ? Border.all(color: Colors.blue, width: 2)
                    : null,
              ),
            ),
            Container(width: 2, height: 40, color: Colors.grey[200]),
          ],
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
                color: isDone ? Colors.black : Colors.grey,
              ),
            ),
            Text(
              time,
              style: GoogleFonts.inter(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPartItem(String name, String cost) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              Text(
                cost,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: Colors.grey.shade100),
      ],
    );
  }

  Widget _buildActionPanel(String status) {
    String buttonText = 'Update Job Status';
    Color buttonColor = Colors.black;

    if (status == 'Pending_Acceptance') {
      buttonText = 'Accept Job';
      buttonColor = Colors.green;
    } else if (status == 'Accepted') {
      buttonText = 'On My Way 🚚';
      buttonColor = Colors.blue;
    } else if (status == 'In_Progress' || status == 'Picked_Up') {
      buttonText = 'Mark as Completed';
      buttonColor = Colors.green;
    } else if (status == 'Completed') {
      buttonText = 'Job Completed ✓';
      buttonColor = Colors.grey;
    } else if (status == 'On_Way') {
      buttonText = 'Arrived at Location';
      buttonColor = Colors.orange;
    } else if (status == 'Arrived') {
      buttonText = 'Start Repair Job';
      buttonColor = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: status != 'Completed'
                  ? () => _updateStatus(status)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                padding: const EdgeInsets.symmetric(vertical: 18),
                disabledBackgroundColor: Colors.grey.shade300,
              ),
              child: Text(buttonText),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              LucideIcons.helpCircle,
              color: Colors.black,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(String currentStatus) async {
    String newStatus;
    if (currentStatus == 'Pending_Acceptance') {
      newStatus = 'Accepted';
    } else if (currentStatus == 'Accepted') {
      newStatus = 'On_Way';
    } else if (currentStatus == 'On_Way') {
      newStatus = 'Arrived';
    } else if (currentStatus == 'Arrived') {
      _showOtpVerificationDialog();
      return;
    } else if (currentStatus == 'In_Progress' || currentStatus == 'Picked_Up') {
      newStatus = 'Completed';
    } else {
      return;
    }

    try {
      final result = await _apiService.updateBookingStatus(
        widget.orderId,
        newStatus,
      );
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status updated to $newStatus'),
            backgroundColor: Colors.green,
          ),
        );
        _fetchBookingDetails(); // Refresh the page
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showOtpVerificationDialog() {
    final otpController = TextEditingController();
    bool isVerifying = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Verify Job Code',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Please ask the customer for the 6-digit verification code to start the job.',
                style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                ),
                decoration: InputDecoration(
                  hintText: '000000',
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.black, width: 2),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isVerifying ? null : () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: isVerifying
                  ? null
                  : () async {
                      if (otpController.text.length != 6) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter 6-digit OTP'),
                          ),
                        );
                        return;
                      }

                      setDialogState(() => isVerifying = true);

                      try {
                        final result = await _apiService.verifyOtp(
                          widget.orderId,
                          otpController.text,
                        );

                        if (result['success'] == true) {
                          if (context.mounted) {
                            Navigator.pop(context); // Close OTP Dialog
                            _showPickupChoiceDialog(); // Show Pickup/Skip choice
                          }
                        }
                      } catch (e) {
                        setDialogState(() => isVerifying = false);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.toString()),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isVerifying
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Verify & Start'),
            ),
          ],
        ),
      ),
    );
  }

  String _getIssueImagePath(String issueName, String? existingImg) {
    if (existingImg != null && existingImg.isNotEmpty) return existingImg;

    final name = issueName.toLowerCase();
    if (name.contains('camera')) return 'issue_camera.png';
    if (name.contains('battery')) return 'issue_battery.png';
    if (name.contains('screen') || name.contains('display')) {
      return 'issue_screen.png';
    }
    if (name.contains('charging') ||
        name.contains('jack') ||
        name.contains('port')) {
      return 'issue_charging.png';
    }
    if (name.contains('mic')) return 'issue_mic.png';
    if (name.contains('speaker') || name.contains('receiver')) {
      return 'issue_speaker.png';
    }
    if (name.contains('face id')) return 'issue_faceid.png';
    if (name.contains('water') || name.contains('liquid')) {
      return 'issue_water.png';
    }
    if (name.contains('software')) return 'issue_software.png';
    if (name.contains('motherboard') || name.contains('ic')) {
      return 'issue_motherboard.png';
    }
    if (name.contains('sensor')) return 'issue_sensors.png';
    if (name.contains('glass')) return 'issue_backglass.png';

    return '';
  }

  void _showPickupChoiceDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Next Step',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Do you want to pick up the device for repair or continue with on-site repair?',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _fetchBookingDetails(); // Just refresh and stay in In_Progress
            },
            child: Text(
              'Skip (On-Site Repair)',
              style: GoogleFonts.inter(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showPickupFormDialog();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Pickup Device'),
          ),
        ],
      ),
    );
  }

  void _showPickupFormDialog() {
    List<XFile> selectedImages = [];
    final deliveryController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Device Pickup Details',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Add 4 images of the mobile device (Front, Back, Sides) before picking up.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ...List.generate(selectedImages.length, (index) {
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              selectedImages[index].path,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                // For non-web, use Image.file if it were a file
                                return Container(
                                  color: Colors.grey[300],
                                  width: 60,
                                  height: 60,
                                );
                              },
                            ),
                          ),
                          Positioned(
                            top: -10,
                            right: -10,
                            child: IconButton(
                              icon: const Icon(
                                Icons.cancel,
                                color: Colors.red,
                                size: 20,
                              ),
                              onPressed: () {
                                setDialogState(() {
                                  selectedImages.removeAt(index);
                                });
                              },
                            ),
                          ),
                        ],
                      );
                    }),
                    if (selectedImages.length < 4)
                      GestureDetector(
                        onTap: () async {
                          final ImagePicker picker = ImagePicker();
                          final XFile? image = await picker.pickImage(
                            source: ImageSource.camera,
                          );
                          if (image != null) {
                            setDialogState(() {
                              selectedImages.add(image);
                            });
                          }
                        },
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: const Icon(
                            LucideIcons.camera,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: deliveryController,
                  decoration: InputDecoration(
                    labelText: 'Estimated Delivery Time',
                    hintText: 'e.g., Tomorrow, 4 PM',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      if (selectedImages.length < 4) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please add 4 images of device'),
                          ),
                        );
                        return;
                      }
                      if (deliveryController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter delivery time'),
                          ),
                        );
                        return;
                      }

                      setDialogState(() => isSubmitting = true);

                      try {
                        // Upload Images
                        List<String> imageUrls = [];
                        for (var xfile in selectedImages) {
                          final url = await _apiService.uploadImage(xfile);
                          if (url != null) imageUrls.add(url);
                        }

                        // Confirm Pickup
                        final result = await _apiService.confirmPickup(
                          bookingId: widget.orderId,
                          images: imageUrls,
                          deliveryTime: deliveryController.text,
                        );

                        if (result['success'] == true) {
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Device Picked Up Successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            _fetchBookingDetails();
                          }
                        }
                      } catch (e) {
                        setDialogState(() => isSubmitting = false);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.toString()),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Confirm Pickup'),
            ),
          ],
        ),
      ),
    );
  }
}
