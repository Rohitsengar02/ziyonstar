import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:ziyonstar/theme.dart';
import 'package:ziyonstar/responsive.dart';
import '../widgets/navbar.dart';
import '../widgets/app_drawer.dart';
import '../widgets/mobile_bottom_nav.dart';
// Removed ChatPage import
import 'package:firebase_auth/firebase_auth.dart';
import '../services/api_service.dart';
// Unused import removed
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'chat_screen.dart';

class MyBookingsScreen extends StatefulWidget {
  final String? initialBookingId;
  const MyBookingsScreen({super.key, this.initialBookingId});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _selectedFilter = 'All';
  String? _hoveredBookingId;
  Map<String, dynamic>? _selectedBooking; // For Detail Sidebar
  late AnimationController _controller;
  bool _isLoading = true;
  bool _isFirstLoad = true; // Track first load to prevent false positives

  final List<String> _filters = [
    'All',
    'Upcoming',
    'Completed',
    'Cancelled',
    'Rejected',
  ];

  List<Map<String, dynamic>> _allBookings = [];

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _controller.forward();
    _fetchBookings();

    // Simulate Notification/Real-time updates via Polling
    _timer = Timer.periodic(
      const Duration(seconds: 5),
      (timer) => _fetchBookings(),
    );
  }

  Future<void> _fetchBookings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? uid;

      // 1. Try Firebase Auth
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        uid = user.uid;
      } else {
        // 2. Try Guest ID (consistent with booking screen)
        uid = prefs.getString('user_uid') ?? prefs.getString('user_id');
      }

      if (uid != null) {
        final api = ApiService();
        // Get Mongo User ID from our UID (firebase or guest)
        final mongoUser = await api.getUser(uid);

        if (mongoUser != null) {
          final bookings = await api.getUserBookings(
            mongoUser['_id'].toString(),
          );

          final newBookings = bookings.map<Map<String, dynamic>>((b) {
            // Safe Date Parsing
            String dateStr = 'Date Unknown';
            try {
              final dt = DateTime.parse(b['scheduledDate']).toLocal();
              // Manual formatting: MMM d, y
              const months = [
                'Jan',
                'Feb',
                'Mar',
                'Apr',
                'May',
                'Jun',
                'Jul',
                'Aug',
                'Sep',
                'Oct',
                'Nov',
                'Dec',
              ];
              dateStr = '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
            } catch (e) {
              dateStr = b['scheduledDate'].toString().substring(0, 10);
            }

            // Address Fallback
            String addressStr = 'Address Details';
            if (b['address'] is Map) {
              addressStr = b['address']['fullAddress'];
            } else if (b['addressDetails'] != null) {
              addressStr = b['addressDetails'];
            }

            List<Map<String, dynamic>> issuesData = [];
            if (b['issues'] is List) {
              issuesData = (b['issues'] as List).map((i) {
                if (i is Map) {
                  return {
                    'issueName': i['issueName']?.toString() ?? '',
                    'issueImage': i['issueImage']?.toString() ?? '',
                  };
                }
                return {'issueName': i.toString(), 'issueImage': ''};
              }).toList();
            }

            // Technician Details
            Map<String, dynamic>? tech = b['technicianId'] is Map
                ? b['technicianId']
                : null;
            String techName = tech?['name'] ?? 'Pending Assignment';
            String techPhoto =
                tech?['photoUrl'] ?? 'assets/images/tech_avatar_1.png';
            String? techPhone = tech?['phone'];

            return {
              'id': b['_id']?.toString() ?? 'Unknown',
              'device':
                  '${b['deviceBrand'] ?? ''} ${b['deviceModel'] ?? 'Device'}'
                      .trim(),
              'status': _mapStatus(b['status']?.toString() ?? ''),
              'rawStatus': b['status']?.toString() ?? '',
              'date': dateStr, // Formatted Date
              'timeSlot':
                  (b['timeSlot'] != null && b['timeSlot'].toString().isNotEmpty)
                  ? b['timeSlot'].toString()
                  : 'Time Not Scheduled', // Explicit fallback
              'technician': techName,
              'techImage': techPhoto,
              'techPhone': techPhone,
              'issues': issuesData,
              'price': b['totalPrice']?.toString() ?? '0',
              'address': addressStr,
              'payment': b['paymentStatus']?.toString() ?? 'Pending',
              'otp': b['otp']?.toString() ?? '',
              'otpVerified': b['otpVerified'] == true,
              'pickupDetails': b['pickupDetails'],
            };
          }).toList();

          // Notification Logic (Only after first load)
          if (!_isFirstLoad) {
            for (var newB in newBookings) {
              final oldB = _allBookings.firstWhere(
                (old) => old['id'] == newB['id'],
                orElse: () => {},
              );
              if (oldB.isNotEmpty && oldB['rawStatus'] != newB['rawStatus']) {
                // Simple notification trigger for status changes
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Update: ${newB['device']} is now ${newB['status']}",
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            }
          }

          // Sort by date (newest first)
          newBookings.sort(
            (a, b) => (b['id'] as String).compareTo(a['id'] as String),
          );

          _isFirstLoad = false;
          if (mounted) {
            setState(() {
              _allBookings = newBookings;
              _isLoading = false;

              // Auto-select booking if initialBookingId is provided
              if (widget.initialBookingId != null && _selectedBooking == null) {
                final target = _allBookings.firstWhere(
                  (b) => b['id'] == widget.initialBookingId,
                  orElse: () => {},
                );
                if (target.isNotEmpty) {
                  _selectedBooking = target;
                }
              }
            });
          }
        } else {
          if (mounted) setState(() => _isLoading = false);
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("Error fetching bookings: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _mapStatus(String status) {
    if (status == 'Pending_Assignment' ||
        status == 'Pending_Acceptance' ||
        status == 'On_Way' ||
        status == 'Arrived')
      return 'Upcoming';
    if (status == 'In_Progress') return 'Upcoming';
    return status; // Completed, Cancelled, Rejected
  }

  Future<void> _handleReassign(String bookingId) async {
    try {
      await ApiService().reassignBooking(bookingId);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Reassignment Requested')));
      _fetchBookings();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  final _player = AudioPlayer();

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _player.dispose();
    super.dispose();
  }

  // _playSound removed as it was unused
  Future<void> _callTechnician(String? phone) async {
    if (phone == null || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Technician phone number not available')),
      );
      return;
    }
    final Uri url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch dialer')),
        );
      }
    }
  }

  Future<void> _showComplaintDialog(Map<String, dynamic> booking) async {
    final List<String> reasons = [
      'Technician didn\'t arrive',
      'High pricing',
      'Poor service quality',
      'Rude behaviour',
      'Parts not replaced correctly',
      'Other',
    ];
    String selectedReason = reasons[0];
    final TextEditingController descriptionController = TextEditingController();
    bool isSubmitting = false;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            'Raise a Complaint',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Reason',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedReason,
                  items: reasons
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (val) => setState(() => selectedReason = val!),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Description',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Tell us more...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      setState(() => isSubmitting = true);
                      try {
                        final prefs = await SharedPreferences.getInstance();
                        final String? uid = prefs.getString('user_uid');
                        if (uid == null) throw 'User not logged in';

                        final mongoUser = await ApiService().getUser(uid);
                        if (mongoUser == null) throw 'User record not found';

                        final success = await ApiService().createDispute(
                          bookingId: booking['id'],
                          userId: mongoUser['_id'],
                          reason: selectedReason,
                          description: descriptionController.text,
                        );

                        if (success != null) {
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Complaint submitted successfully',
                                ),
                              ),
                            );
                          }
                        } else {
                          throw 'Failed to submit complaint';
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('Error: $e')));
                      } finally {
                        if (mounted) setState(() => isSubmitting = false);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryButton,
              ),
              child: isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> get _filteredBookings {
    if (_selectedFilter == 'All') return _allBookings;
    if (_selectedFilter == 'Upcoming') {
      return _allBookings.where((b) => b['status'] == 'Upcoming').toList();
    }
    return _allBookings.where((b) => b['status'] == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveLayout.isDesktop(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF9FAFB),
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
                'My Bookings',
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(LucideIcons.refreshCw, color: Colors.black),
                  onPressed: () {
                    setState(() => _isLoading = true);
                    _fetchBookings();
                  },
                ),
              ],
            ),
      drawer: const AppDrawer(),
      bottomNavigationBar: isDesktop
          ? null
          : const MobileBottomNav(currentIndex: 1),
      body: Column(
        children: [
          // Navbar (Desktop Only)
          if (isDesktop)
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 80 : 20,
                vertical: isDesktop ? 20 : 16,
              ),
              child: Navbar(scaffoldKey: _scaffoldKey),
            ),
          // Main Content with Stack for Detail Sidebar
          Expanded(
            child: Stack(
              children: [
                ResponsiveLayout(
                  mobile: _buildMobileLayout(),
                  desktop: _buildDesktopLayout(),
                ),
                // Detail Sidebar Overlay
                if (_selectedBooking != null) _buildDetailSidebar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSidebar() {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Positioned(
      top: 0,
      bottom: 0,
      right: 0,
      left: isDesktop ? null : 0, // Full width on mobile
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: isDesktop ? 450 : screenWidth,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 50,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade100),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryButton.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        LucideIcons.fileText,
                        color: AppColors.primaryButton,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Booking Details',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textHeading,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => setState(() => _selectedBooking = null),
                      icon: const Icon(LucideIcons.x, size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[50],
                        hoverColor: Colors.grey[100],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status and Device Header
                      _buildStatusChip(
                        _selectedBooking!['status'],
                        large: true,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _selectedBooking!['device'],
                        style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textHeading,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Booking ID: ${_selectedBooking!['id']}',
                        style: GoogleFonts.inter(
                          color: Colors.grey[500],
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Information Grid/List
                      _buildSidebarInfoSection(
                        LucideIcons.calendar,
                        'Schedule',
                        '${_selectedBooking!['date']} at ${_selectedBooking!['timeSlot']}',
                        Colors.blue,
                      ),
                      const SizedBox(height: 24),
                      _buildSidebarInfoSection(
                        LucideIcons.mapPin,
                        'Service Address',
                        _selectedBooking!['address'],
                        Colors.red,
                      ),
                      const SizedBox(height: 24),
                      _buildSidebarInfoSection(
                        LucideIcons.creditCard,
                        'Payment Method',
                        _selectedBooking!['payment'],
                        Colors.green,
                      ),

                      const SizedBox(height: 40),
                      const Divider(),
                      const SizedBox(height: 40),

                      // Technician Section
                      Text(
                        'Assigned Technician',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textHeading,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade100),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primaryButton.withOpacity(
                                    0.1,
                                  ),
                                  width: 2,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 28,
                                backgroundImage:
                                    _selectedBooking!['techImage']
                                        .toString()
                                        .startsWith('http')
                                    ? NetworkImage(
                                        _selectedBooking!['techImage'],
                                      )
                                    : AssetImage(_selectedBooking!['techImage'])
                                          as ImageProvider,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedBooking!['technician'],
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppColors.textHeading,
                                    ),
                                  ),
                                  Text(
                                    'Ziyonstar Certified Expert',
                                    style: GoogleFonts.inter(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            _buildCircleAction(
                              LucideIcons.phone,
                              Colors.blue,
                              () => _callTechnician(
                                _selectedBooking!['techPhone'],
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildCircleAction(
                              LucideIcons.messageSquare,
                              Colors.green,
                              () {
                                final user = FirebaseAuth.instance.currentUser;
                                if (user != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatScreen(
                                        bookingId: _selectedBooking!['id'],
                                        currentUserId: user.uid,
                                        otherUserName:
                                            _selectedBooking!['technician'],
                                        senderRole: 'user',
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Issues Section
                      Text(
                        'Issues Reported',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textHeading,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: (_selectedBooking!['issues'] as List).map((
                          issue,
                        ) {
                          final issueName =
                              issue['issueName']?.toString() ?? '';
                          final rawImg = issue['issueImage']?.toString();
                          final img = _getIssueImagePath(issueName, rawImg);

                          return Container(
                            width: 120,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
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
                                Container(
                                  height: 60,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(10),
                                    image: img.isNotEmpty
                                        ? DecorationImage(
                                            image: img.startsWith('http')
                                                ? NetworkImage(img)
                                                : AssetImage(
                                                        img.startsWith('assets')
                                                            ? img
                                                            : 'assets/images/issues/$img',
                                                      )
                                                      as ImageProvider,
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: img.isEmpty
                                      ? const Icon(LucideIcons.wrench, size: 20)
                                      : null,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  issueName,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textHeading,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 60),

                      // Footer Actions (Cancel/Reassign)
                      if (_selectedBooking!['status'] == 'Upcoming')
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              setState(
                                () => _selectedBooking!['status'] = 'Cancelled',
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Booking Cancelled'),
                                ),
                              );
                            },
                            icon: const Icon(LucideIcons.xCircle, size: 18),
                            label: const Text('Cancel Appointment'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.red,
                              elevation: 0,
                              side: const BorderSide(
                                color: Colors.red,
                                width: 1.5,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),

                      if (_selectedBooking!['status'] == 'Rejected')
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                _handleReassign(_selectedBooking!['id']),
                            icon: const Icon(LucideIcons.refreshCw, size: 18),
                            label: const Text('Find New Technician'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryButton,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        // Filter Chips Row
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filters.map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _selectedFilter = filter;
                      _controller.reset();
                      _controller.forward();
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryButton
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primaryButton.withOpacity(
                                    0.4,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: Text(
                        filter,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: _filteredBookings.length,
            itemBuilder: (context, index) {
              return _buildAnimatedCard(
                index,
                _filteredBookings[index],
                isMobile: true,
              );
            },
          ),
        ),
        if (!_isLoading && _filteredBookings.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.calendarX,
                    size: 64,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No bookings found",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSidebarInfoSection(
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textHeading,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleAction(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sidebar Filter
        Container(
          width: 250,
          color: Colors.white,
          height: double.infinity,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filters',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textHeading,
                ),
              ),
              const SizedBox(height: 24),
              ..._filters.map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () => setState(() {
                      _selectedFilter = filter;
                      _controller.reset();
                      _controller.forward();
                    }),
                    borderRadius: BorderRadius.circular(10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFEFF6FF)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _getFilterIcon(filter),
                            size: 18,
                            color: isSelected
                                ? AppColors.primaryButton
                                : Colors.grey[400],
                          ),
                          const SizedBox(width: 12),
                          Text(
                            filter,
                            style: GoogleFonts.inter(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isSelected
                                  ? AppColors.primaryButton
                                  : Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          if (isSelected) const Spacer(),
                          if (isSelected)
                            const Icon(
                              LucideIcons.chevronRight,
                              size: 14,
                              color: AppColors.primaryButton,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        // Content Area
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Wrap(
              spacing: 20,
              runSpacing: 20,
              children: _filteredBookings.asMap().entries.map((entry) {
                final index = entry.key;
                final booking = entry.value;
                // Use a constrained container to mimic the 'card' look but allow flexibility
                return SizedBox(
                  width: 350, // Fixed width for consistency, height flexible
                  child: _buildAnimatedCard(
                    index,
                    booking,
                    isMobile:
                        true, // FORCE MOBILE LOGIC: Use the exact same layout logic as the app
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  IconData _getFilterIcon(String filter) {
    switch (filter) {
      case 'All':
        return LucideIcons.layers;
      case 'Upcoming':
        return LucideIcons.calendarClock;
      case 'Completed':
        return LucideIcons.checkCircle;
      case 'Cancelled':
        return LucideIcons.xCircle;
      default:
        return LucideIcons.circle;
    }
  }

  Widget _buildAnimatedCard(
    int index,
    Map<String, dynamic> booking, {
    bool isMobile = false,
  }) {
    final animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(
        (index * 0.05).clamp(0.0, 1.0),
        1.0,
        curve: Curves.easeOutQuad,
      ),
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: animation,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - animation.value)),
            child: child,
          ),
        );
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _hoveredBookingId = booking['id']),
        onExit: (_) => setState(() => _hoveredBookingId = null),
        child: GestureDetector(
          onTap: () => setState(() => _selectedBooking = booking),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: Matrix4.identity()
              ..scale(_hoveredBookingId == booking['id'] ? 1.02 : 1.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: _hoveredBookingId == booking['id']
                    ? AppColors.primaryButton.withOpacity(0.3)
                    : Colors.grey.shade100,
                width: _hoveredBookingId == booking['id'] ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: _hoveredBookingId == booking['id']
                      ? AppColors.primaryButton.withOpacity(0.12)
                      : Colors.black.withOpacity(0.04),
                  blurRadius: _hoveredBookingId == booking['id'] ? 30 : 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ID and Status Chip
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade100),
                          ),
                          child: Text(
                            booking['id'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _buildStatusChip(booking['status'], large: true),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Technician and Device Details
                  Row(
                    children: [
                      Hero(
                        tag: 'tech_${booking['id']}',
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primaryButton.withOpacity(0.1),
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 22,
                            backgroundImage:
                                booking['techImage'].toString().startsWith(
                                  'http',
                                )
                                ? NetworkImage(booking['techImage'])
                                : AssetImage(booking['techImage'])
                                      as ImageProvider,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking['device'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.textHeading,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              booking['technician'],
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Time and Date
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryButton.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          LucideIcons.calendar,
                          size: 14,
                          color: AppColors.primaryButton,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${booking['date']} • ${booking['timeSlot']}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryButton,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Action Buttons (Call / Complaint)
                  Row(
                    children: [
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () =>
                              _callTechnician(booking['techPhone']),
                          icon: const Icon(LucideIcons.phone, size: 14),
                          label: const Text('Call'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.blue,
                            backgroundColor: Colors.blue.withOpacity(0.05),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () => _showComplaintDialog(booking),
                          icon: const Icon(LucideIcons.alertCircle, size: 14),
                          label: const Text('Support'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.orange,
                            backgroundColor: Colors.orange.withOpacity(0.05),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  Divider(color: Colors.grey.shade100, height: 1),
                  const SizedBox(height: 20),

                  // Price and View Details
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Amount to pay',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            '₹${booking['price']}',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textHeading,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryButton,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryButton.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          LucideIcons.chevronRight,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Upcoming':
        return const Color(0xFF2563EB);
      case 'Completed':
        return const Color(0xFF059669);
      case 'Cancelled':
        return const Color(0xFFDC2626);
      default:
        return Colors.black;
    }
  }

  Widget _buildStatusChip(String status, {bool large = false}) {
    final color = _getStatusColor(status);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 14 : 10,
        vertical: large ? 6 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            status,
            style: GoogleFonts.inter(
              fontSize: large ? 12 : 10,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.3,
            ),
          ),
        ],
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
}
