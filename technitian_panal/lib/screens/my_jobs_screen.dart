import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'job_details_screen.dart';
import 'map_screen.dart';
import '../services/api_service.dart';

class MyJobsScreen extends StatefulWidget {
  final String technicianId;
  const MyJobsScreen({super.key, required this.technicianId});

  @override
  State<MyJobsScreen> createState() => _MyJobsScreenState();
}

class _MyJobsScreenState extends State<MyJobsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();
  List<dynamic> _activeJobs = [];
  List<dynamic> _historyJobs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchJobs();
  }

  Future<void> _fetchJobs() async {
    try {
      final bookings = await _apiService.getTechnicianBookings(
        widget.technicianId,
      );

      setState(() {
        // Active jobs: Accepted, In_Progress, Pending_Acceptance
        _activeJobs = bookings
            .where(
              (b) =>
                  b['status'] == 'Accepted' ||
                  b['status'] == 'In_Progress' ||
                  b['status'] == 'Pending_Acceptance' ||
                  b['status'] == 'On_Way' ||
                  b['status'] == 'Arrived',
            )
            .toList();

        // History: Completed, Cancelled, Rejected
        _historyJobs = bookings
            .where(
              (b) =>
                  b['status'] == 'Completed' ||
                  b['status'] == 'Cancelled' ||
                  b['status'] == 'Rejected',
            )
            .toList();

        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching jobs: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: Text(
          'My Jobs',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: _fetchJobs,
            icon: const Icon(LucideIcons.refreshCw, size: 20),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.black,
          indicatorWeight: 3,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          labelStyle: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          tabs: [
            Tab(text: 'Active Jobs (${_activeJobs.length})'),
            Tab(text: 'History (${_historyJobs.length})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildJobsList(_activeJobs, isActive: true),
                _buildJobsList(_historyJobs, isActive: false),
              ],
            ),
    );
  }

  Widget _buildJobsList(List<dynamic> jobs, {required bool isActive}) {
    if (jobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? LucideIcons.briefcase : LucideIcons.history,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              isActive ? 'No active jobs' : 'No job history',
              style: GoogleFonts.inter(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchJobs,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: jobs.length,
        itemBuilder: (context, index) {
          final job = jobs[index];
          final issues =
              (job['issues'] as List?)
                  ?.map((i) => i['issueName']?.toString() ?? '')
                  .join(', ') ??
              'N/A';
          final user = job['userId'];
          final customerName = user is Map
              ? (user['name'] ?? 'Customer')
              : 'Customer';

          final addressObj = job['address'];
          String displayAddress =
              job['addressDetails'] ?? 'Address not provided';
          if (addressObj is Map) {
            final full = addressObj['fullAddress'] ?? '';
            final landmark = addressObj['landmark'] ?? '';
            displayAddress = landmark.isNotEmpty ? '$full ($landmark)' : full;
          }

          return _buildJobCard(
            booking: job,
            orderId: job['_id']?.toString().substring(0, 8) ?? 'N/A',
            device:
                '${job['deviceBrand'] ?? 'Unknown'} ${job['deviceModel'] ?? ''}',
            issue: issues,
            status: job['status'] ?? 'Unknown',
            date: job['scheduledDate'] ?? 'N/A',
            price: '₹${job['totalPrice'] ?? 0}',
            address: displayAddress,
            customerName: customerName,
            customerImage: user is Map ? user['photoUrl'] : null,
            isActive: isActive,
          );
        },
      ),
    );
  }

  Widget _buildJobCard({
    required dynamic booking,
    required String orderId,
    required String device,
    required String issue,
    required String status,
    required String date,
    required String price,
    required String address,
    required String customerName,
    String? customerImage,
    required bool isActive,
  }) {
    final List<dynamic> issuesData = booking['issues'] ?? [];
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => JobDetailsScreen(orderId: booking['_id']),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ORD-#$orderId',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
                _buildStatusBadge(status),
              ],
            ),
            if (booking['reviewed'] == true) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < (booking['rating'] ?? 0)
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: Colors.amber,
                        size: 14,
                      );
                    }),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${booking['rating']}.0',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade900,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                CircleAvatar(
                  radius: 10,
                  backgroundImage:
                      (customerImage != null && customerImage.isNotEmpty)
                      ? NetworkImage(customerImage)
                      : const AssetImage('assets/images/tech_avatar_1.png')
                            as ImageProvider,
                  backgroundColor: Colors.grey[200],
                ),
                const SizedBox(width: 8),
                Text(
                  customerName,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    LucideIcons.smartphone,
                    size: 24,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        device,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        issue,
                        style: GoogleFonts.inter(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Text(
                  price,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            if (issuesData.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 32,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: issuesData.length,
                  itemBuilder: (context, i) {
                    final img = issuesData[i]['issueImage'];
                    final name = issuesData[i]['issueName'] ?? 'Issue';
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (img != null && img.toString().isNotEmpty)
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                image: DecorationImage(
                                  image: NetworkImage(img),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          else
                            const Icon(
                              LucideIcons.wrench,
                              size: 14,
                              color: Colors.grey,
                            ),
                          const SizedBox(width: 6),
                          Text(
                            name,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
            const Divider(height: 32),
            if (isActive)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MapScreen(
                              orderId:
                                  booking['_id'], // Pass full ID for API call
                              destination: address,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(LucideIcons.navigation, size: 16),
                      label: const Text('Navigate'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              JobDetailsScreen(orderId: booking['_id']),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('View Details'),
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  const Icon(
                    LucideIcons.calendar,
                    size: 14,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      date,
                      style: GoogleFonts.inter(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Text(
                    'Details',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(LucideIcons.chevronRight, size: 14),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case 'Completed':
        bgColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green;
        break;
      case 'In_Progress':
      case 'Accepted':
        bgColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue;
        break;
      case 'Pending_Acceptance':
        bgColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        break;
      case 'On_Way':
        bgColor = Colors.amber.withOpacity(0.1);
        textColor = Colors.amber.shade900;
        break;
      case 'Arrived':
        bgColor = Colors.teal.withOpacity(0.1);
        textColor = Colors.teal;
        break;
      case 'Rejected':
      case 'Cancelled':
        bgColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red;
        break;
      default:
        bgColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
