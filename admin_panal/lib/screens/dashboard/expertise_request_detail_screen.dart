import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../services/api_service.dart';

class ExpertiseRequestDetailScreen extends StatefulWidget {
  final Map<String, dynamic> request;
  const ExpertiseRequestDetailScreen({super.key, required this.request});

  @override
  State<ExpertiseRequestDetailScreen> createState() =>
      _ExpertiseRequestDetailScreenState();
}

class _ExpertiseRequestDetailScreenState
    extends State<ExpertiseRequestDetailScreen> {
  final ApiService _apiService = ApiService();
  bool _isProcessing = false;
  final TextEditingController _commentController = TextEditingController();

  Future<void> _updateStatus(String status) async {
    setState(() => _isProcessing = true);
    try {
      await _apiService.updateExpertiseRequestStatus(
        widget.request['_id'],
        status,
        adminComment: _commentController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Request $status')));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tech = widget.request['technicianId'] ?? {};
    final brands = widget.request['brandExpertise'] as List<dynamic>? ?? [];
    final repairs = widget.request['repairExpertise'] as List<dynamic>? ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Expertise Request Detail',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('Technician Info', [
              _buildInfoRow('Name', tech['name'] ?? 'N/A'),
              _buildInfoRow('Email', tech['email'] ?? 'N/A'),
            ]),
            const SizedBox(height: 24),
            if (brands.isNotEmpty) ...[
              _buildSectionTitle('Requested Brands'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: brands
                    .map((b) => _buildChip(b['title'] ?? 'Brand'))
                    .toList(),
              ),
              const SizedBox(height: 24),
            ],
            if (repairs.isNotEmpty) ...[
              _buildSectionTitle('Requested Repair Skills'),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: repairs.length,
                itemBuilder: (context, index) {
                  final r = repairs[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(LucideIcons.wrench, size: 18),
                    title: Text(
                      r['name'] ?? 'Repair',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      r['category'] ?? 'Category',
                      style: GoogleFonts.inter(fontSize: 12),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
            _buildSectionTitle('Admin Comment (Optional)'),
            const SizedBox(height: 12),
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Add a comment for the technician...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isProcessing
                        ? null
                        : () => _updateStatus('rejected'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isProcessing
                        ? null
                        : () => _updateStatus('approved'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Approve'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 13, color: Colors.grey),
          ),
          Text(
            value,
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label) {
    return Chip(
      label: Text(
        label,
        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      backgroundColor: Colors.grey[100],
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}
