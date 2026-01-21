import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme.dart';

class ServiceAreasScreen extends StatelessWidget {
  final Map<String, dynamic> technicianData;
  const ServiceAreasScreen({super.key, required this.technicianData});

  @override
  Widget build(BuildContext context) {
    final pincodes = (technicianData['coverageAreas'] as List<dynamic>?) ?? [];
    final serviceTypes =
        (technicianData['serviceTypes'] as List<dynamic>?) ?? [];
    final radius = technicianData['serviceAreaRadius'] ?? 'Not set';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Service Areas',
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
            _buildRadiusCard(radius),
            const SizedBox(height: 32),
            Text(
              'Coverage Areas (Pincodes)',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildPincodeList(pincodes),
            const SizedBox(height: 32),
            Text(
              'Service Types',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildServiceTypes(serviceTypes),
          ],
        ),
      ),
    );
  }

  Widget _buildRadiusCard(String radius) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryButton.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryButton.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.primaryButton,
            child: Icon(LucideIcons.map, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Maximum Distance',
                style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                '$radius Radius',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryButton,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPincodeList(List<dynamic> pincodes) {
    if (pincodes.isEmpty) return _buildEmptyState('No pincodes added');

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: pincodes.map((p) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.mapPin, size: 14, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                p.toString(),
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildServiceTypes(List<dynamic> types) {
    if (types.isEmpty) return _buildEmptyState('No service types specified');

    return Column(
      children: types.map((t) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  LucideIcons.checkCircle,
                  color: Colors.green,
                  size: 18,
                ),
                const SizedBox(width: 12),
                Text(
                  t.toString(),
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState(String msg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
}
