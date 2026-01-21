import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:ziyonstar/theme.dart';
import 'package:ziyonstar/responsive.dart';
import '../widgets/navbar.dart';
import '../widgets/app_drawer.dart';
import '../widgets/mobile_bottom_nav.dart';
import 'chat_page.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

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

  final List<String> _filters = ['All', 'Upcoming', 'Completed', 'Cancelled'];

  // Mock data needs to include all fields for details
  final List<Map<String, dynamic>> _allBookings = [
    {
      'id': 'BK-19283',
      'device': 'iPhone 13 Pro',
      'status': 'Upcoming',
      'date': 'Today, 4:00 PM',
      'technician': 'Rahul Sharma',
      'techImage': 'assets/images/tech_avatar_1.png',
      'issues': ['Screen', 'Battery'],
      'price': 4498,
      'address': 'B-403, Galaxy Heights, Mumbai',
      'payment': 'UPI',
    },
    {
      'id': 'BK-10293',
      'device': 'MacBook Air M2',
      'status': 'Completed',
      'date': '12 Jan, 11:00 AM',
      'technician': 'Vikram Singh',
      'techImage': 'assets/images/tech_avatar_2.png',
      'issues': ['Software'],
      'price': 1499,
      'address': 'Startups Hub, Bangalore',
      'payment': 'Credit Card',
      'reviewed': false, // Not reviewed yet
    },
    {
      'id': 'BK-99281',
      'device': 'Samsung S23 Ultra',
      'status': 'Completed',
      'date': '10 Dec, 02:00 PM',
      'technician': 'Amit Verma',
      'techImage': 'assets/images/tech_avatar_3.png',
      'issues': ['Camera', 'Mic'],
      'price': 1999,
      'address': 'Sector 18, Noida',
      'payment': 'Cash',
      'reviewed': true, // Already reviewed
    },
    {
      'id': 'BK-55102',
      'device': 'OnePlus 11',
      'status': 'Cancelled',
      'date': '05 Nov, 10:00 AM',
      'technician': 'Rahul Sharma',
      'techImage': 'assets/images/tech_avatar_1.png',
      'issues': ['Charging Port'],
      'price': 899,
      'address': 'B-403, Galaxy Heights, Mumbai',
      'payment': 'UPI',
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredBookings {
    if (_selectedFilter == 'All') return _allBookings;
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
                padding: EdgeInsets.all(isDesktop ? 24 : 16),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFEEEFF2))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Booking Details',
                      style: GoogleFonts.poppins(
                        fontSize: isDesktop ? 20 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() => _selectedBooking = null),
                      icon: const Icon(LucideIcons.x),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isDesktop ? 24 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatusChip(
                        _selectedBooking!['status'],
                        large: true,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _selectedBooking!['device'],
                        style: GoogleFonts.poppins(
                          fontSize: isDesktop ? 24 : 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Booking ID: ${_selectedBooking!['id']}',
                        style: GoogleFonts.inter(
                          color: Colors.grey,
                          fontSize: isDesktop ? 14 : 12,
                        ),
                      ),
                      const SizedBox(height: 32),

                      _buildDetailRow(
                        LucideIcons.calendar,
                        'Date & Time',
                        _selectedBooking!['date'],
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow(
                        LucideIcons.mapPin,
                        'Address',
                        _selectedBooking!['address'],
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow(
                        LucideIcons.creditCard,
                        'Payment',
                        _selectedBooking!['payment'],
                      ),

                      const Divider(height: 48),

                      Text(
                        'Technician',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: isDesktop ? 14 : 13,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: isDesktop ? 25 : 20,
                            backgroundImage: AssetImage(
                              _selectedBooking!['techImage'] ??
                                  'assets/images/tech_avatar_1.png',
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
                                    fontSize: isDesktop ? 16 : 14,
                                  ),
                                ),
                                Text(
                                  'Expert Technician',
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

                      const Divider(height: 48),

                      Text(
                        'Issues Fixed',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: isDesktop ? 14 : 13,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: (_selectedBooking!['issues'] as List).map((
                          issue,
                        ) {
                          return Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade200),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  LucideIcons.wrench,
                                  size: isDesktop ? 40 : 35,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  issue,
                                  style: GoogleFonts.inter(fontSize: 10),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 40),
                      if (_selectedBooking!['status'] == 'Upcoming')
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // Cancel Logic
                              setState(() {
                                _selectedBooking!['status'] = 'Cancelled';
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Booking Cancelled'),
                                ),
                              );
                            },
                            icon: const Icon(
                              LucideIcons.xCircle,
                              color: Colors.red,
                            ),
                            label: const Text('Cancel Booking'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
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

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: Colors.grey[600]),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
            ),
            Text(value, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }

  // Mobile and Desktop Layouts similar to previous, but updated grid settings

  Widget _buildMobileLayout() {
    return Column(
      children: [
        // Filter Chips Row (Same as before)
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
      ],
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
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // 3 Columns
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 2.2, // Compact height
              ),
              itemCount: _filteredBookings.length,
              itemBuilder: (context, index) {
                return _buildAnimatedCard(index, _filteredBookings[index]);
              },
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
            margin: isMobile
                ? const EdgeInsets.only(bottom: 20)
                : EdgeInsets.zero,
            transform: Matrix4.identity()
              ..scale(_hoveredBookingId == booking['id'] ? 1.02 : 1.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(isMobile ? 20 : 16),
              border: Border.all(
                color: _hoveredBookingId == booking['id']
                    ? AppColors.primaryButton.withOpacity(0.3)
                    : Colors.grey.shade100,
              ),
              boxShadow: [
                BoxShadow(
                  color: _hoveredBookingId == booking['id']
                      ? AppColors.primaryButton.withOpacity(0.1)
                      : Colors.black.withOpacity(isMobile ? 0.08 : 0.05),
                  blurRadius: _hoveredBookingId == booking['id']
                      ? 20
                      : (isMobile ? 15 : 10),
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 24 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: isMobile
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.spaceBetween,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 12 : 0,
                          vertical: isMobile ? 6 : 0,
                        ),
                        decoration: isMobile
                            ? BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(8),
                              )
                            : null,
                        child: Text(
                          booking['id'],
                          style: GoogleFonts.inter(
                            fontSize: isMobile ? 12 : 10,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      _buildStatusChip(booking['status'], large: isMobile),
                    ],
                  ),

                  SizedBox(height: isMobile ? 20 : 0),

                  // Content
                  Row(
                    children: [
                      Hero(
                        tag: 'tech_${booking['id']}',
                        child: CircleAvatar(
                          radius: isMobile ? 24 : 18,
                          backgroundImage: AssetImage(
                            booking['techImage'] ??
                                'assets/images/tech_avatar_1.png',
                          ),
                        ),
                      ),
                      SizedBox(width: isMobile ? 16 : 12),
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
                                fontSize: isMobile ? 16 : 14,
                                color: AppColors.textHeading,
                              ),
                            ),
                            SizedBox(height: isMobile ? 4 : 0),
                            Text(
                              booking['technician'],
                              style: GoogleFonts.inter(
                                fontSize: isMobile ? 13 : 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Chat/Phone Actions
                      if (!isMobile) ...[
                        Row(
                          children: [
                            _buildActionButton(
                              context,
                              LucideIcons.messageCircle,
                              AppColors.primaryButton,
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ChatPage(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                            _buildActionButton(
                              context,
                              LucideIcons.phone,
                              Colors.green,
                              () {},
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),

                  SizedBox(height: isMobile ? 20 : 0),

                  // Issues Icons Row
                  Row(
                    children: [
                      ...(booking['issues'] as List).take(3).map<Widget>((
                        issue,
                      ) {
                        return Container(
                          width: isMobile ? 60 : 50,
                          height: isMobile ? 60 : 50,
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade100),
                          ),
                          child: const Center(
                            child: Icon(LucideIcons.wrench, size: 24),
                          ),
                        );
                      }),
                    ],
                  ),

                  // Mobile Actions Row (Chat/Phone below issues on mobile)
                  if (isMobile) ...[
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ChatPage(),
                                ),
                              );
                            },
                            icon: const Icon(
                              LucideIcons.messageCircle,
                              size: 16,
                            ),
                            label: const Text('Chat'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primaryButton,
                              side: BorderSide(
                                color: AppColors.primaryButton.withOpacity(0.5),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(LucideIcons.phone, size: 16),
                            label: const Text('Call'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.green,
                              side: BorderSide(
                                color: Colors.green.withOpacity(0.5),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  SizedBox(height: isMobile ? 20 : 0),

                  // Footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isMobile)
                            Text(
                              'Total Amount',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          Text(
                            '₹${booking['price']}',
                            style: GoogleFonts.inter(
                              fontSize: isMobile ? 18 : 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryButton,
                            ),
                          ),
                        ],
                      ),
                      if (!isMobile) // Mobile has dedicated buttons above
                        Icon(
                          LucideIcons.arrowRight,
                          size: 16,
                          color: Colors.grey[400],
                        ),
                    ],
                  ),

                  // Review Section (for Completed bookings without review)
                  if (booking['status'] == 'Completed' &&
                      booking['reviewed'] != true)
                    Column(
                      children: [
                        const SizedBox(height: 12),
                        // Star Rating Display
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              LucideIcons.star,
                              size: 16,
                              color: Colors.amber.shade300,
                            );
                          }),
                        ),
                        const SizedBox(height: 8),
                        // Give Review Button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => _showReviewDialog(booking),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primaryButton,
                              side: BorderSide(
                                color: AppColors.primaryButton.withOpacity(0.3),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Give Review',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Upcoming':
        return LucideIcons.clock;
      case 'Completed':
        return LucideIcons.checkCircle;
      case 'Cancelled':
        return LucideIcons.xCircle;
      default:
        return LucideIcons.circle;
    }
  }

  Widget _buildStatusChip(String status, {bool large = false}) {
    final color = _getStatusColor(status);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 16 : 8,
        vertical: large ? 8 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getStatusIcon(status), size: large ? 16 : 10, color: color),
          SizedBox(width: large ? 8 : 4),
          Text(
            status,
            style: GoogleFonts.inter(
              fontSize: large ? 14 : 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showReviewDialog(Map<String, dynamic> booking) {
    int selectedRating = 0;
    final TextEditingController reviewController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Container(
                padding: const EdgeInsets.all(32),
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primaryButton,
                                AppColors.primaryButton.withOpacity(0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            LucideIcons.star,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Rate Your Service',
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                booking['id'],
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(LucideIcons.x),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Star Rating
                    Text(
                      'How was your experience?',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              selectedRating = index + 1;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Icon(
                              index < selectedRating
                                  ? Icons.star
                                  : Icons.star_border,
                              size: 40,
                              color: index < selectedRating
                                  ? Colors.amber
                                  : Colors.grey.shade300,
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 32),

                    // Review Text
                    TextField(
                      controller: reviewController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Share your experience (optional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: selectedRating > 0
                            ? () {
                                setState(() {
                                  booking['reviewed'] = true;
                                  booking['rating'] = selectedRating;
                                  booking['reviewText'] = reviewController.text;
                                });
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Thank you for your review!',
                                      style: GoogleFonts.inter(),
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryButton,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Submit Review',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 18, color: color),
      ),
    );
  }
}
