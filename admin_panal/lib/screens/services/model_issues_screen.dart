import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../services/api_service.dart';

class ModelIssuesScreen extends StatefulWidget {
  final Map<String, dynamic> model;

  const ModelIssuesScreen({super.key, required this.model});

  @override
  State<ModelIssuesScreen> createState() => _ModelIssuesScreenState();
}

class _ModelIssuesScreenState extends State<ModelIssuesScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<dynamic> _globalIssues = [];
  List<Map<String, dynamic>> _modelRepairPrices = [];
  final TextEditingController _basePriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _basePriceController.text = widget.model['price']?.toString() ?? '0';
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      // 1. Fetch all global issues
      final issues = await _apiService.getIssues();

      // 2. Initialize model's repair prices from the passed model object
      // We make a mutable copy to work with
      final List<dynamic> existingPrices = widget.model['repairPrices'] ?? [];

      setState(() {
        _globalIssues = issues;
        _modelRepairPrices = existingPrices
            .map((p) => Map<String, dynamic>.from(p))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      }
    }
  }

  Future<void> _syncToDatabase() async {
    setState(() => _isLoading = true);
    try {
      await _apiService.updateModel(
        widget.model['_id'],
        widget.model['name'],
        _basePriceController.text,
        repairPrices: _modelRepairPrices,
      );
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Database updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to sync to database: $e')),
        );
      }
    }
  }

  void _showEditPricingDialog(Map<String, dynamic> globalIssue) {
    // Find if this issue already exists in model's repair prices
    final existingIndex = _modelRepairPrices.indexWhere(
      (p) => p['issueName'] == globalIssue['name'],
    );

    final Map<String, dynamic>? existingData = existingIndex != -1
        ? _modelRepairPrices[existingIndex]
        : null;

    final priceController = TextEditingController(
      text: existingData != null
          ? existingData['price'].toString()
          : globalIssue['base_price'].toString(),
    );
    final originalPriceController = TextEditingController(
      text: existingData != null
          ? existingData['originalPrice'].toString()
          : '',
    );
    final discountController = TextEditingController(
      text: existingData != null ? existingData['discount'].toString() : '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Update Pricing for ${globalIssue['name']}',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _buildTextField(
                priceController,
                'Final Price (Sync to DB)',
                'e.g. 7844',
                TextInputType.number,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                originalPriceController,
                'Original Price',
                'e.g. 10600',
                TextInputType.number,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                discountController,
                'Discount Display',
                'e.g. 26%',
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final newPrice = int.tryParse(priceController.text) ?? 0;
                    final newOriginalPrice = int.tryParse(
                      originalPriceController.text,
                    );
                    final newDiscount = discountController.text;

                    setState(() {
                      final newData = {
                        'issueName': globalIssue['name'],
                        'price': newPrice,
                        'originalPrice': newOriginalPrice,
                        'discount': newDiscount,
                      };

                      if (existingIndex != -1) {
                        _modelRepairPrices[existingIndex] = newData;
                      } else {
                        _modelRepairPrices.add(newData);
                      }
                    });
                    Navigator.pop(context);
                    // Automatically trigger sync after updating an issue
                    _syncToDatabase();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Update Database Pricing',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint, [
    TextInputType? keyboardType,
  ]) {
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
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: Text(
          'Model Pricing: ${widget.model['name']}',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () =>
              Navigator.pop(context, true), // Pop to refresh parent
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Model Base Price Card
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Model Display Price',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'This is the default price shown in the model list.',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _basePriceController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                prefixText: '₹ ',
                                hintText: '0',
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: _syncToDatabase,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                            child: const Icon(LucideIcons.save, size: 20),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _globalIssues.length,
                    itemBuilder: (context, index) {
                      final issue = _globalIssues[index];
                      final existingData = _modelRepairPrices.firstWhere(
                        (p) => p['issueName'] == issue['name'],
                        orElse: () => {},
                      );

                      final bool isSet = existingData.isNotEmpty;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSet
                                ? Colors.blue.withOpacity(0.3)
                                : Colors.grey.shade100,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: (isSet ? Colors.blue : Colors.grey)
                                    .withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isSet ? LucideIcons.check : LucideIcons.circle,
                                size: 16,
                                color: isSet ? Colors.blue : Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    issue['name'],
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: isSet ? Colors.black : Colors.grey,
                                    ),
                                  ),
                                  if (isSet)
                                    Text(
                                      'Final: ₹${existingData['price']} | Orig: ₹${existingData['originalPrice'] ?? '-'} | ${existingData['discount'] ?? '0%'}',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    )
                                  else
                                    Text(
                                      'No specific pricing set (Base: ₹${issue['base_price']})',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                isSet
                                    ? LucideIcons.edit3
                                    : LucideIcons.plusCircle,
                                size: 20,
                                color: isSet ? Colors.black : Colors.blue,
                              ),
                              onPressed: () => _showEditPricingDialog(issue),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
