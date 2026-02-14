import 'package:flutter/material.dart';
import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import 'my_jobs_screen.dart';
import 'wallet_screen.dart';
import 'profile_screen.dart';
import 'job_details_screen.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';

class DashboardScreen extends StatefulWidget {
  final Map<String, dynamic>?
  technicianData; // Make it optional for fallback flexibility
  const DashboardScreen({super.key, this.technicianData});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  // Global polling state
  Timer? _globalTimer;
  final AudioPlayer _globalPlayer = AudioPlayer();
  final ApiService _globalApiService = ApiService();
  int _lastPendingCount = -1; // -1 means first load

  @override
  void initState() {
    super.initState();
    // Start global polling for new job notifications
    _startGlobalPolling();
    _initSocket();
  }

  void _initSocket() {
    if (widget.technicianData != null) {
      SocketService().connect();
      SocketService().register(widget.technicianData!['_id'], 'technician');
    }
  }

  @override
  void dispose() {
    _globalTimer?.cancel();
    _globalPlayer.dispose();
    SocketService().dispose();
    super.dispose();
  }

  void _startGlobalPolling() {
    // Poll every 5 seconds for new bookings
    _globalTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _checkForNewJobs(),
    );
  }

  Future<void> _checkForNewJobs() async {
    if (widget.technicianData == null) return;

    try {
      final bookings = await _globalApiService.getTechnicianBookings(
        widget.technicianData!['_id'],
      );
      final pendingCount = bookings
          .where((b) => b['status'] == 'Pending_Acceptance')
          .length;

      // Only play sound if NOT first load AND there are MORE pending bookings
      if (_lastPendingCount >= 0 && pendingCount > _lastPendingCount) {
        _playNotificationSound();
        _showNewBookingPopup(
          bookings.firstWhere((b) => b['status'] == 'Pending_Acceptance'),
        );
      }

      _lastPendingCount = pendingCount;
    } catch (e) {
      debugPrint('Global polling error: $e');
    }
  }

  Future<void> _playNotificationSound() async {
    try {
      await _globalPlayer.setAsset('assets/notification.mp3');
      await _globalPlayer.setVolume(1.0);
      await _globalPlayer.setLoopMode(LoopMode.one); // Infinite repeat
      await _globalPlayer.play();
    } catch (e) {
      debugPrint('Error playing notification sound: $e');
    }
  }

  void _stopNotificationSound() {
    _globalPlayer.stop();
  }

  void _showNewBookingPopup(dynamic lastBooking) {
    showDialog(
      context: context,
      barrierDismissible: false, // Force technician to take action
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(LucideIcons.zap, color: Colors.orange),
            const SizedBox(width: 10),
            Text(
              'New Repair Request',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A new repair job is available!',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        LucideIcons.smartphone,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${lastBooking['deviceBrand']} ${lastBooking['deviceModel']}',
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        LucideIcons.indianRupee,
                        size: 16,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '₹${lastBooking['totalPrice']}',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              _stopNotificationSound();
              Navigator.pop(context);
              setState(() => _selectedIndex = 1); // Go to My Jobs to decide
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('View Request & Stop Alarm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.technicianData == null) {
      return const Scaffold(
        body: Center(child: Text("Error: No Technician Data")),
      );
    }

    final String techId = widget.technicianData!['_id'];

    final List<Widget> _pages = [
      _HomeContent(
        technicianData: widget.technicianData!,
        onTabChange: (index) => setState(() => _selectedIndex = index),
      ),
      MyJobsScreen(technicianId: techId),
      WalletScreen(technicianId: techId),
      const ProfileScreen(),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = MediaQuery.of(context).size.width >= 1200;
        final bool isTablet =
            MediaQuery.of(context).size.width >= 900 &&
            MediaQuery.of(context).size.width < 1200;

        if (isDesktop || isTablet) {
          return Scaffold(
            backgroundColor: const Color(0xFFF6F8FA),
            body: Row(
              children: [
                _buildSidebar(),
                Expanded(
                  child: Column(
                    children: [
                      _buildDesktopDashboardHeader(),
                      Expanded(child: _pages[_selectedIndex]),
                    ],
                  ),
                ),
                if (isDesktop) _buildRightSidebar(),
              ],
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF6F8FA),
          body: _pages[_selectedIndex],
          bottomNavigationBar: _buildBottomNav(),
        );
      },
    );
  }

  Widget _buildDesktopDashboardHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _selectedIndex == 0
                ? 'Dashboard Overview'
                : _selectedIndex == 1
                ? 'My Jobs'
                : _selectedIndex == 2
                ? 'Wallet & Earnings'
                : 'My Profile',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(LucideIcons.bell),
                onPressed: () {},
                color: Colors.grey[600],
              ),
              const SizedBox(width: 16),
              const VerticalDivider(width: 1, indent: 10, endIndent: 10),
              const SizedBox(width: 16),
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundImage:
                        widget.technicianData?['photoUrl'] != null &&
                            widget.technicianData!['photoUrl'].isNotEmpty
                        ? NetworkImage(widget.technicianData!['photoUrl'])
                        : const NetworkImage('https://i.pravatar.cc/150?img=11')
                              as ImageProvider,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.technicianData?['name'] ?? 'Technician',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Premium Partner',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 32),
          // Brand Logo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    LucideIcons.zap,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'ZIYONSTAR',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildSidebarItem(0, LucideIcons.home, 'Dashboard'),
                _buildSidebarItem(1, LucideIcons.briefcase, 'My Jobs'),
                _buildSidebarItem(2, LucideIcons.wallet, 'Wallet'),
                _buildSidebarItem(3, LucideIcons.user, 'Profile'),
              ],
            ),
          ),
          // Sidebar Footer
          _buildSidebarFooter(),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(int index, IconData icon, String label) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRightSidebar() {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(left: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Notifications',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '3 New',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildNotificationItem(
                  icon: LucideIcons.zap,
                  color: Colors.orange,
                  title: 'New Repair Job',
                  desc: 'iPhone 13 Pro Screen Replacement available now.',
                  time: '2m ago',
                  isUnread: true,
                ),
                _buildNotificationItem(
                  icon: LucideIcons.checkCircle,
                  color: Colors.green,
                  title: 'Payment Received',
                  desc: '₹1,200 has been credited to your wallet.',
                  time: '1h ago',
                  isUnread: true,
                ),
                _buildNotificationItem(
                  icon: LucideIcons.star,
                  color: Colors.amber,
                  title: '5 Star Review',
                  desc: 'Rahul Gupta left a wonderful review for your service.',
                  time: '5h ago',
                  isUnread: true,
                ),
                _buildNotificationItem(
                  icon: LucideIcons.shieldCheck,
                  color: Colors.blue,
                  title: 'KYC Verified',
                  desc:
                      'Your profile is now fully verified. Enjoy premium perks.',
                  time: 'Yesterday',
                  isUnread: false,
                ),
              ],
            ),
          ),
          _buildRightSidebarPromo(),
        ],
      ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required Color color,
    required String title,
    required String desc,
    required String time,
    required bool isUnread,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnread ? color.withOpacity(0.03) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnread ? color.withOpacity(0.1) : Colors.transparent,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      time,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightSidebarPromo() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Icon(LucideIcons.crown, color: Colors.amber, size: 32),
          const SizedBox(height: 12),
          Text(
            'Pro Support Plan',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Get 24/7 priority help',
            style: GoogleFonts.inter(color: Colors.grey[400], fontSize: 11),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Upgrade Now',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.helpCircle, size: 18),
                const SizedBox(width: 12),
                Text(
                  'Support Center',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(LucideIcons.logOut, size: 18, color: Colors.red),
              const SizedBox(width: 12),
              Text(
                'Logout',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(0, LucideIcons.home, 'Home'),
              _buildNavItem(1, LucideIcons.briefcase, 'My Jobs'),
              _buildNavItem(2, LucideIcons.wallet, 'Wallet'),
              _buildNavItem(3, LucideIcons.user, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryButton.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primaryButton : Colors.grey,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppColors.primaryButton : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeContent extends StatefulWidget {
  final Map<String, dynamic> technicianData;
  final Function(int) onTabChange;
  const _HomeContent({required this.technicianData, required this.onTabChange});
  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  bool _isOnline = true;
  List<dynamic> _pendingBookings = [];
  final ApiService _apiService = ApiService();
  bool _isUpdatingStatus = false;

  Map<String, dynamic>? _walletStats;
  List<dynamic> _allBookings = [];
  Map<String, dynamic>? _activeJob;

  Timer? _timer;
  final _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _isOnline = widget.technicianData['isOnline'] ?? true;
    _fetchBookings();
    _timer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _fetchBookings(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _player.dispose();
    super.dispose();
  }

  // Removed local _playSound to use Global Dashboard logic

  Future<void> _fetchBookings() async {
    try {
      final techId = widget.technicianData['_id'];
      final bookings = await _apiService.getTechnicianBookings(techId);
      final wallet = await _apiService.getTechnicianWallet(techId);

      final newPending = bookings
          .where((b) => b['status'] == 'Pending_Acceptance')
          .toList();

      // Find active job (On_Way, Arrived, In_Progress)
      final active = bookings.firstWhere(
        (b) =>
            b['status'] == 'On_Way' ||
            b['status'] == 'Arrived' ||
            b['status'] == 'In_Progress',
        orElse: () => null,
      );

      // Only trigger notification logically from DashboardScreen's global polling
      // to avoid double sounds or popups.

      if (mounted) {
        setState(() {
          _pendingBookings = newPending;
          _allBookings = bookings;
          _walletStats = wallet;
          _activeJob = active;
        });
      }
    } catch (e) {
      debugPrint("Error fetching bookings: $e");
    }
  }

  Future<void> _handleResponse(String bookingId, String action) async {
    try {
      await _apiService.respondToBooking(bookingId, action);
      // Use a subtle feedback or no sound here since Global alarm is separate
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Booking ${action == 'accept' ? 'Accepted ✅' : 'Rejected ❌'}',
          ),
          backgroundColor: action == 'accept' ? Colors.green : Colors.orange,
        ),
      );
      _fetchBookings(); // Refresh list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _toggleOnlineStatus(bool value) async {
    if (_isUpdatingStatus) return;

    setState(() {
      _isUpdatingStatus = true;
      _isOnline = value;
    });

    try {
      await _apiService.updateTechnicianOnlineStatus(
        widget.technicianData['firebaseUid'],
        value,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value ? 'You are now Online 🟢' : 'You are now Offline ⚪',
          ),
          backgroundColor: value ? Colors.green : Colors.grey[800],
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // Revert if failed
      setState(() {
        _isOnline = !value;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isUpdatingStatus = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 900;

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 0 : 24,
          vertical: 24,
        ),
        child: Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 1000 : double.infinity,
            ),
            padding: EdgeInsets.symmetric(horizontal: isDesktop ? 40 : 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header Section
                if (!isDesktop) ...[_buildHeader(), const SizedBox(height: 32)],

                // 4. Earnings Grid
                _buildEarningsRow(),
                const SizedBox(height: 32),

                // 2. Announcements
                _buildAlertBanner(),
                const SizedBox(height: 32),

                // 7. Active Job Section
                if (_activeJob != null) ...[
                  _buildSectionHeader('Live Repair', 'Active Session'),
                  const SizedBox(height: 16),
                  _buildTimeline(),
                  const SizedBox(height: 16),
                  _buildActiveJobCard(),
                  const SizedBox(height: 32),
                ],

                // 11. Status & Compliance
                _buildSectionHeader(
                  'Account Status',
                  'Verification & Compliance',
                ),
                const SizedBox(height: 16),
                _buildComplianceCard(),
                const SizedBox(height: 32),

                // 3. New Requests
                _buildSectionHeader(
                  'New Requests',
                  'Immediate Action Required',
                ),
                const SizedBox(height: 16),
                _buildNewJobRequest(),
                const SizedBox(height: 32),

                // 5. Financial Overview
                _buildSectionHeader('Financial Overview', 'Wallet & Payouts'),
                const SizedBox(height: 16),
                _buildWalletCard(),
                const SizedBox(height: 32),

                // 9. Ratings & Reviews
                _buildSectionHeader('Recent Feedback', 'What customers say'),
                const SizedBox(height: 16),
                _buildReviewCard(),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Colors.blue, Colors.purple, Colors.orange],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 32,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey[200],
                  backgroundImage:
                      widget.technicianData['photoUrl'] != null &&
                          widget.technicianData['photoUrl'].isNotEmpty
                      ? NetworkImage(widget.technicianData['photoUrl']!)
                      : const NetworkImage('https://i.pravatar.cc/150?img=11')
                            as ImageProvider,
                ),
              ),
            ),
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: _isOnline ? Colors.green : Colors.grey,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      widget.technicianData['name'] ?? 'Technician',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textHeading,
                        letterSpacing: -0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    LucideIcons.badgeCheck,
                    size: 18,
                    color: Colors.blue,
                  ),
                ],
              ),
              Text(
                widget.technicianData['experience'] ??
                    'Professional Technician',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.technicianData['averageRating'] ?? 0.0}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.technicianData['totalReviews'] ?? 0} Reviews',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey[500],
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        _buildOnlineSwitch(),
      ],
    );
  }

  Widget _buildOnlineSwitch() {
    return GestureDetector(
      onTap: () => _toggleOnlineStatus(!_isOnline),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: _isOnline ? Colors.black : Colors.grey[100],
          borderRadius: BorderRadius.circular(24),
          boxShadow: _isOnline
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            if (_isUpdatingStatus)
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            else
              Text(
                _isOnline ? 'ONLINE' : 'OFFLINE',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: _isOnline ? Colors.white : Colors.grey[600],
                  letterSpacing: 1,
                ),
              ),
            const SizedBox(width: 8),
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: _isOnline ? Colors.greenAccent : Colors.grey[400],
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsRow() {
    final today = _walletStats?['today']?.toDouble() ?? 0.0;
    final week = _walletStats?['week']?.toDouble() ?? 0.0;
    return Row(
      children: [
        _buildStatBox(
          'Daily Revenue',
          '₹${today.toStringAsFixed(0)}',
          LucideIcons.trendingUp,
          Colors.green,
          '+₹50 more than yesterday',
        ),
        const SizedBox(width: 16),
        _buildStatBox(
          'Weekly Summary',
          '₹${week.toStringAsFixed(0)}',
          LucideIcons.barChart3,
          Colors.blue,
          '12 bookings completed',
        ),
      ],
    );
  }

  Widget _buildStatBox(
    String label,
    String value,
    IconData icon,
    Color color,
    String trend,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.08), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.03),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(height: 16),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              trend,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: color.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertBanner() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              LucideIcons.sparkles,
              size: 100,
              color: Colors.white.withOpacity(0.05),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    LucideIcons.gift,
                    color: Colors.orange,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Unlock Daily Bonus! ⚡',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Complete 5 repairs today and get ₹500 extra cashback directly in your wallet.',
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  LucideIcons.chevronRight,
                  color: Colors.white54,
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    final status = _activeJob?['status'] ?? 'Assigned';
    final List<Map<String, dynamic>> stages = [
      {'title': 'Assigned', 'icon': LucideIcons.checkCircle2},
      {'title': 'On way', 'icon': LucideIcons.truck},
      {'title': 'Arrived', 'icon': LucideIcons.mapPin},
      {'title': 'Repairing', 'icon': LucideIcons.wrench},
      {'title': 'Finished', 'icon': LucideIcons.partyPopper},
    ];

    int currentStageIndex = 0;
    if (status == 'On_Way') currentStageIndex = 1;
    if (status == 'Arrived') currentStageIndex = 2;
    if (status == 'In_Progress') currentStageIndex = 3;
    if (status == 'Completed') currentStageIndex = 4;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Row(
            children: List.generate(stages.length, (index) {
              final bool isDone = index <= currentStageIndex;
              final bool isLast = index == stages.length - 1;

              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 3,
                        color: index == 0
                            ? Colors.transparent
                            : (index <= currentStageIndex
                                  ? Colors.black
                                  : Colors.grey[200]),
                      ),
                    ),
                    Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isDone ? Colors.black : Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDone ? Colors.black : Colors.grey[300]!,
                              width: 2,
                            ),
                            boxShadow: isDone
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Icon(
                            stages[index]['icon'],
                            size: 16,
                            color: isDone ? Colors.white : Colors.grey[400],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          stages[index]['title'],
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: isDone
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: isDone ? Colors.black : Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Container(
                        height: 3,
                        color: isLast
                            ? Colors.transparent
                            : (index < currentStageIndex
                                  ? Colors.black
                                  : Colors.grey[200]),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildComplianceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.green.withOpacity(0.1), width: 1.5),
        gradient: LinearGradient(
          colors: [Colors.white, Colors.green.withOpacity(0.02)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              LucideIcons.shieldCheck,
              color: Colors.green,
              size: 24,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verified Partner',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'Your KYC and documents are fully verified.',
                  style: GoogleFonts.inter(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            child: Text(
              'Details',
              style: GoogleFonts.inter(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveJobCard() {
    if (_activeJob == null) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.grey.shade100, width: 2),
          image: DecorationImage(
            image: const NetworkImage(
              'https://www.transparenttextures.com/patterns/cubes.png',
            ),
            opacity: 0.05,
            colorFilter: ColorFilter.mode(Colors.grey[200]!, BlendMode.srcIn),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.clipboardList,
                size: 32,
                color: Colors.grey[300],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No live jobs at the moment',
              style: GoogleFonts.inter(
                color: Colors.grey[500],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    final device =
        "${_activeJob!['deviceBrand']} ${_activeJob!['deviceModel']}";
    final issues = (_activeJob!['issues'] as List)
        .map((i) => i['issueName'])
        .join(", ");
    final status = _activeJob!['status'];
    final id = _activeJob!['_id'].toString().substring(0, 8);

    String statusText = status;
    if (status == 'On_Way') statusText = 'ON THE WAY';
    if (status == 'Arrived') statusText = 'ARRIVED';
    if (status == 'In_Progress') statusText = 'IN PROGRESS';

    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.blue.withOpacity(0.2),
            blurRadius: 40,
            spreadRadius: -10,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            top: -30,
            right: -30,
            child: CircleAvatar(
              radius: 80,
              backgroundColor: Colors.white.withOpacity(0.05),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        LucideIcons.smartphone,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            device,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'ORDER #$id',
                              style: GoogleFonts.inter(
                                color: Colors.white60,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildPulseIndicator(statusText),
                  ],
                ),
                const SizedBox(height: 24),
                Divider(color: Colors.white.withOpacity(0.1), height: 1),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'REPORTED ISSUES',
                            style: GoogleFonts.inter(
                              color: Colors.white54,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            issues,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'CUSTOMER',
                          style: GoogleFonts.inter(
                            color: Colors.white54,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              _activeJob!['userId']?['name'] ?? 'Customer',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            CircleAvatar(
                              radius: 12,
                              backgroundImage:
                                  _activeJob!['userId']?['photoUrl'] != null
                                  ? NetworkImage(
                                      _activeJob!['userId']['photoUrl'],
                                    )
                                  : const NetworkImage(
                                          'https://i.pravatar.cc/150?img=12',
                                        )
                                        as ImageProvider,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              JobDetailsScreen(orderId: _activeJob!['_id']),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Manage Repair Session',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPulseIndicator(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PulseCircle(),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.inter(
              color: Colors.blue,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewJobRequest() {
    if (_pendingBookings.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          children: [
            Icon(LucideIcons.mailOpen, size: 32, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              "No new requests at the moment",
              style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 13),
            ),
          ],
        ),
      );
    }

    return Column(
      children: _pendingBookings.map((booking) {
        final bookingId = booking['_id'];
        final device = "${booking['deviceBrand']} ${booking['deviceModel']}";
        final issues = (booking['issues'] as List)
            .map((i) => i['issueName'])
            .join(", ");
        final price = "₹${booking['totalPrice']}";

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.orange.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 8),
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
                      color: Colors.orange.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.zap,
                      color: Colors.orange,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Urgent Request',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          '$device • $issues',
                          style: GoogleFonts.inter(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      price,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _handleResponse(bookingId, 'reject'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: BorderSide(color: Colors.red.withOpacity(0.3)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Decline'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _handleResponse(bookingId, 'accept'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Accept Now'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWalletCard() {
    final balance = _walletStats?['balance']?.toDouble() ?? 0.0;
    final pending = _walletStats?['pending']?.toDouble() ?? 0.0;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo[900]!, Colors.black],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              LucideIcons.wallet2,
              size: 120,
              color: Colors.white.withOpacity(0.05),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Available Balance',
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        LucideIcons.info,
                        color: Colors.white70,
                        size: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '₹${balance.toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'On Hold',
                              style: GoogleFonts.inter(
                                color: Colors.white54,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '₹${pending.toStringAsFixed(0)}',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () => widget.onTabChange(2),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Withdraw',
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard() {
    final reviewedBookings = _allBookings
        .where((b) => b['reviewed'] == true)
        .toList();
    if (reviewedBookings.isEmpty) {
      return Container(
        height: 100,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Text(
          'No reviews yet',
          style: GoogleFonts.inter(color: Colors.grey),
        ),
      );
    }

    final latestReview = reviewedBookings.first;
    final userName = latestReview['userId']?['name'] ?? 'Customer';
    final userImg = latestReview['userId']?['photoUrl'];
    final rating = latestReview['rating'] ?? 0;
    final text = latestReview['reviewText'] ?? 'No comment provided';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey[100],
                backgroundImage: userImg != null ? NetworkImage(userImg) : null,
                child: userImg == null
                    ? const Icon(LucideIcons.user, size: 18, color: Colors.grey)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: i < rating ? Colors.amber : Colors.grey[200],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Yesterday',
                style: GoogleFonts.inter(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.grey[700],
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String sub) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              sub,
              style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
        if (title == 'Immediate Action Required' || title == 'New Requests')
          TextButton(
            onPressed: () => widget.onTabChange(1),
            child: Row(
              children: [
                Text(
                  'View All',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const Icon(
                  LucideIcons.chevronRight,
                  size: 16,
                  color: Colors.blue,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _PulseCircle extends StatefulWidget {
  const _PulseCircle();

  @override
  State<_PulseCircle> createState() => _PulseCircleState();
}

class _PulseCircleState extends State<_PulseCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue,
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(1 - _controller.value),
                spreadRadius: _controller.value * 5,
                blurRadius: 5,
              ),
            ],
          ),
        );
      },
    );
  }
}
