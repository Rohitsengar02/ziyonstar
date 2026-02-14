import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme.dart';
import '../../responsive.dart';

class KycDocumentsScreen extends StatelessWidget {
  final Map<String, dynamic> technicianData;
  const KycDocumentsScreen({super.key, required this.technicianData});

  @override
  Widget build(BuildContext context) {
    final status = technicianData['status'] ?? 'pending';
    final kycType = technicianData['kycType'] ?? 'Not Provided';
    final kycNumber = technicianData['kycNumber'] ?? 'Not Provided';
    final frontImg = technicianData['kycDocumentFront'];
    final backImg = technicianData['kycDocumentBack'];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'KYC Documents',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Responsive(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusCard(status),
              const SizedBox(height: 32),
              _buildInfoRow('Document Type', kycType, LucideIcons.fileText),
              const SizedBox(height: 16),
              _buildInfoRow(
                'Document Number',
                kycNumber,
                LucideIcons.creditCard,
              ),
              const SizedBox(height: 32),
              Text(
                'Uploaded Images',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildImageCard('Front Side', frontImg),
              const SizedBox(height: 20),
              _buildImageCard('Back Side', backImg),
              const SizedBox(height: 40),
              if (status == 'rejected')
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to re-upload or contact support
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryButton,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Resubmit Documents',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(String status) {
    Color color = Colors.orange;
    IconData icon = LucideIcons.clock;
    String text = 'Verification Pending';

    if (status == 'approved' || status == 'active') {
      color = Colors.green;
      icon = LucideIcons.checkCircle;
      text = 'Verified';
    } else if (status == 'rejected') {
      color = Colors.red;
      icon = LucideIcons.alertCircle;
      text = 'Rejected';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: color,
                  ),
                ),
                Text(
                  'Last updated on today',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: color.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageCard(String label, String? url) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: url != null && url.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    url,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => const Center(
                      child: Icon(
                        LucideIcons.image,
                        size: 40,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                )
              : const Center(
                  child: Icon(LucideIcons.image, size: 40, color: Colors.grey),
                ),
        ),
      ],
    );
  }
}
