import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../users/users_screen.dart';
import '../technicians/technicians_screen.dart';
import '../services/services_screen.dart';
import '../orders/orders_screen.dart';
import '../disputes/disputes_screen.dart';
import '../payouts/payouts_screen.dart';
import '../commissions/commission_screen.dart';
import '../analytics/analytics_screen.dart';
import '../promos/promos_screen.dart';
import '../support/support_screen.dart';
import 'approve_admins_screen.dart';
import '../notifications/notifications_screen.dart';
import '../auth/login_screen.dart';
import '../profile/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_colors.dart';
import '../../services/api_service.dart';

class AdminDashboard extends StatefulWidget {
  final Map<String, dynamic>? user;
  const AdminDashboard({super.key, this.user});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final ApiService _apiService = ApiService();
  final PageController _pageController = PageController();
  bool _isLoading = true;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    try {
      final data = await _apiService
          .getAnalytics(); // Ensure this method exists and returns correct structure
      if (mounted) {
        setState(() {
          _data = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading dashboard: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Header / Profile Section
                    _buildHeader(context),
                    const SizedBox(height: 28),

                    // Overall Performance
                    _buildSectionHeader(
                      context,
                      'Overall Performance',
                      'Financial Overview',
                    ),
                    const SizedBox(height: 12),
                    _buildOverallPerformanceCarousel(),
                    const SizedBox(height: 28),


                    // 3. Orders Overview
                    _buildSectionHeader(
                      context,
                      'Orders Overview',
                      'Growth & Volume',
                    ),
                    const SizedBox(height: 12),
                    _buildOrdersOverview(),
                    const SizedBox(height: 28),

                    // 6. Revenue Summary
                    _buildSectionHeader(
                      context,
                      'Revenue Summary',
                      'Financial Health',
                    ),
                    const SizedBox(height: 12),
                    _buildRevenueSummary(),
                    const SizedBox(height: 28),

                    // 11. Active Jobs
                    _buildSectionHeader(
                      context,
                      'Ongoing Repairs',
                      'Live Tracking',
                    ),
                    const SizedBox(height: 12),
                    _buildActiveJobsList(),
                    const SizedBox(height: 28),

                    // 4. Technicians Overview
                    _buildSectionHeader(
                      context,
                      'Technicians Workforce',
                      'Onboarding & Presence',
                    ),
                    const SizedBox(height: 12),
                    _buildTechniciansOverview(),
                    const SizedBox(height: 28),

                    // 5. Users Overview
                    _buildSectionHeader(
                      context,
                      'Customer Base',
                      'Growth & retention',
                    ),
                    const SizedBox(height: 12),
                    _buildUsersOverview(),
                    const SizedBox(height: 28),

                    // 8. Disputes Overview
                    _buildSectionHeader(
                      context,
                      'Disputes & Resolutions',
                      'Platform Quality',
                    ),
                    const SizedBox(height: 12),
                    _buildDisputesOverview(),
                    const SizedBox(height: 28),

                    // 9. Verification Status
                    _buildSectionHeader(
                      context,
                      'Onboarding Pipeline',
                      'Compliance Checks',
                    ),
                    const SizedBox(height: 12),
                    _buildVerificationStatus(),
                    const SizedBox(height: 28),

                    // 15. Announcements / Alerts
                    _buildSectionHeader(
                      context,
                      'System Alerts',
                      'Critical Notifications',
                    ),
                    const SizedBox(height: 12),
                    _buildAlertBanner(),
                    const SizedBox(height: 28),

                    // 20. Technician Leaderboard
                    _buildSectionHeader(
                      context,
                      'Leaderboard',
                      'Top Performers',
                    ),
                    const SizedBox(height: 12),
                    _buildLeaderboard(),
                    const SizedBox(height: 28),

                    // 16. Charts & Analytics
                    _buildSectionHeader(
                      context,
                      'Business Analytics',
                      'Trends & Data',
                    ),
                    const SizedBox(height: 12),
                    _buildChartsSection(),
                    const SizedBox(height: 28),

                    // 13. Recent Transactions
                    _buildSectionHeader(
                      context,
                      'Recent Transactions',
                      'Financial Ledger',
                    ),
                    const SizedBox(height: 12),
                    _buildTransactionList(),
                    const SizedBox(height: 28),

                    // 14. Recent Orders
                    _buildSectionHeader(
                      context,
                      'Latest Orders',
                      'Recent Activity',
                    ),
                    const SizedBox(height: 12),
                    _buildRecentOrders(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final user = widget.user;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileScreen(user: widget.user),
              ),
            );
          },
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: CircleAvatar(
                  radius: 24,
                  backgroundImage:
                      (user?['profileImage'] != null &&
                          user!['profileImage'].toString().isNotEmpty)
                      ? NetworkImage(user!['profileImage'])
                      : const NetworkImage('https://i.pravatar.cc/150?img=11'),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?['name'] ?? 'Super Admin',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    (user?['role'] == 'master_admin')
                        ? 'Master Admin'
                        : 'Operations Control',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Row(
          children: [
            _buildIconButton(
              LucideIcons.bell,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminNotificationsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
            _buildIconButton(
              LucideIcons.settings,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(user: widget.user),
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
            _buildIconButton(
              LucideIcons.logOut,
              onPressed: () => _handleLogout(context),
              color: Colors.red,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIconButton(
    IconData icon, {
    VoidCallback? onPressed,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Icon(icon, size: 20, color: color ?? Colors.black),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, String sub) {
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
        TextButton(
          onPressed: () {
            if (title == 'Technicians Workforce') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TechniciansScreen(),
                ),
              );
            } else if (title == 'Customer Base' || title == 'Users Overview') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UsersScreen()),
              );
            } else if (title == 'Orders Overview') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OrdersScreen()),
              );
            }
          },

          child: const Text(
            'View All',
            style: TextStyle(
              color: Colors.black,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrdersOverview() {
    final orders = _data?['ordersOverview'] ?? {};
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildOverviewItem(
                'Today',
                '${orders['today'] ?? 0}',
                Colors.white,
              ),
              _buildOverviewItem(
                'Weekly',
                '${orders['weekly'] ?? 0}',
                Colors.white,
              ),
              _buildOverviewItem(
                'Monthly',
                '${orders['monthly'] ?? 0}',
                Colors.white,
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildOverviewItem(
                'Ongoing',
                '${orders['ongoing'] ?? 0}',
                Colors.blue,
              ),
              _buildOverviewItem(
                'Scheduled',
                '${orders['scheduled'] ?? 0}',
                Colors.orange,
              ),
              _buildOverviewItem(
                'Cancelled',
                '${orders['cancelled'] ?? 0}',
                Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _buildRevenueSummary() {
    final revenue = _data?['revenueSummary'] ?? {};
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          _buildRevenueRow(
            'Gross Revenue',
            '₹${revenue['gross'] ?? 0}',
            isLarge: true,
          ),
          const Divider(height: 32),
          _buildRevenueRow(
            'Net Earnings',
            '₹${revenue['net'] ?? 0}',
            color: Colors.green,
          ),
          _buildRevenueRow(
            'Admin Commission',
            '₹${revenue['commission'] ?? 0}',
            color: Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildRevenueRow(
            'Today Earnings',
            '₹${revenue['today'] ?? 0}',
            isSmall: true,
          ),
          _buildRevenueRow(
            'Month-to-date',
            '₹${revenue['month'] ?? 0}',
            isSmall: true,
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueRow(
    String label,
    String value, {
    bool isLarge = false,
    bool isSmall = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: isSmall ? 12 : 14,
              color: isSmall ? Colors.grey : Colors.black,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: isLarge ? 20 : 16,
              fontWeight: FontWeight.bold,
              color: color ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechniciansOverview() {
    final techs = _data?['techs'] ?? {};
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 2.2,
      children: [
        _buildTechStatusCard(
          'Verified',
          '${techs['verified'] ?? 0}',
          Colors.green,
        ),
        _buildTechStatusCard(
          'Pending',
          '${techs['pending'] ?? 0}',
          Colors.orange,
        ),
        _buildTechStatusCard('Online', '${techs['online'] ?? 0}', Colors.blue),
        _buildTechStatusCard(
          'Deactivated',
          '${techs['deactivated'] ?? 0}',
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildTechStatusCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersOverview() {
    final users = _data?['users'] ?? {};
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildOverviewItem(
            'Total Users',
            '${users['total'] ?? 0}',
            Colors.black,
          ),
          _buildOverviewItem(
            'New Signups',
            '${users['new'] ?? 0}',
            Colors.green,
          ),
          _buildOverviewItem(
            'Returning',
            '${users['returning'] ?? "N/A"}',
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildDisputesOverview() {
    final disputes = _data?['disputeStats'] ?? {};
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildOverviewItem('Open', '${disputes['open'] ?? 0}', Colors.red),
          _buildOverviewItem(
            'In-Review',
            '${disputes['investigation'] ?? 0}',
            Colors.orange,
          ),
          _buildOverviewItem(
            'Resolved',
            '${disputes['resolved'] ?? 0}',
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationStatus() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          _buildVerificationRow('KYC Pending', '12', Colors.orange),
          _buildVerificationRow('KYC Approved Today', '5', Colors.green),
          _buildVerificationRow('Rejected', '2', Colors.red),
          _buildVerificationRow('Skill Verifications', '8', Colors.blue),
        ],
      ),
    );
  }

  Widget _buildVerificationRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 12),
              Text(label, style: GoogleFonts.inter(fontSize: 14)),
            ],
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.alertTriangle,
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
                  '3 High Complaint Rates',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                Text(
                  'Technicians in Noida have crossed the 10% complaint threshold.',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.red.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveJobsList() {
    final active = _data?['activeOrders'] as List? ?? [];

    if (active.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text("No active jobs right now"),
      );
    }

    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: active.length,
        itemBuilder: (context, index) {
          final order = active[index];
          final id = order['_id']?.toString().substring(0, 8) ?? 'Unknown';

          return Container(
            width: 300,
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(20),
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
                      'ORD-#$id',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        order['status'] ?? 'Active',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '${order['deviceBrand']} ${order['deviceModel']}',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  'User: ${order['userId']?['name'] ?? 'Unknown'}',
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Price: ₹${order['totalPrice']}',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.green,
                      ),
                    ),
                    const Text(
                      'View Details',
                      style: TextStyle(
                        fontSize: 12,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverallPerformanceCarousel() {
    final revenue = _data?['revenueSummary'] ?? {};
    final totalRevenue = revenue['gross'] ?? 0;
    final platformRevenue = revenue['commission'] ?? 0;

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PageView(
            controller: _pageController,
            children: [
              _buildPerformanceCard(
                'Total Revenue',
                '₹$totalRevenue',
                Colors.blue,
                LucideIcons.barChart3,
              ),
              _buildPerformanceCard(
                'Platform Revenue',
                '₹$platformRevenue',
                Colors.indigo,
                LucideIcons.wallet,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Indicator could go here
      ],
    );
  }

  Widget _buildPerformanceCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const Spacer(),
          Text(
            title,
            style: GoogleFonts.inter(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          _buildLeaderboardItem('Arjun Malhotra', '₹1.2L • ⭐ 4.9', 1),
          const Divider(height: 1),
          _buildLeaderboardItem('Vikram Singh', '₹1.0L • ⭐ 4.8', 2),
        ],
      ),
    );
  }

  Widget _buildLeaderboardItem(String name, String stats, int rank) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.secondary,
        child: Text(
          '#$rank',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      title: Text(
        name,
        style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      subtitle: Text(
        stats,
        style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
      ),
      trailing: const Icon(
        LucideIcons.trendingUp,
        color: Colors.green,
        size: 18,
      ),
    );
  }

  Widget _buildChartsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Growth Trend',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(
                7,
                (index) => Container(
                  width: 25,
                  height: 30.0 + (index * 10.0),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.5 + (index * 0.05)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'City-wise Breakdown: Gurgaon (42%), Noida (38%), Delhi (20%)',
            style: GoogleFonts.inter(color: Colors.white60, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: List.generate(
          3,
          (index) => ListTile(
            leading: const Icon(LucideIcons.arrowUpRight, color: Colors.green),
            title: const Text(
              'Payment Received',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            subtitle: const Text(
              'ORD-#8274 • UPI',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
            trailing: const Text(
              '₹2,499',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentOrders() {
    return Column(
      children: List.generate(
        2,
        (index) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(LucideIcons.smartphone, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'iPhone 12 Pro',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Screen Issue • Amit S.',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'COMPLETED',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(LucideIcons.layoutGrid, 'Home', true, onTap: () {}),
          _buildNavItem(
            LucideIcons.shoppingBag,
            'Orders',
            false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OrdersScreen()),
              );
            },
          ),
          _buildNavItem(
            LucideIcons.hardHat,
            'Techs',
            false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TechniciansScreen(),
                ),
              );
            },
          ),
          _buildNavItem(
            LucideIcons.wrench,
            'Services',
            false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ServicesScreen()),
              );
            },
          ),
          _buildNavItem(
            LucideIcons.menu,
            'More',
            false,
            onTap: () => _showMoreMenu(context),
          ),
        ],
      ),
    );
  }

  void _showMoreMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 32),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              mainAxisSpacing: 24,
              crossAxisSpacing: 16,
              children: [
                if (widget.user != null &&
                    widget.user!['role'] == 'master_admin')
                  _buildMenuIcon(
                    context,
                    LucideIcons.userCheck,
                    'Approve',
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ApproveAdminsScreen(),
                      ),
                    ),
                  ),
                _buildMenuIcon(
                  context,
                  LucideIcons.users,
                  'Users',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UsersScreen(),
                    ),
                  ),
                ),
                _buildMenuIcon(
                  context,
                  LucideIcons.shieldAlert,
                  'Disputes',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DisputesScreen(),
                    ),
                  ),
                ),
                _buildMenuIcon(
                  context,
                  LucideIcons.banknote,
                  'Payouts',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PayoutsScreen(),
                    ),
                  ),
                ),
                _buildMenuIcon(
                  context,
                  LucideIcons.percent,
                  'Rates',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CommissionScreen(),
                    ),
                  ),
                ),
                _buildMenuIcon(
                  context,
                  LucideIcons.pieChart,
                  'Analytics',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AnalyticsScreen(),
                    ),
                  ),
                ),
                _buildMenuIcon(
                  context,
                  LucideIcons.tag,
                  'Promos',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PromosScreen(),
                    ),
                  ),
                ),
                _buildMenuIcon(
                  context,
                  LucideIcons.lifeBuoy,
                  'Support',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SupportScreen(),
                    ),
                  ),
                ),
                _buildMenuIcon(
                  context,
                  LucideIcons.settings,
                  'Settings',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(user: widget.user),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuIcon(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.black, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    bool isActive, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? Colors.black : Colors.grey, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: isActive ? Colors.black : Colors.grey,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_session');

    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
        (route) => false,
      );
    }
  }
}
