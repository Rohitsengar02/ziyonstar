import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TechnicianProfilePage extends StatefulWidget {
  final Map<String, dynamic> technician;

  const TechnicianProfilePage({super.key, required this.technician});

  @override
  State<TechnicianProfilePage> createState() => _TechnicianProfilePageState();
}

class _TechnicianProfilePageState extends State<TechnicianProfilePage> {
  final ApiService _apiService = ApiService();
  List<dynamic> _reviews = [];
  bool _isLoadingReviews = true;

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    final techId = widget.technician['_id'] ?? widget.technician['id'];
    if (techId != null) {
      final reviews = await _apiService.getTechnicianReviews(techId);
      if (mounted) {
        setState(() {
          _reviews = reviews.toList(); // Create modifiable list
          // Sort Decreasing order (Top reviews first)
          _reviews.sort((a, b) {
            int ratingA = a['rating'] ?? 0;
            int ratingB = b['rating'] ?? 0;
            return ratingB.compareTo(ratingA);
          });
          _isLoadingReviews = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoadingReviews = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extract expertise data
    final brandExpertise =
        widget.technician['brandExpertise'] as List<dynamic>? ?? [];
    final repairExpertise =
        widget.technician['repairExpertise'] as List<dynamic>? ?? [];
    final isOnline = widget.technician['isOnline'] ?? false;
    final status = widget.technician['status'] ?? 'pending';

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: AppColors.primaryButton,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  widget.technician['photoUrl'] != null &&
                          widget.technician['photoUrl'].toString().isNotEmpty
                      ? Image.network(
                          widget.technician['photoUrl'],
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
                          Colors.black.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 25,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.technician['name'] ?? 'Technician',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ).animate().fadeIn().slideX(begin: -0.2),
                            ),
                            if (status == 'approved' ||
                                status == 'active' ||
                                status == 'active')
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isOnline
                                      ? Colors.green
                                      : Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: isOnline
                                                ? Colors.white
                                                : Colors.grey,
                                            shape: BoxShape.circle,
                                          ),
                                        )
                                        .animate(
                                          onPlay: (c) =>
                                              isOnline ? c.repeat() : c.stop(),
                                        )
                                        .scale(
                                          begin: Offset(1, 1),
                                          end: Offset(1.5, 1.5),
                                          duration: 1000.ms,
                                        )
                                        .fade(duration: 1000.ms),
                                    const SizedBox(width: 6),
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
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(
                              LucideIcons.star,
                              color: Colors.amber,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.technician['averageRating'] ?? '0.0'} • ${widget.technician['totalReviews'] ?? 0} reviews',
                              style: GoogleFonts.inter(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              LucideIcons.mapPin,
                              color: Colors.white.withOpacity(0.7),
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.technician['city'] ?? "USA",
                              style: GoogleFonts.inter(
                                color: Colors.white.withOpacity(0.7),
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
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatRow(),
                    const SizedBox(height: 32),

                    // About Section
                    Text(
                      "About Professional",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textHeading,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.technician['bio'] ??
                          "Certified mobile repair specialist. Expert in screen replacements, battery issues, and motherboard diagnostics. Dedicated to providing quick and reliable service.",
                      style: GoogleFonts.inter(
                        color: Colors.grey[600],
                        height: 1.6,
                        fontSize: 15,
                      ),
                    ),

                    // Brand Expertise Section
                    if (brandExpertise.isNotEmpty) ...[
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Brand Expertise",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textHeading,
                            ),
                          ),
                          Text(
                            "${brandExpertise.length} Brands",
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.primaryButton,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 110,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: brandExpertise.length,
                          itemBuilder: (context, index) {
                            final brand = brandExpertise[index];
                            return Container(
                              width: 90,
                              margin: const EdgeInsets.only(right: 16),
                              child:
                                  Column(
                                        children: [
                                          Container(
                                            width: 70,
                                            height: 70,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.05),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                              border: Border.all(
                                                color: Colors.grey.shade100,
                                              ),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  12,
                                                ),
                                                child: brand['imageUrl'] != null
                                                    ? Image.network(
                                                        brand['imageUrl'],
                                                        fit: BoxFit.contain,
                                                        errorBuilder:
                                                            (
                                                              c,
                                                              e,
                                                              s,
                                                            ) => const Icon(
                                                              LucideIcons
                                                                  .smartphone,
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                      )
                                                    : const Icon(
                                                        LucideIcons.smartphone,
                                                        color: Colors.grey,
                                                      ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            brand['title'] ??
                                                brand['name'] ??
                                                '',
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textHeading,
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      )
                                      .animate()
                                      .fadeIn(delay: (index * 100).ms)
                                      .slideX(begin: 0.2),
                            );
                          },
                        ),
                      ),
                    ],

                    // Repair Expertise Section
                    if (repairExpertise.isNotEmpty) ...[
                      const SizedBox(height: 32),
                      Text(
                        "Skills & Services",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textHeading,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: repairExpertise.map<Widget>((repair) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryButton.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: AppColors.primaryButton.withOpacity(
                                  0.15,
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
                                const SizedBox(width: 8),
                                Text(
                                  repair['name'] ?? '',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryButton,
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn().scale();
                        }).toList(),
                      ),
                    ],

                    // Contact Info
                    const SizedBox(height: 32),
                    Text(
                      "Business Contact",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textHeading,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildContactCard(),

                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Verified Reviews",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textHeading,
                          ),
                        ),
                        if (!_isLoadingReviews && _reviews.isNotEmpty)
                          Text(
                            "See All",
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.primaryButton,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _isLoadingReviews
                        ? const Center(child: CircularProgressIndicator())
                        : _reviews.isEmpty
                        ? _buildEmptyReviews()
                        : Column(
                            children: _reviews.take(5).map((review) {
                              return _buildReviewItem(review);
                            }).toList(),
                          ),
                    const SizedBox(height: 40),
                  ],
                ),
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
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  LucideIcons.messageSquare,
                  color: AppColors.primaryButton,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryButton,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    shadowColor: AppColors.primaryButton.withOpacity(0.4),
                  ),
                  child: Text(
                    "Confirm Selection",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
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

  Widget _buildStatRow() {
    final brandCount =
        (widget.technician['brandExpertise'] as List<dynamic>?)?.length ?? 0;
    final repairCount =
        (widget.technician['repairExpertise'] as List<dynamic>?)?.length ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.grey.shade50),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            widget.technician['experience'] ?? "5+ Yrs",
            "Experience",
          ),
          Container(width: 1, height: 30, color: Colors.grey.shade200),
          _buildStatItem("$brandCount", "Brands"),
          Container(width: 1, height: 30, color: Colors.grey.shade200),
          _buildStatItem("$repairCount", "Skills"),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryButton,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade500),
        ),
      ],
    );
  }

  Widget _buildContactCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          _buildContactItem(
            LucideIcons.mail,
            widget.technician['email'] ?? 'Not provided',
            "Business Email",
            null,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          _buildContactItem(
            LucideIcons.phone,
            widget.technician['phone'] ?? 'Not provided',
            "Support Line",
            () async {
              if (widget.technician['phone'] != null) {
                final Uri url = Uri.parse('tel:${widget.technician['phone']}');
                if (await canLaunchUrl(url)) await launchUrl(url);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(
    IconData icon,
    String value,
    String label,
    VoidCallback? onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: AppColors.primaryButton),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textHeading,
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null)
            const Icon(LucideIcons.chevronRight, size: 16, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildReviewItem(Map<String, dynamic> review) {
    final user = review['userId'] ?? {};
    final rating = review['rating'] ?? 5;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
                radius: 18,
                backgroundColor: Colors.grey.shade100,
                backgroundImage: user['photoUrl'] != null
                    ? NetworkImage(user['photoUrl'])
                    : null,
                child: user['photoUrl'] == null
                    ? const Icon(LucideIcons.user, size: 14, color: Colors.grey)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user['name'] ?? 'Anonymous User',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.textHeading,
                      ),
                    ),
                    Text(
                      'Verified customer',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    LucideIcons.star,
                    size: 14,
                    color: index < rating ? Colors.amber : Colors.grey.shade200,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review['reviewText'] ?? "No comment provided.",
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildEmptyReviews() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            LucideIcons.messageSquare,
            size: 40,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            "No reviews yet",
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
            ),
          ),
          Text(
            "Be the first to review this specialist!",
            style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade400),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
