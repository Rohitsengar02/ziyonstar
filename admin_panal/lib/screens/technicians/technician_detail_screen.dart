import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_colors.dart';
import '../../services/api_service.dart';

class TechnicianDetailScreen extends StatefulWidget {
  final String technicianId;
  final Map<String, dynamic> technicianData;

  const TechnicianDetailScreen({
    super.key,
    required this.technicianId,
    required this.technicianData,
  });

  @override
  State<TechnicianDetailScreen> createState() => _TechnicianDetailScreenState();
}

class _TechnicianDetailScreenState extends State<TechnicianDetailScreen> {
  late Map<String, dynamic> _data;
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _data = widget.technicianData;
  }

  Future<void> _updateStatus(String status) async {
    setState(() => _isLoading = true);
    try {
      await _apiService.updateTechnician(_data['_id'], {'status': status});
      // Refresh local data
      setState(() {
        _data['status'] = status;
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Status updated to $status')));
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _deleteTechnician() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Technician?'),
        content: const Text('This action cannot be undone. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        await _apiService.deleteTechnician(_data['_id']);
        if (mounted) {
          Navigator.pop(context); // Go back to list
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Technician deleted')));
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
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final techName = _data['name'] ?? 'Unknown';
    final photoUrl = _data['photoUrl'] ?? '';
    final status = _data['status'] ?? 'pending';

    // final phone = _data['phone'] ?? 'N/A';

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: Text(
          'Technician Profile',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              // Reload logic if needed
            },
            icon: const Icon(LucideIcons.share2, size: 20),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildProfileHero(techName, photoUrl, status, _data),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEarningsCard(),
                  const SizedBox(height: 28),
                  _buildSectionHeader('Contact & Info'),
                  const SizedBox(height: 12),
                  _buildInfoCard(_data),
                  const SizedBox(height: 28),

                  _buildSectionHeader('Expertise & Skills'),
                  const SizedBox(height: 12),
                  _buildSkillsChips(_data['brandExpertise'] ?? []),
                  _buildRepairExpertise(
                    _data['repairExpertise'] ?? [],
                  ), // Added Repair Expertise
                  const SizedBox(height: 28),

                  _buildSectionHeader('Documents & KYC'),
                  const SizedBox(height: 12),
                  _buildKycStatusCard(_data),
                  const SizedBox(height: 28),

                  _buildSectionHeader('Service Area'),
                  const SizedBox(height: 12),
                  _buildLocationCard(_data),
                  const SizedBox(height: 28),

                  _buildSectionHeader('System Management'),
                  const SizedBox(height: 12),
                  _buildManagementButtons(status),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildActionStrip(status),
    );
  }

  Widget _buildProfileHero(
    String name,
    String photo,
    String status,
    Map<String, dynamic> data,
  ) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 30),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: ClipOval(
                  child: photo.isNotEmpty
                      ? Image.network(
                          photo,
                          width: 108,
                          height: 108,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.person, size: 50),
                        )
                      : const Icon(Icons.person, size: 50),
                ),
              ),
              if (status == 'approved')
                Positioned(
                  bottom: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.fromBorderSide(
                        BorderSide(color: Colors.white, width: 2),
                      ),
                    ),
                    child: const Icon(
                      LucideIcons.check,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            status.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 13,
              color: status == 'approved' ? Colors.green : Colors.orange,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          // Stats Row (Mock values if not available)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildMetric(
                '${data['brandExpertise']?.length ?? 0}',
                'Brands',
                LucideIcons.layers,
                Colors.blue,
              ),
              _buildDivider(),
              _buildMetric(
                '${data['jobs'] ?? 0}',
                'Jobs',
                LucideIcons.briefcase,
                Colors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String val, String label, IconData icon, Color color) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Text(
              val,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 20,
      width: 1,
      color: Colors.grey[200],
      margin: const EdgeInsets.symmetric(horizontal: 24),
    );
  }

  Widget _buildInfoCard(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildInfoRow(LucideIcons.mail, data['email'] ?? 'N/A'),
          const SizedBox(height: 12),

          _buildInfoRow(
            LucideIcons.calendar,
            'DOB: ${data['dob'] != null ? data['dob'].toString().split('T')[0] : 'N/A'}',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(LucideIcons.user, 'Gender: ${data['gender'] ?? 'N/A'}'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 12),
        Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildSkillsChips(List<dynamic> skills) {
    if (skills.isEmpty)
      return const Text("No specific brand expertise listed.");

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.8,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: skills.length,
      itemBuilder: (context, index) {
        final skill = skills[index];
        // Check if skill is object (from populate) or just ID/string
        if (skill is Map) {
          final imageUrl =
              skill['imageUrl'] ?? skill['image'] ?? skill['icon'] ?? '';
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (imageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl,
                      height: 40,
                      width: 40,
                      fit: BoxFit.contain,
                      errorBuilder: (c, e, s) =>
                          const Icon(LucideIcons.smartphone),
                    ),
                  )
                else
                  const Icon(
                    LucideIcons.smartphone,
                    size: 30,
                    color: Colors.grey,
                  ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Text(
                    skill['title'] ?? 'Unknown',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          return Chip(label: Text(skill.toString()));
        }
      },
    );
  }

  // Helper for Issue/Repair Expertise if separate field exists in data
  Widget _buildRepairExpertise(List<dynamic> repairs) {
    if (repairs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        _buildSectionHeader('Repair Expertise'),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.9, // Adjusted for image visibility
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: repairs.length,
          itemBuilder: (context, index) {
            final repair = repairs[index];
            if (repair is Map) {
              final imageUrl =
                  repair['imageUrl'] ?? repair['image'] ?? repair['icon'] ?? '';
              String name = repair['name'] ?? 'Issue';
              return Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (imageUrl.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrl,
                          height: 40,
                          width: 40,
                          fit: BoxFit.contain,
                          errorBuilder: (c, e, s) =>
                              const Icon(LucideIcons.wrench),
                        ),
                      )
                    else
                      const Icon(
                        LucideIcons.wrench,
                        size: 30,
                        color: Colors.blueAccent,
                      ),
                    const SizedBox(height: 8),
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Chip(label: Text(repair.toString()));
            }
          },
        ),
      ],
    );
  }

  Widget _buildKycStatusCard(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          _buildKycItem(
            'KYC Status',
            data['kycStatus'] ?? data['status'] ?? 'Pending',
            Colors.blue,
          ),
          const Divider(height: 32),
          _buildDocRow('Document Front', data['kycDocumentFront']),
          const SizedBox(height: 16),
          _buildDocRow('Document Back', data['kycDocumentBack']),
          const SizedBox(height: 16),
          _buildInfoRow(
            LucideIcons.creditCard,
            'Number: ${data['kycNumber'] ?? 'N/A'}',
          ),
        ],
      ),
    );
  }

  Widget _buildDocRow(String label, String? url) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        if (url != null && url.isNotEmpty)
          GestureDetector(
            onTap: () {
              // Open full image
              showDialog(
                context: context,
                builder: (_) => Dialog(child: Image.network(url)),
              );
            },
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(url),
                  fit: BoxFit.cover,
                ),
                border: Border.all(color: Colors.grey.shade200),
              ),
            ),
          )
        else
          Container(
            height: 50,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: const Text(
              'No Document Uploaded',
              style: TextStyle(color: Colors.grey),
            ),
          ),
      ],
    );
  }

  Widget _buildKycItem(String title, String status, Color color) {
    return Row(
      children: [
        const Icon(LucideIcons.fileText, size: 20, color: Colors.grey),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            status,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationCard(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(LucideIcons.map, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Primary Location',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      data['city'] ?? 'Unknown',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Bank Details Section
          const Divider(),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(LucideIcons.landmark, size: 18, color: Colors.grey),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bank Details',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${data['bankName'] ?? 'Bank N/A'} • ${data['accountNumber'] ?? '****'}',
                      style: GoogleFonts.inter(fontSize: 12),
                    ),
                    Text(
                      'IFSC: ${data['ifscCode'] ?? 'N/A'}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsCard() {
    // Determine earnings from data or default to 0
    // String earnings = _data['totalEarnings']?.toString() ?? '0'; // If backed has this
    String earnings = "1,42,800"; // Mock for UI match requested

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Earnings',
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '₹$earnings',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              // Navigate to ledger or show details
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: Text(
              'View Ledger',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagementButtons(String status) {
    return Column(
      children: [
        _buildManageBtn(
          LucideIcons.trash2,
          'Delete Technician',
          Colors.red,
          _deleteTechnician,
        ),
        const SizedBox(height: 12),
        if (status != 'approved')
          _buildManageBtn(
            LucideIcons.checkCircle,
            'Approve Technician',
            Colors.green,
            () => _updateStatus('approved'),
          ),
        if (status == 'approved')
          _buildManageBtn(
            LucideIcons.alertTriangle,
            'Suspend Technician',
            Colors.orange,
            () => _updateStatus('suspended'),
          ),
      ],
    );
  }

  Widget _buildManageBtn(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 16),
            Text(
              label,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: color,
              ),
            ),
            const Spacer(),
            Icon(
              LucideIcons.arrowRight,
              size: 16,
              color: color.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionStrip(String status) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF1F1F1))),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // Placeholder for assign task logic
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Assign Task feature coming soon'),
                  ),
                );
                // Or we could set status to 'busy'
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                'Assign Task',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
