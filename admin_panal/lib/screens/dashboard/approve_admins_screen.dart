import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../services/api_service.dart';
import '../../theme/app_colors.dart';
import '../technicians/technician_detail_screen.dart';
import 'expertise_request_detail_screen.dart';

class ApproveAdminsScreen extends StatefulWidget {
  const ApproveAdminsScreen({super.key});

  @override
  State<ApproveAdminsScreen> createState() => _ApproveAdminsScreenState();
}

class _ApproveAdminsScreenState extends State<ApproveAdminsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _pendingAdmins = [];
  List<Map<String, dynamic>> _approvedAdmins = [];
  List<dynamic> _pendingTechs = [];
  List<dynamic> _expertiseRequests = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final pending = await _apiService.getPendingAdmins();
      final approved = await _apiService.getApprovedAdmins();
      final techs = await _apiService.getTechnicians();

      if (mounted) {
        setState(() {
          _pendingAdmins = pending;
          _approvedAdmins = approved;
          _pendingTechs = techs.where((t) => t['status'] == 'pending').toList();
          _expertiseRequests = [];
        });

        // Load expertise requests separately
        final requests = await _apiService.getPendingExpertiseRequests();
        if (mounted) {
          setState(() {
            _expertiseRequests = requests;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _approve(String id) async {
    try {
      await _apiService.approveAdmin(id);
      _loadData();
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Admin Approved')));
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _rejectOrDelete(String id, {bool isDelete = false}) async {
    try {
      await _apiService.deleteAdmin(id);
      _loadData();
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isDelete ? 'Admin Removed' : 'Request Rejected'),
          ),
        );
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _editAdmin(Map<String, dynamic> admin) async {
    final nameController = TextEditingController(text: admin['name']);
    final deptController = TextEditingController(
      text: admin['department'] ?? '',
    );

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Edit Admin',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: deptController,
              decoration: const InputDecoration(
                labelText: 'Department',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _apiService.updateAdmin(admin['_id'], {
                  'name': nameController.text,
                  'department': deptController.text,
                });
                if (mounted) {
                  Navigator.pop(context);
                  _loadData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Updated successfully')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: Text(
          'Approvals & Team',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelStyle: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              tabs: [
                Tab(
                  text: 'Admins (${_isLoading ? '-' : _pendingAdmins.length})',
                ),
                Tab(text: 'Techs (${_isLoading ? '-' : _pendingTechs.length})'),
                Tab(
                  text:
                      'Expertise (${_isLoading ? '-' : _expertiseRequests.length})',
                ),
                Tab(
                  text:
                      'Active Team (${_isLoading ? '-' : _approvedAdmins.length})',
                ),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildStatsSection(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildList(_pendingAdmins, isPending: true),
                      _buildTechList(_pendingTechs),
                      _buildExpertiseRequestList(_expertiseRequests),
                      _buildList(_approvedAdmins, isPending: false),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: const Color(0xFFF6F8FA),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Pending',
              (_pendingAdmins.length + _pendingTechs.length).toString(),
              Colors.orange,
              LucideIcons.clock,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Active',
              _approvedAdmins.length.toString(),
              Colors.green,
              LucideIcons.shieldCheck,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Total',
              (_pendingAdmins.length +
                      _approvedAdmins.length +
                      _pendingTechs.length)
                  .toString(),
              Colors.blue,
              LucideIcons.users,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String count,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            count,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildList(
    List<Map<String, dynamic>> admins, {
    required bool isPending,
  }) {
    if (admins.isEmpty) {
      return _buildEmptyState(
        isPending ? LucideIcons.clipboardCheck : LucideIcons.users,
        isPending ? "No pending admn requests" : "No active admins",
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: admins.length,
      itemBuilder: (context, index) {
        final admin = admins[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (isPending ? Colors.orange : Colors.blue).withValues(
                    alpha: 0.1,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  LucideIcons.user,
                  color: (isPending ? Colors.orange : Colors.blue),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      admin['name'] ?? 'Unknown',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      admin['email'] ?? '',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              if (isPending) ...[
                IconButton(
                  onPressed: () => _approve(admin['_id']),
                  icon: const Icon(
                    LucideIcons.checkCircle,
                    color: Colors.green,
                  ),
                ),
                IconButton(
                  onPressed: () => _rejectOrDelete(admin['_id']),
                  icon: const Icon(LucideIcons.xCircle, color: Colors.red),
                ),
              ] else ...[
                IconButton(
                  onPressed: () => _editAdmin(admin),
                  icon: const Icon(
                    LucideIcons.pencil,
                    color: Colors.blueGrey,
                    size: 20,
                  ),
                ),
                IconButton(
                  onPressed: () =>
                      _rejectOrDelete(admin['_id'], isDelete: true),
                  icon: const Icon(
                    LucideIcons.trash2,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildTechList(List<dynamic> techs) {
    if (techs.isEmpty) {
      return _buildEmptyState(
        LucideIcons.userPlus,
        "No pending technician apps",
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: techs.length,
      itemBuilder: (context, index) {
        final tech = techs[index];
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TechnicianDetailScreen(
                technicianId: tech['_id'],
                technicianData: tech,
              ),
            ),
          ).then((_) => _loadData()),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: tech['photoUrl'] != null && tech['photoUrl'].isNotEmpty
                      ? Image.network(
                          tech['photoUrl'],
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: 44,
                                height: 44,
                                color: Colors.orange.withValues(alpha: 0.1),
                                child: const Icon(
                                  LucideIcons.user,
                                  color: Colors.orange,
                                ),
                              ),
                        )
                      : Container(
                          width: 44,
                          height: 44,
                          color: Colors.orange.withValues(alpha: 0.1),
                          child: const Icon(
                            LucideIcons.user,
                            color: Colors.orange,
                          ),
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tech['name'] ?? 'Unknown',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        tech['email'] ?? '',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  LucideIcons.chevronRight,
                  size: 16,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpertiseRequestList(List<dynamic> requests) {
    if (requests.isEmpty) {
      return _buildEmptyState(
        LucideIcons.gitPullRequest,
        "No pending expertise requests",
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final req = requests[index];
        final tech = req['technicianId'] ?? {};
        final brandsCount = (req['brandExpertise'] as List?)?.length ?? 0;
        final issuesCount = (req['repairExpertise'] as List?)?.length ?? 0;

        return GestureDetector(
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ExpertiseRequestDetailScreen(request: req),
              ),
            );
            if (result == true) _loadData();
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.wrench,
                    color: Colors.purple,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tech['name'] ?? 'Unknown',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        "$brandsCount Brands, $issuesCount Skills Requested",
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  LucideIcons.chevronRight,
                  size: 16,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(IconData icon, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(message, style: GoogleFonts.inter(color: Colors.grey)),
        ],
      ),
    );
  }
}
