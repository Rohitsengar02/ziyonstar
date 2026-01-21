import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme.dart';

class TechnicianProfilePage extends StatelessWidget {
  final Map<String, dynamic> technician;

  const TechnicianProfilePage({super.key, required this.technician});

  @override
  Widget build(BuildContext context) {
    // Extract expertise data
    final brandExpertise = technician['brandExpertise'] as List<dynamic>? ?? [];
    final repairExpertise =
        technician['repairExpertise'] as List<dynamic>? ?? [];
    final isOnline = technician['isOnline'] ?? false;
    final status = technician['status'] ?? 'pending';

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  technician['photoUrl'] != null &&
                          technician['photoUrl'].isNotEmpty
                      ? Image.network(
                          technician['photoUrl'],
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(
                            color: Colors.grey.shade200,
                            child: const Icon(LucideIcons.user, size: 60),
                          ),
                        )
                      : Image.asset(
                          'assets/images/tech_avatar_1.png',
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(
                            color: Colors.grey.shade200,
                            child: const Icon(LucideIcons.user, size: 60),
                          ),
                        ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                technician['name'] ?? 'Technician',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (status == 'approved' || status == 'active')
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: isOnline
                                      ? Colors.green
                                      : Colors.grey.shade600,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isOnline
                                          ? LucideIcons.zap
                                          : LucideIcons.clock,
                                      size: 12,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      isOnline ? 'ONLINE' : 'OFFLINE',
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: 10,
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
                              LucideIcons.star,
                              color: Colors.amber,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${technician['rating'] ?? '4.9'} • ${technician['completedJobs'] ?? '50+'} repairs completed',
                              style: GoogleFonts.inter(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            leading: IconButton(
              icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatRow(),
                  const SizedBox(height: 24),

                  // About Section
                  Text(
                    "About",
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    technician['bio'] ??
                        "Certified mobile repair specialist. Expert in screen replacements, battery issues, and motherboard diagnostics. Dedicated to providing quick and reliable service.",
                    style: GoogleFonts.inter(
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),

                  // Brand Expertise Section
                  if (brandExpertise.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      "Brand Expertise",
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: brandExpertise.length,
                        itemBuilder: (context, index) {
                          final brand = brandExpertise[index];
                          return Container(
                            width: 80,
                            margin: const EdgeInsets.only(right: 12),
                            child: Column(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    ),
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

                  // Repair Expertise Section
                  if (repairExpertise.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      "Repair Expertise",
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: repairExpertise.map<Widget>((repair) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryButton.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.primaryButton.withValues(
                                alpha: 0.3,
                              ),
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
                      }).toList(),
                    ),
                  ],

                  // Contact Info
                  const SizedBox(height: 24),
                  Text(
                    "Contact",
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildContactItem(
                    LucideIcons.mail,
                    technician['email'] ?? 'Not provided',
                  ),
                  if (technician['phone'] != null &&
                      technician['phone'].isNotEmpty)
                    _buildContactItem(LucideIcons.phone, technician['phone']),

                  const SizedBox(height: 24),
                  Text(
                    "Recent Reviews",
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildReview(
                    "John Doe",
                    "Fast and professional. Fixed my screen in 30 mins!",
                    5,
                  ),
                  _buildReview(
                    "Emily Clark",
                    "Great service, highly recommended.",
                    5,
                  ),
                  _buildReview(
                    "Michael Brown",
                    "Very knowledgeable technician.",
                    4,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context), // Just go back to select
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryButton,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            "Select This Technician",
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow() {
    final brandCount =
        (technician['brandExpertise'] as List<dynamic>?)?.length ?? 0;
    final repairCount =
        (technician['repairExpertise'] as List<dynamic>?)?.length ?? 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(technician['experience'] ?? "5+ Years", "Experience"),
        _buildStatItem("$brandCount", "Brands"),
        _buildStatItem("$repairCount", "Repairs"),
      ],
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryButton,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildContactItem(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Text(
            value,
            style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildReview(String user, String comment, int rating) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(user, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    LucideIcons.star,
                    size: 14,
                    color: index < rating ? Colors.amber : Colors.grey.shade300,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment,
            style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
