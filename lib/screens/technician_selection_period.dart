import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:ziyonstar/screens/booking_success_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';
import '../responsive.dart';
import '../services/api_service.dart';

class TechnicianSelectionScreen extends StatefulWidget {
  final String deviceName;
  final List<String> selectedIssues;
  final double totalPrice;
  final String repairMode;

  const TechnicianSelectionScreen({
    super.key,
    required this.deviceName,
    required this.selectedIssues,
    required this.totalPrice,
    required this.repairMode,
  });

  @override
  State<TechnicianSelectionScreen> createState() =>
      _TechnicianSelectionScreenState();
}

class _TechnicianSelectionScreenState extends State<TechnicianSelectionScreen> {
  int? _selectedTechIndex;
  DateTime _selectedDate = DateTime.now();
  String? _selectedTimeSlot;
  int _currentStep = 0; // 0: Select Tech, 1: Schedule

  // Interactive Selection State
  Map<String, dynamic>? _selectedAddress;
  String _currentPaymentMethod = 'Select Payment Method';

  // Dynamic Addresses from API
  List<dynamic> _savedAddresses = [];
  bool _isLoadingAddresses = true;

  final List<String> _paymentMethods = [
    'Cash on Delivery',
    'UPI / GPay',
    'Credit/Debit Card',
  ];

  // Mock Technician Data
  // Removed _technicians mock list

  // Removed _dates list

  // Expanded to 8 Time Slots
  // Time Slots
  final List<String> _timeSlots = [
    '09:00 AM - 10:00 AM',
    '10:00 AM - 11:00 AM',
    '11:00 AM - 12:00 PM',
    '12:00 PM - 01:00 PM',
    '01:00 PM - 02:00 PM',
    '02:00 PM - 03:00 PM',
    '03:00 PM - 04:00 PM',
    '04:00 PM - 05:00 PM',
  ];

  final ApiService _apiService = ApiService();
  List<dynamic> _apiTechnicians = [];
  bool _isLoadingTechs = true;

  @override
  void initState() {
    super.initState();
    _fetchTechnicians();
    _initAndFetchAddresses();
  }

  String _userId = 'guest_user';
  String _userName = 'App User';
  String _userEmail = '';

  Future<void> _initAndFetchAddresses() async {
    // Get or create a persistent user ID
    final prefs = await SharedPreferences.getInstance();
    // Prioritize authenticated user UID
    String? storedId = prefs.getString('user_uid');

    if (storedId == null) {
      // Fallback to guest user_id
      storedId = prefs.getString('user_id');
      if (storedId == null) {
        // Generate a simple unique ID for this device
        storedId = 'user_${DateTime.now().millisecondsSinceEpoch}';
        await prefs.setString('user_id', storedId);
      }
    }
    _userId = storedId!;
    _userName = prefs.getString('user_name') ?? 'App User';
    _userEmail = prefs.getString('user_email') ?? 'user_$_userId@ziyon.com';
    _fetchAddresses();
  }

  Future<void> _fetchAddresses() async {
    try {
      final addresses = await _apiService.getAddresses(_userId);
      if (mounted) {
        setState(() {
          _savedAddresses = addresses;
          _isLoadingAddresses = false;
          // Set default address if available
          if (_savedAddresses.isNotEmpty && _selectedAddress == null) {
            final defaultAddr = _savedAddresses.firstWhere(
              (a) => a['isDefault'] == true,
              orElse: () => _savedAddresses.first,
            );
            _selectedAddress = defaultAddr;
          }
        });
      }
    } catch (e) {
      debugPrint('Error fetching addresses: $e');
      if (mounted) setState(() => _isLoadingAddresses = false);
    }
  }

