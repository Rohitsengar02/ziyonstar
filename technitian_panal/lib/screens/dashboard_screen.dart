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

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      body: _pages[_selectedIndex],
      bottomNavigationBar: _buildBottomNav(),
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
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header / Profile Section
            _buildHeader(),
            const SizedBox(height: 28),

            // 4. Earnings Snapshot (Moved up for quick visibility)
            _buildEarningsRow(),
            const SizedBox(height: 28),

            // 2. Announcements & Alerts (Important for admin broadcast)
            _buildAlertBanner(),
            const SizedBox(height: 28),

            // 7. Job Status Timeline (For active job)
            if (_activeJob != null) ...[
              _buildSectionHeader('Job Timeline', 'Current Progress'),
              const SizedBox(height: 12),
              _buildTimeline(),
              const SizedBox(height: 28),
            ],

            // 2. Active Jobs Section
            _buildSectionHeader('Live Job', 'Track Progress'),
            const SizedBox(height: 12),
            _buildActiveJobCard(),
            const SizedBox(height: 28),

            // 11. Compliance & KYC Status
            _buildComplianceCard(),
            const SizedBox(height: 28),

            // 3. New Job Requests
            _buildSectionHeader('New Requests', 'Accept Now'),
            const SizedBox(height: 12),
            _buildNewJobRequest(),
            const SizedBox(height: 28),

            // 5. Wallet Section
            _buildWalletCard(),
            const SizedBox(height: 28),

            // 9. Ratings & Reviews
            _buildSectionHeader('Reviews', 'Recent Feedback'),
            const SizedBox(height: 12),
            _buildReviewCard(),
            const SizedBox(height: 40),
          ],
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
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: CircleAvatar(
                radius: 28,
                backgroundColor: Colors.grey[200],
                backgroundImage:
                    widget.technicianData['photoUrl'] != null &&
                        widget.technicianData['photoUrl'].isNotEmpty
                    ? NetworkImage(widget.technicianData['photoUrl'])
                    : const NetworkImage('https://i.pravatar.cc/150?img=11')
                          as ImageProvider,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.check,
                  size: 10,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textHeading,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    LucideIcons.badgeCheck,
                    size: 16,
                    color: Colors.blue,
                  ),
                ],
              ),
              Text(
                widget.technicianData['experience'] ??
                    'Professional Technician',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textBody,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.technicianData['averageRating'] ?? 0.0}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    ' (${widget.technicianData['totalReviews'] ?? 0})',
                    style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _isOnline ? Colors.black : Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _isOnline ? Colors.green : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              if (_isUpdatingStatus)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              else
                Switch(
                  value: _isOnline,
                  onChanged: (val) => _toggleOnlineStatus(val),
                  activeColor: Colors.white,
                  activeTrackColor: Colors.green.withOpacity(0.5),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEarningsRow() {
    final today = _walletStats?['today']?.toDouble() ?? 0.0;
    final week = _walletStats?['week']?.toDouble() ?? 0.0;
    return Row(
      children: [
        _buildStatBox(
          'Today',
          '₹${today.toStringAsFixed(0)}',
          LucideIcons.trendingUp,
          Colors.green,
        ),
        const SizedBox(width: 12),
        _buildStatBox(
          'This Week',
          '₹${week.toStringAsFixed(0)}',
          LucideIcons.calendar,
          Colors.blue,
        ),
      ],
    );
  }

  Widget _buildStatBox(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(icon, size: 16, color: color),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.megaphone,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'New Bonus Policy',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  'Complete 5 repairs today and get ₹500 extra!',
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
          const Icon(LucideIcons.chevronRight, color: Colors.white54, size: 16),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    final status = _activeJob?['status'];
    final List<Map<String, dynamic>> stages = [
      {'title': 'Assigned', 'done': true},
      {
        'title': 'On way',
        'done':
            status == 'On_Way' ||
            status == 'Arrived' ||
            status == 'In_Progress' ||
            status == 'Completed',
      },
      {
        'title': 'Arrived',
        'done':
            status == 'Arrived' ||
            status == 'In_Progress' ||
            status == 'Completed',
      },
      {
        'title': 'Repair',
        'done': status == 'In_Progress' || status == 'Completed',
      },
      {'title': 'Paid', 'done': status == 'Completed'},
    ];

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: stages.map((s) {
          int idx = stages.indexOf(s);
          return Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    if (idx != 0)
                      Expanded(
                        child: Divider(
                          color: stages[idx - 1]['done'] && s['done']
                              ? Colors.black
                              : Colors.grey[300],
                          thickness: 2,
                        ),
                      ),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: s['done'] ? Colors.black : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: s['done']
                              ? Colors.black
                              : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: s['done']
                          ? const Icon(
                              Icons.check,
                              size: 14,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    if (idx != stages.length - 1)
                      Expanded(
                        child: Divider(
                          color: s['done'] && stages[idx + 1]['done']
                              ? Colors.black
                              : Colors.grey[300],
                          thickness: 2,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  s['title'],
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: s['done'] ? Colors.black : Colors.grey,
                    fontWeight: s['done'] ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildComplianceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green[50],
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.shieldCheck,
              color: Colors.green,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'KYC Status: Verified',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'All documents approved',
                  style: GoogleFonts.inter(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            'View Docs',
            style: GoogleFonts.inter(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveJobCard() {
    if (_activeJob == null) {
      return Container(
        padding: const EdgeInsets.all(28),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          children: [
            Icon(LucideIcons.clipboardList, size: 40, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No active job right now',
              style: GoogleFonts.inter(
                color: Colors.grey,
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
    if (status == 'On_Way') statusText = 'On the way';
    if (status == 'Arrived') statusText = 'Arrived';
    if (status == 'In_Progress') statusText = 'In progress';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
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
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  LucideIcons.smartphone,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      issues,
                      style: GoogleFonts.inter(
                        color: Colors.grey[400],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusText,
                  style: GoogleFonts.inter(
                    color: Colors.blue,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(LucideIcons.hash, color: Colors.grey, size: 14),
              const SizedBox(width: 4),
              Text(
                'ORD-#$id',
                style: GoogleFonts.inter(color: Colors.grey[400], fontSize: 12),
              ),
              const Spacer(),
              Row(
                children: [
                  CircleAvatar(
                    radius: 10,
                    backgroundImage: _activeJob!['userId']?['photoUrl'] != null
                        ? NetworkImage(_activeJob!['userId']['photoUrl'])
                        : const AssetImage('assets/images/tech_avatar_1.png')
                              as ImageProvider,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _activeJob!['userId']?['name'] ?? 'Customer',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            JobDetailsScreen(orderId: _activeJob!['_id']),
                      ),
                    );
                  },
                  icon: const Icon(LucideIcons.eye, size: 16),
                  label: const Text('View Details'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNewJobRequest() {
    if (_pendingBookings.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        alignment: Alignment.center,
        child: Text(
          "No new requests",
          style: GoogleFonts.inter(color: Colors.grey),
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
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.orange.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.orange.withOpacity(0.1),
                    child: const Icon(
                      LucideIcons.zap,
                      color: Colors.orange,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'New Job Request',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          '$device • $issues',
                          style: GoogleFonts.inter(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    price,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _handleResponse(bookingId, 'reject'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _handleResponse(bookingId, 'accept'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Accept'),
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey[900]!, Colors.black],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Wallet Balance',
                style: GoogleFonts.inter(color: Colors.grey[400], fontSize: 14),
              ),
              const Icon(LucideIcons.wallet, color: Colors.white54, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '₹${balance.toStringAsFixed(2)}',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pending',
                        style: GoogleFonts.inter(
                          color: Colors.grey,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        '₹${pending.toStringAsFixed(0)}',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  widget.onTabChange(2); // Go to wallet tab
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                ),
                child: const Text('Withdraw'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Removed Inventory and Support as requested

  Widget _buildReviewCard() {
    final reviewedBookings = _allBookings
        .where((b) => b['reviewed'] == true)
        .toList();
    if (reviewedBookings.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Center(
          child: Text(
            'No reviews yet',
            style: GoogleFonts.inter(color: Colors.grey),
          ),
        ),
      );
    }

    final latestReview = reviewedBookings.first;
    final userName = latestReview['userId']?['name'] ?? 'Customer';
    final userImg = latestReview['userId']?['photoUrl'];
    final rating = latestReview['rating'] ?? 0;
    final text = latestReview['reviewText'] ?? 'No comment provided';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundImage: userImg != null
                    ? NetworkImage(userImg)
                    : const NetworkImage('https://i.pravatar.cc/150?img=5')
                          as ImageProvider,
              ),
              const SizedBox(width: 8),
              Text(
                userName,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    Icons.star_rounded,
                    size: 14,
                    color: i < rating ? Colors.amber : Colors.grey[300],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.grey[700],
              height: 1.5,
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
              ),
            ),
            Text(
              sub,
              style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        if (title == 'New Requests')
          TextButton(
            onPressed: () {
              widget.onTabChange(1); // Go to My Jobs
            },
            child: const Text(
              'View All',
              style: TextStyle(color: Colors.black),
            ),
          ),
      ],
    );
  }
}
