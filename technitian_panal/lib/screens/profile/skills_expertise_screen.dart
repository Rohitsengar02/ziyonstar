import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme.dart';
import 'update_expertise_screen.dart';

class SkillsExpertiseScreen extends StatelessWidget {
  final Map<String, dynamic> technicianData;
  const SkillsExpertiseScreen({super.key, required this.technicianData});

  @override
  Widget build(BuildContext context) {
    final brands = (technicianData['brandExpertise'] as List<dynamic>?) ?? [];
    final repairs = (technicianData['repairExpertise'] as List<dynamic>?) ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Skills & Expertise',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Brand Expertise', brands.length),
            const SizedBox(height: 16),
            _buildBrandsGrid(brands),
            const SizedBox(height: 32),
            _buildSectionHeader('Repair Expertise', repairs.length),
            const SizedBox(height: 16),
            _buildRepairsList(repairs),
            const SizedBox(height: 40),
            _buildUpdateBanner(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$count Selected',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBrandsGrid(List<dynamic> brands) {
    if (brands.isEmpty) return _buildEmptyState('No brands selected');

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.9,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: brands.length,
      itemBuilder: (context, index) {
        final brand = brands[index];
        bool isMap = brand is Map;
        String title = isMap ? (brand['title'] ?? 'Brand') : 'Brand';
        String imageUrl = isMap ? (brand['imageUrl'] ?? '') : '';

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (imageUrl.isNotEmpty)
                Image.network(
                  imageUrl,
                  height: 40,
                  width: 40,
                  fit: BoxFit.contain,
                  errorBuilder: (c, e, s) =>
                      const Icon(LucideIcons.smartphone, color: Colors.grey),
                )
              else
                const Icon(
                  LucideIcons.smartphone,
                  color: Colors.grey,
                  size: 30,
                ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRepairsList(List<dynamic> repairs) {
    if (repairs.isEmpty) return _buildEmptyState('No repair skills listed');

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: repairs.length,
        separatorBuilder: (c, i) => Divider(height: 1, color: Colors.grey[200]),
        itemBuilder: (context, index) {
          final repair = repairs[index];
          String name = repair is Map ? (repair['name'] ?? 'Repair') : 'Repair';
          String cat = repair is Map
              ? (repair['category'] ?? 'Category')
              : 'Category';

          return ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.white,
              radius: 18,
              child: Icon(
                LucideIcons.wrench,
                size: 16,
                color: AppColors.primaryButton,
              ),
            ),
            title: Text(
              name,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              cat,
              style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String msg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        msg,
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(color: Colors.grey),
      ),
    );
  }

  Widget _buildUpdateBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(LucideIcons.info, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Want to update your expertise?',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'You can add more brands or skills by contacting our administrator team.',
            style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        UpdateExpertiseScreen(technicianData: technicianData),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white24),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Add More Skills / Brands'),
            ),
          ),
        ],
      ),
    );
  }
}