  Future<void> _fetchTechnicians() async {
    try {
      final techs = await _apiService.getTechnicians();
      if (mounted) {
        setState(() {
          // Filter only approved/active technicians
          _apiTechnicians = techs
              .where(
                (t) => t['status'] == 'approved' || t['status'] == 'active',
              )
              .toList();
          _isLoadingTechs = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching technicians: $e');
      if (mounted) setState(() => _isLoadingTechs = false);
    }
  }

  bool _isBookingLoading = false;

  void _showNotification() {
    // Simulate a push notification using a custom top Overlay
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: -100, end: 0),
            duration: const Duration(milliseconds: 500),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, value),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          LucideIcons.checkCircle,
                          color: Color(0xFF10B981),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Booking Confirmed',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppColors.textHeading,
                              ),
                            ),
                            Text(
                              'Your technician is on the way!',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Remove notification after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  Future<void> _confirmBooking() async {
    setState(() => _isBookingLoading = true);

    try {
      final technician = _apiTechnicians[_selectedTechIndex!];

      // 1. Ensure User Exists/Get Valid DB ID
      String dbUserId;
      try {
        final userData = {
          'name': _userName,
          'email': _userEmail,
          'firebaseUid': _userId,
          'phone': '',
        };
        // Update local address info if available
        if (_selectedAddress != null && _selectedAddress!['phone'] != null) {
          userData['phone'] = _selectedAddress!['phone'];
        }

        final userResult = await _apiService.registerUser(userData);
        if (userResult != null && userResult['user'] != null) {
          dbUserId = userResult['user']['_id'];
        } else {
          throw 'User registration returned invalid data';
        }
      } catch (e) {
        debugPrint('User Reg Error: $e');
        // If reg fails, we can't create booking as userId is required Ref
        throw 'Failed to verify user identity for booking.';
      }

      // 2. Prepare Data Schema Matching Backend
      final nameParts = widget.deviceName.split(' ');
      final brand = nameParts.isNotEmpty ? nameParts[0] : 'Unknown';
      final model = nameParts.length > 1
          ? nameParts.sublist(1).join(' ')
          : 'Unknown';

      final bookingData = {
        'userId': dbUserId, // Must be valid ObjectId
        'technicianId': technician['_id'],
        'deviceBrand': brand,
        'deviceModel': model,
        'issues': widget.selectedIssues
            .map(
              (i) => {
                'issueName': i,
                'price':
                    0, // Price per issue typically fetched from backend, using 0 as fallback
              },
            )
            .toList(),
        'totalPrice': widget.totalPrice, // Matches schema 'totalPrice'
        'scheduledDate': _selectedDate.toIso8601String(), // 'scheduledDate'
        'timeSlot': _selectedTimeSlot,
        'addressDetails':
            _selectedAddress?['fullAddress'] ?? 'No address provided',
        // Optional: pass address ObjectId if we have it
        // 'address': _selectedAddress['_id']
        'paymentStatus': 'Pending',
        'status': 'Pending_Assignment',
      };

      if (_selectedAddress != null && _selectedAddress!['_id'] != null) {
        bookingData['address'] = _selectedAddress!['_id'];
      }

      // Call API
      final newBooking = await _apiService.createBooking(bookingData);

      // Show In-App Notification
      _showNotification();

      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => BookingSuccessScreen(
            deviceName: widget.deviceName,
            technicianName: technician['name'] ?? 'Technician',
            technicianImage: technician['photoUrl'] ?? '',
            selectedIssues: widget.selectedIssues,
            timeSlot: _selectedTimeSlot ?? '',
            date: _selectedDate,
            amount: widget.totalPrice,
            otp: newBooking?['otp']?.toString() ?? '000000',
          ),
        ),
      );
    } catch (e) {
      debugPrint('Booking failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to book: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(20),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isBookingLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveLayout.isDesktop(context);
    String title = _currentStep == 0 ? 'Select Technician' : 'Schedule Repair';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: AppColors.textHeading,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textHeading),
        centerTitle: true,
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(LucideIcons.arrowLeft),
                onPressed: () => setState(() => _currentStep--),
              )
            : null,
      ),
      body: isDesktop
          ? Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1100),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 30,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _currentStep == 0
                            ? _buildTechnicianList()
                            : _buildSchedulingStep(),
                      ),
                    ),
                    const SizedBox(width: 40),
                    Expanded(
                      flex: 2,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildDynamicSummary(),
                            const SizedBox(height: 24),
                            if (_currentStep == 1 && _selectedTimeSlot != null)
                              _buildDesktopCTA(),
                            const SizedBox(height: 32),
                            _buildTrustFeatures(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildDynamicSummary(),
                  const SizedBox(height: 30),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _currentStep == 0
                        ? _buildTechnicianList()
                        : _buildSchedulingStep(),
                  ),
                  if (_currentStep == 1 && _selectedTimeSlot != null) ...[
                    const SizedBox(height: 100),
                  ],
                ],
              ),
            ),
      bottomSheet: isDesktop || _currentStep == 0 ? null : _buildBottomBar(),
    );
  }

  Widget _buildSchedulingStep() {
    return Column(
      key: const ValueKey('ScheduleStep'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Date',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textHeading,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(5),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: CalendarDatePicker(
            initialDate: _selectedDate,
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 30)),
            onDateChanged: (newDate) {
              setState(() {
                _selectedDate = newDate;
              });
            },
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Select Time Slot',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textHeading,
          ),
        ),
        const SizedBox(height: 16),
        _buildTimeSelector(),
      ],
    );
  }

  Widget _buildDynamicSummary() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF334155)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E293B).withAlpha(80),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.smartphone,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.deviceName,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      widget.selectedIssues.join(", "),
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_selectedTechIndex != null) ...[
            const SizedBox(height: 20),
            const Divider(color: Colors.white24),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.grey[200],
                    backgroundImage:
                        _apiTechnicians[_selectedTechIndex!]['photoUrl'] !=
                                null &&
                            _apiTechnicians[_selectedTechIndex!]['photoUrl']
                                .isNotEmpty
                        ? NetworkImage(
                            _apiTechnicians[_selectedTechIndex!]['photoUrl'],
                          )
                        : const AssetImage('assets/images/tech_avatar_1.png')
                              as ImageProvider,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Technician',
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        _apiTechnicians[_selectedTechIndex!]['name'] ??
                            'Technician',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => _currentStep = 0),
                  icon: const Icon(
                    LucideIcons.edit2,
                    color: Colors.white70,
                    size: 16,
                  ),
                  tooltip: 'Change Technician',
                ),
              ],
            ),
          ],
          if (_selectedTimeSlot != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withAlpha(40),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF10B981).withAlpha(80),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    LucideIcons.calendarClock,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_selectedDate.day}/${_selectedDate.month}, $_selectedTimeSlot',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildDarkDetailRow(
              LucideIcons.mapPin,
              'Address',
              _selectedAddress?['fullAddress'] ?? 'Select Delivery Address',
              onTap: _showAddressManager,
            ),
            Divider(height: 24, color: Colors.white.withAlpha(20)),
            _buildDarkDetailRow(
              LucideIcons.creditCard,
              'Payment',
              _currentPaymentMethod,
              onTap: _showPaymentSelector,
            ),
          ],
          const SizedBox(height: 20),
          const Divider(color: Colors.white24),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Estimate',
                style: GoogleFonts.inter(color: Colors.white70, fontSize: 14),
              ),
              Text(
                '₹${widget.totalPrice.toStringAsFixed(0)}',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDarkDetailRow(
    IconData icon,
    String label,
    String value, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white60,
                    ),
                  ),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(LucideIcons.chevronRight, color: Colors.white30, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTechnicianList() {
    if (_isLoadingTechs) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_apiTechnicians.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: Text('No technicians available in your area.'),
        ),
      );
    }

    return ListView.separated(
      key: const ValueKey('TechList'),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _apiTechnicians.length,
      separatorBuilder: (_, index) => const SizedBox(height: 20),
      itemBuilder: (context, index) {
        final tech = _apiTechnicians[index];
        final isSelected = _selectedTechIndex == index;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedTechIndex = index;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFD4AF37)
                    : Colors.transparent,
                width: isSelected ? 2 : 0,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withAlpha(40),
                        blurRadius: 25,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.grey.withAlpha(15),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => _showTechnicianProfile(tech),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(10),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 36,
                          backgroundColor: Colors.grey[200],
                          backgroundImage:
                              tech['photoUrl'] != null &&
                                  tech['photoUrl'].isNotEmpty
                              ? NetworkImage(tech['photoUrl'])
                              : const AssetImage(
                                      'assets/images/tech_avatar_1.png',
                                    )
                                    as ImageProvider,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                tech['name'] ?? 'Technician',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: AppColors.textHeading,
                                ),
                              ),
                              if (tech['isOnline'] == true)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF22C55E),
                                        Color(0xFF16A34A),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        LucideIcons.zap,
                                        size: 10,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'AVAILABLE',
                                        style: GoogleFonts.inter(
                                          fontSize: 10,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                LucideIcons.briefcase,
                                size: 14,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                tech['experience'] ?? 'No Exp Info',
                                style: GoogleFonts.inter(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildTechBadge(LucideIcons.star, '4.9'),
                              const SizedBox(width: 12),
                              _buildTechBadge(LucideIcons.briefcase, 'Active'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryButton.withAlpha(10),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              (tech['specialty'] ?? 'General Repair') as String,
                              style: GoogleFonts.inter(
                                color: AppColors.primaryButton,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(height: 1),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTechStat(
                      LucideIcons.briefcase,
                      '${tech['jobs'] ?? 0}+ Repairs',
                    ),
                    _buildTechStat(
                      LucideIcons.award,
                      '${tech['experience'] ?? '1 Year'} Exp.',
                    ),
                    _buildTechStat(
                      LucideIcons.mapPin,
                      tech['distance']?.toString() ?? 'Unknown location',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showTechnicianProfile(tech),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'View Profile',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textHeading,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedTechIndex = index;
                            _currentStep = 1;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryButton,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Select & Schedule',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              LucideIcons.arrowRight,
                              size: 16,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTechStat(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 6),
        Text(
          text,
          style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[700]),
        ),
      ],
    );
  }

  Widget _buildTechBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _timeSlots.map((slot) {
        final isSelected = _selectedTimeSlot == slot;
        return GestureDetector(
          onTap: () => setState(() => _selectedTimeSlot = slot),
          child: Container(
            width: (MediaQuery.of(context).size.width - 100) / 2,
            constraints: const BoxConstraints(minWidth: 140, maxWidth: 200),
            padding: const EdgeInsets.symmetric(vertical: 14),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppColors.primaryButton
                    : Colors.grey.shade200,
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 5),
              ],
            ),
            child: Text(
              slot,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: isSelected
                    ? AppColors.primaryButton
                    : AppColors.textBody,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDesktopCTA() {
    final bool isReady =
        _selectedTechIndex != null && _selectedTimeSlot != null;
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: isReady
            ? LinearGradient(
                colors: [AppColors.primaryButton, const Color(0xFF2563EB)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        color: isReady ? null : Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
        boxShadow: isReady
            ? [
                BoxShadow(
                  color: AppColors.primaryButton.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ]
            : [],
      ),
      child: ElevatedButton(
        onPressed: isReady && !_isBookingLoading ? _confirmBooking : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isBookingLoading)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            else ...[
              Text(
                'Confirm Booking',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isReady ? Colors.white : Colors.grey[500],
                ),
              ),
              if (isReady) ...[
                const SizedBox(width: 12),
                const Icon(LucideIcons.arrowRight, color: Colors.white),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final bool isReady =
        _selectedTechIndex != null && _selectedTimeSlot != null;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: isReady
                ? LinearGradient(
                    colors: [AppColors.primaryButton, const Color(0xFF2563EB)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : null,
            color: isReady ? null : Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
            boxShadow: isReady
                ? [
                    BoxShadow(
                      color: AppColors.primaryButton.withValues(alpha: 0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: ElevatedButton(
            onPressed: isReady && !_isBookingLoading ? _confirmBooking : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isBookingLoading)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                else ...[
                  Text(
                    'Confirm Booking',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isReady ? Colors.white : Colors.grey[400],
                    ),
                  ),
                  if (isReady) ...[
                    const SizedBox(width: 8),
                    const Icon(
                      LucideIcons.checkCircle,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Address Logic ---

  void _showAddressManager() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Address',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _isLoadingAddresses
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.separated(
                        controller: controller,
                        itemCount: _savedAddresses.length + 1,
                        separatorBuilder: (_, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          if (index == _savedAddresses.length) {
                            return OutlinedButton.icon(
                              onPressed: _showAddAddressForm,
                              icon: const Icon(LucideIcons.plus),
                              label: const Text('Add New Address'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                side: BorderSide(
                                  color: AppColors.primaryButton.withAlpha(50),
                                ),
                              ),
                            );
                          }
                          final address = _savedAddresses[index];
                          final isSelected =
                              address['_id'] == _selectedAddress?['_id'];
                          return InkWell(
                            onTap: () {
                              setState(() => _selectedAddress = address);
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryButton.withAlpha(10)
                                    : Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primaryButton
                                      : Colors.transparent,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isSelected
                                        ? LucideIcons.checkCircle
                                        : LucideIcons.mapPin,
                                    color: isSelected
                                        ? AppColors.primaryButton
                                        : Colors.grey,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (address['label'] != null)
                                          Text(
                                            address['label'],
                                            style: GoogleFonts.inter(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              color: AppColors.primaryButton,
                                            ),
                                          ),
                                        Text(
                                          address['fullAddress'] ?? '',
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        if (address['phone'] != null &&
                                            address['phone'].isNotEmpty)
                                          Text(
                                            address['phone'],
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (address['isDefault'] == true)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withAlpha(20),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Default',
                                        style: GoogleFonts.inter(
                                          fontSize: 10,
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddAddressForm() {
    final labelController = TextEditingController(text: 'Home');
    final addressController = TextEditingController();
    final landmarkController = TextEditingController();
    final cityController = TextEditingController();
    final pincodeController = TextEditingController();
    final phoneController = TextEditingController();
    bool isDefault = _savedAddresses.isEmpty;
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            'Add New Address',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: labelController.text,
                  decoration: const InputDecoration(
                    labelText: 'Address Type',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Home', 'Office', 'Other']
                      .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                      .toList(),
                  onChanged: (v) => labelController.text = v ?? 'Home',
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: 'Full Address *',
                    hintText: 'Street, Building, Floor',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: landmarkController,
                  decoration: const InputDecoration(
                    labelText: 'Landmark',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: cityController,
                        decoration: const InputDecoration(
                          labelText: 'City',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: pincodeController,
                        decoration: const InputDecoration(
                          labelText: 'Pincode',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  value: isDefault,
                  onChanged: (v) =>
                      setDialogState(() => isDefault = v ?? false),
                  title: const Text('Set as default address'),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
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
              onPressed: isSaving
                  ? null
                  : () async {
                      if (addressController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter the full address'),
                          ),
                        );
                        return;
                      }
                      setDialogState(() => isSaving = true);

                      final newAddress = await _apiService.addAddress(
                        userId: _userId,
                        label: labelController.text,
                        fullAddress: addressController.text,
                        landmark: landmarkController.text,
                        city: cityController.text,
                        pincode: pincodeController.text,
                        phone: phoneController.text,
                        isDefault: isDefault,
                      );

                      if (newAddress != null) {
                        setState(() {
                          _savedAddresses.add(newAddress);
                          _selectedAddress = newAddress;
                        });
                        Navigator.pop(context); // Close Dialog
                        Navigator.pop(context); // Close Sheet
                      } else {
                        setDialogState(() => isSaving = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Failed to save address'),
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryButton,
              ),
              child: isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Save Address'),
            ),
          ],
        ),
      ),
    );
  }

  // --- Payment Logic ---

  void _showPaymentSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Method',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ..._paymentMethods.map(
              (method) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getPaymentIcon(method),
                    size: 20,
                    color: AppColors.textHeading,
                  ),
                ),
                title: Text(
                  method,
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
                trailing: const Icon(LucideIcons.chevronRight, size: 16),
                onTap: () {
                  if (method.contains('Card')) {
                    Navigator.pop(context);
                    _showCardForm();
                  } else {
                    setState(() => _currentPaymentMethod = method);
                    Navigator.pop(context);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPaymentIcon(String method) {
    if (method.contains('Cash')) return LucideIcons.banknote;
    if (method.contains('Card')) return LucideIcons.creditCard;
    return LucideIcons.smartphone;
  }

  void _showCardForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add Card Details',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(LucideIcons.x),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildModernTextField(
                'Card Number',
                '0000 0000 0000 0000',
                LucideIcons.creditCard,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildModernTextField(
                      'Expiry Date',
                      'MM/YY',
                      LucideIcons.calendar,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildModernTextField(
                      'CVV',
                      '123',
                      LucideIcons.lock,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(
                      () =>
                          _currentPaymentMethod = 'Debit Card Ending with 8842',
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryButton,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Add & Select Card',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernTextField(String label, String hint, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 18, color: Colors.grey),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  void _showTechnicianProfile(Map<String, dynamic> tech) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: ListView(
            controller: controller,
            padding: EdgeInsets.zero,
            children: [
              Stack(
                children: [
                  Container(
                    height: 150,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1E293B), Color(0xFF334155)],
                      ),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 20,
                    right: 20,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(LucideIcons.x, color: Colors.white),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withAlpha(50),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 80,
                      left: 24,
                      right: 24,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment
                          .center, // Center align text with avatar
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.grey[200],
                            backgroundImage:
                                tech['photoUrl'] != null &&
                                    tech['photoUrl'].isNotEmpty
                                ? NetworkImage(tech['photoUrl'])
                                : const AssetImage(
                                        'assets/images/tech_avatar_1.png',
                                      )
                                      as ImageProvider,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min, // Wrap content
                            children: [
                              Text(
                                tech['name'],
                                style: GoogleFonts.poppins(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white, // White Text
                                ),
                              ),
                              Text(
                                tech['experience'] ?? 'Technician',
                                style: GoogleFonts.inter(
                                  color: Colors.white70, // Lighter Text
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildProfileStat(LucideIcons.star, '4.9', 'Rating'),
                    _buildProfileStat(
                      LucideIcons.briefcase,
                      tech['isOnline'] == true ? 'Online' : 'Offline',
                      'Status',
                    ),
                    _buildProfileStat(
                      LucideIcons.clock,
                      tech['experience'] ?? '5+ Yrs',
                      'Experience',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Brand Expertise Section
              if ((tech['brandExpertise'] as List?)?.isNotEmpty ?? false) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Brand Expertise',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 90,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: (tech['brandExpertise'] as List).length,
                          itemBuilder: (context, index) {
                            final brand =
                                (tech['brandExpertise'] as List)[index];
                            return Container(
                              width: 80,
                              margin: const EdgeInsets.only(right: 12),
                              child: Column(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: brand['imageUrl'] != null
                                          ? Image.network(
                                              brand['imageUrl'],
                                              fit: BoxFit.cover,
                                              errorBuilder: (c, e, s) =>
                                                  const Icon(
                                                    LucideIcons.smartphone,
                                                    color: Colors.grey,
                                                  ),
                                            )
                                          : const Icon(
                                              LucideIcons.smartphone,
                                              color: Colors.grey,
                                            ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    brand['title'] ?? brand['name'] ?? '',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              // Repair Expertise Section
              if ((tech['repairExpertise'] as List?)?.isNotEmpty ?? false) ...[
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Repair Expertise',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: (tech['repairExpertise'] as List).map<Widget>(
                          (repair) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryButton.withAlpha(25),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.primaryButton.withAlpha(75),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    LucideIcons.wrench,
                                    size: 14,
                                    color: AppColors.primaryButton,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    repair['name'] ?? '',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.primaryButton,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ).toList(),
                      ),
                    ],
                  ),
                ),
              ],
              // Contact Info
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contact',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(LucideIcons.mail, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          tech['email'] ?? 'Not provided',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                    if (tech['phone'] != null &&
                        tech['phone'].toString().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(LucideIcons.phone, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            tech['phone'],
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.textHeading, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(label, style: GoogleFonts.inter(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildTrustFeatures() {
    final features = [
      {
        'icon': LucideIcons.shieldCheck,
        'title': '6 Months Warranty',
        'desc': 'On all screen replacements',
      },
      {
        'icon': LucideIcons.cpu,
        'title': 'Genuine Parts',
        'desc': 'Original quality components',
      },
      {
        'icon': LucideIcons.lock,
        'title': '100% Data Safe',
        'desc': 'Your privacy is our priority',
      },
      {
        'icon': LucideIcons.clock,
        'title': 'Instant Support',
        'desc': '24/7 dedicated assistance',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFD4AF37).withAlpha(20),
            const Color(0xFFD4AF37).withAlpha(5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD4AF37).withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.star, color: Color(0xFFD4AF37), size: 24),
              const SizedBox(width: 12),
              Text(
                'Premium Promise',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textHeading,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...features.map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(5),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(
                      f['icon'] as IconData,
                      size: 20,
                      color: const Color(0xFFD4AF37),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          f['title'] as String,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          f['desc'] as String,
                          style: GoogleFonts.inter(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
