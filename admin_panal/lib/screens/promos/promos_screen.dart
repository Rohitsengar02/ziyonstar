import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../services/api_service.dart';
import 'package:intl/intl.dart';

class PromosScreen extends StatefulWidget {
  const PromosScreen({super.key});

  @override
  State<PromosScreen> createState() => _PromosScreenState();
}

class _PromosScreenState extends State<PromosScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _promos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPromos();
  }

  Future<void> _loadPromos() async {
    try {
      final promos = await _apiService.getPromos();
      setState(() {
        _promos = promos;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading promos: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deletePromo(String id) async {
    try {
      await _apiService.deletePromo(id);
      _loadPromos();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Promo deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting promo: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: Text(
          'Promo Campaigns',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showAddPromoDialog(),
            icon: const Icon(LucideIcons.plusCircle, size: 22),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadPromos,
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _promos.length,
                itemBuilder: (context, index) {
                  return _buildPromoCard(_promos[index]);
                },
              ),
            ),
    );
  }

  Widget _buildPromoCard(dynamic promo) {
    final bool isExpired =
        promo['validUntil'] != null &&
        DateTime.parse(promo['validUntil']).isBefore(DateTime.now());
    final bool isActive = promo['isActive'] ?? true;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  promo['code'],
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          (isExpired || !isActive ? Colors.grey : Colors.green)
                              .withAlpha((0.1 * 255).toInt()),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isExpired
                          ? 'Expired'
                          : (!isActive ? 'Inactive' : 'Active'),
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: isExpired || !isActive
                            ? Colors.grey
                            : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(LucideIcons.trash2, size: 16),
                    onPressed: () => _deletePromo(promo['_id']),
                    color: Colors.red,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              promo['title'] ?? 'No Title',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          const Divider(height: 32),
          Row(
            children: [
              _buildMetric(
                LucideIcons.scissors,
                'Discount',
                promo['discountType'] == 'percentage'
                    ? '${promo['discountValue']}%'
                    : '₹${promo['discountValue']}',
              ),
              const Spacer(),
              _buildMetric(
                LucideIcons.users,
                'Usages',
                '${promo['usedCount']}/${promo['usageLimit'] ?? '∞'}',
              ),
              const Spacer(),
              _buildMetric(
                LucideIcons.calendar,
                'Expires',
                promo['validUntil'] != null
                    ? DateFormat(
                        'MMM dd, yyyy',
                      ).format(DateTime.parse(promo['validUntil']))
                    : 'Never',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(IconData icon, String label, String val) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.inter(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          val,
          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  void _showAddPromoDialog() {
    final formKey = GlobalKey<FormState>();
    final codeController = TextEditingController();
    final titleController = TextEditingController();
    final discountController = TextEditingController();
    final limitController = TextEditingController();
    final minOrderController = TextEditingController();
    String discountType = 'fixed'; // 'fixed' or 'percentage'
    DateTime? expiryDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    const SizedBox(height: 24),
                    Text(
                      'Create New Promo',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildTextField(
                      controller: codeController,
                      label: 'Promo Code',
                      hint: 'e.g. SUMMER2024',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: titleController,
                      label: 'Title',
                      hint: 'e.g. Summer Sale',
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Discount Type',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                initialValue: discountType,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'fixed',
                                    child: Text('Fixed (₹)'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'percentage',
                                    child: Text('Percentage (%)'),
                                  ),
                                ],
                                onChanged: (val) {
                                  setState(() => discountType = val!);
                                },
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: discountController,
                            label: 'Discount Value',
                            hint: 'e.g. 100 or 10',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: limitController,
                            label: 'Usage Limit',
                            hint: 'e.g. 500',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: minOrderController,
                            label: 'Min Order',
                            hint: 'e.g. 1000',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Expiry Date',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().add(
                            const Duration(days: 30),
                          ),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (picked != null) {
                          setState(() => expiryDate = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              expiryDate != null
                                  ? DateFormat(
                                      'MMM dd, yyyy',
                                    ).format(expiryDate!)
                                  : 'Select Date',
                              style: TextStyle(
                                color: expiryDate != null
                                    ? Colors.black
                                    : Colors.grey,
                              ),
                            ),
                            const Icon(LucideIcons.calendar, size: 20),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (codeController.text.isEmpty ||
                              titleController.text.isEmpty ||
                              discountController.text.isEmpty) {
                            // Basic validation
                            return;
                          }

                          final promoData = {
                            'code': codeController.text,
                            'title': titleController.text,
                            'description': '', // Optional
                            'discountType': discountType,
                            'discountValue':
                                int.tryParse(discountController.text) ?? 0,
                            'minOrderValue':
                                int.tryParse(minOrderController.text) ?? 0,
                            'usageLimit':
                                int.tryParse(limitController.text) ?? 0,
                            'validUntil': expiryDate?.toIso8601String(),
                          };

                          try {
                            await _apiService.createPromo(promoData);
                            if (context.mounted) {
                              Navigator.pop(context);
                              _loadPromos();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Promo created successfully'),
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Launch Campaign',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }
}
