import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:ziyonstar/screens/booking_success_screen.dart';
import 'package:ziyonstar/widgets/app_drawer.dart';
import 'package:ziyonstar/widgets/navbar.dart';
import '../theme.dart';
import '../responsive.dart';

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
  String _currentAddress = 'Select Delivery Address';
  String _currentPaymentMethod = 'Select Payment Method';

  // Mock Data
  final List<String> _savedAddresses = [
    '123 Main Street, Apt 4B, New York, NY 10001',
    '456 Park Avenue, Suite 10, New York, NY 10022',
  ];

  final List<String> _paymentMethods = [
    'Cash on Delivery',
    'UPI / GPay',
    'Credit/Debit Card',
  ];

  // Mock Technician Data
  final List<Map<String, dynamic>> _technicians = [
    {
      'name': 'David Miller',
      'image': 'assets/images/tech_avatar_1.png',
      'rating': 4.9,
      'reviews': 1240,
      'specialty': 'Apple Specialist',
      'experience': '6 Years',
      'jobs': 3400,
      'badges': ['Doorstep', 'Pickup'],
      'isOnline': true,
      'distance': '2.4 km',
    },
    {
      'name': 'Maria Garcia',
      'image': 'assets/images/tech_avatar_2.png',
      'rating': 4.8,
      'reviews': 850,
      'specialty': 'Android & Chip Level',
      'experience': '4 Years',
      'jobs': 1200,
      'badges': ['Walk-in', 'Doorstep'],
      'isOnline': false,
      'distance': '1.2 km',
    },
    {
      'name': 'Robert Fox',
      'image': 'assets/images/tech_avatar_3.png',
      'rating': 5.0,
      'reviews': 2100,
      'specialty': 'Master Technician',
      'experience': '10+ Years',
      'jobs': 5600,
      'badges': ['Complex Repairs'],
      'isOnline': true,
      'distance': '5.0 km',
    },
  ];

  // Removed _dates list

  // Expanded to 8 Time Slots
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
                      '${widget.selectedIssues.join(", ")}',
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
                    backgroundImage: AssetImage(
                      _technicians[_selectedTechIndex!]['image'],
                    ),
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
                        _technicians[_selectedTechIndex!]['name'],
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
              _currentAddress,
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
    return ListView.separated(
      key: const ValueKey('TechList'),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _technicians.length,
      separatorBuilder: (_, __) => const SizedBox(height: 20),
      itemBuilder: (context, index) {
        final tech = _technicians[index];
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
                          backgroundImage: AssetImage(tech['image']),
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
                                tech['name'],
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: AppColors.textHeading,
                                ),
                              ),
                              if (tech['isOnline'])
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
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                LucideIcons.star,
                                size: 16,
                                color: Color(0xFFF59E0B),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${tech['rating']}',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                ' (${tech['reviews']} Verified Reviews)',
                                style: GoogleFonts.inter(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
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
                              tech['specialty'],
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
                      '${tech['jobs']}+ Repairs',
                    ),
                    _buildTechStat(
                      LucideIcons.award,
                      '${tech['experience']} Exp.',
                    ),
                    _buildTechStat(LucideIcons.mapPin, tech['distance']),
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
                  color: AppColors.primaryButton.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ]
            : [],
      ),
      child: ElevatedButton(
        onPressed: isReady
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookingSuccessScreen(
                      deviceName: widget.deviceName,
                      technicianName: _technicians[_selectedTechIndex!]['name'],
                      technicianImage:
                          _technicians[_selectedTechIndex!]['image'],
                      selectedIssues: widget.selectedIssues,
                      timeSlot: _selectedTimeSlot!,
                      date: _selectedDate,
                      amount: widget.totalPrice,
                    ),
                  ),
                );
              }
            : null,
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
                      color: AppColors.primaryButton.withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: ElevatedButton(
            onPressed: isReady
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingSuccessScreen(
                          deviceName: widget.deviceName,
                          technicianName:
                              _technicians[_selectedTechIndex!]['name'],
                          technicianImage:
                              _technicians[_selectedTechIndex!]['image'],
                          selectedIssues: widget.selectedIssues,
                          timeSlot: _selectedTimeSlot!,
                          date: _selectedDate,
                          amount: widget.totalPrice,
                        ),
                      ),
                    );
                  }
                : null,
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
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmationSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Confirmation',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Review your details',
            style: GoogleFonts.inter(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          _buildDetailRow(
            LucideIcons.mapPin,
            'Address',
            _currentAddress,
            onTap: _showAddressManager,
          ),
          Divider(height: 30, color: Colors.grey[100]),
          _buildDetailRow(
            LucideIcons.creditCard,
            'Payment',
            _currentPaymentMethod,
            onTap: _showPaymentSelector,
          ),
          Divider(height: 30, color: Colors.grey[100]),
          _buildDetailRow(
            LucideIcons.shieldCheck,
            'Warranty',
            '6 Months Screen Warranty Applied',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: Colors.grey),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: value.startsWith('Select')
                          ? AppColors.primaryButton
                          : AppColors.textHeading,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(LucideIcons.chevronRight, size: 16, color: Colors.grey[300]),
          ],
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
                child: ListView.separated(
                  controller: controller,
                  itemCount: _savedAddresses.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    if (index == _savedAddresses.length) {
                      return OutlinedButton.icon(
                        onPressed: _showAddAddressForm,
                        icon: const Icon(LucideIcons.plus),
                        label: const Text('Add New Address'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(
                            color: AppColors.primaryButton.withAlpha(50),
                          ),
                        ),
                      );
                    }
                    final address = _savedAddresses[index];
                    final isSelected = address == _currentAddress;
                    return InkWell(
                      onTap: () {
                        setState(() => _currentAddress = address);
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
                              child: Text(
                                address,
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w500,
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
    final TextEditingController addressController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Add New Address',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: addressController,
          decoration: const InputDecoration(
            hintText: 'Enter full address (e.g. Street, City, Zip)',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (addressController.text.isNotEmpty) {
                setState(() {
                  _savedAddresses.add(addressController.text);
                  _currentAddress = addressController.text;
                });
                Navigator.pop(context); // Close Dialog
                Navigator.pop(context); // Close Sheet (optional, or keep open)
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryButton,
            ),
            child: const Text('Save Address'),
          ),
        ],
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
                            backgroundImage: AssetImage(tech['image']),
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
                                tech['specialty'],
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
                    _buildProfileStat(
                      LucideIcons.star,
                      '${tech['rating']}',
                      'Rating',
                    ),
                    _buildProfileStat(
                      LucideIcons.briefcase,
                      '${tech['jobs']}+',
                      'Repairs',
                    ),
                    _buildProfileStat(
                      LucideIcons.clock,
                      '${tech['experience']}',
                      'Experience',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Work',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      children: [
                        _buildPortfolioItem(
                          'assets/images/repair_before_screen.png',
                          'Screen Damage',
                        ),
                        _buildPortfolioItem(
                          'assets/images/repair_after_screen.png',
                          'Screen Fixed',
                        ),
                        _buildPortfolioItem(
                          'assets/images/repair_before_back.png',
                          'Back Damage',
                        ),
                        _buildPortfolioItem(
                          'assets/images/repair_after_back.png',
                          'Back Restore',
                        ),
                      ],
                    ),
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

  Widget _buildPortfolioItem(String imagePath, String label) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover),
      ),
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(12),
          ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withAlpha(150)],
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
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
