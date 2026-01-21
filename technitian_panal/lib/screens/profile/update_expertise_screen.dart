import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../services/api_service.dart';
import '../../theme.dart';

class UpdateExpertiseScreen extends StatefulWidget {
  final Map<String, dynamic> technicianData;
  const UpdateExpertiseScreen({super.key, required this.technicianData});

  @override
  State<UpdateExpertiseScreen> createState() => _UpdateExpertiseScreenState();
}

class _UpdateExpertiseScreenState extends State<UpdateExpertiseScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  late TabController _tabController;

  List<dynamic> _allBrands = [];
  List<dynamic> _allIssues = [];

  final Set<String> _selectedBrandIds = {};
  final Set<String> _selectedIssueIds = {};

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Initialize already selected expertise (to avoid re-requesting them)
    final existingBrands =
        widget.technicianData['brandExpertise'] as List<dynamic>? ?? [];
    for (var b in existingBrands) {
      if (b is Map)
        _selectedBrandIds.add(b['_id']);
      else if (b is String)
        _selectedBrandIds.add(b);
    }

    final existingIssues =
        widget.technicianData['repairExpertise'] as List<dynamic>? ?? [];
    for (var i in existingIssues) {
      if (i is Map)
        _selectedIssueIds.add(i['_id']);
      else if (i is String)
        _selectedIssueIds.add(i);
    }

    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final brands = await _apiService.getBrands();
      final issues = await _apiService.getIssues();
      if (mounted) {
        setState(() {
          _allBrands = brands;
          _allIssues = issues;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitRequest() async {
    // We only care about NEW brands/issues that are NOT already in technicianData
    final existingBrandIds =
        (widget.technicianData['brandExpertise'] as List<dynamic>? ?? [])
            .map((e) => e is Map ? e['_id'] as String : e as String)
            .toSet();
    final existingIssueIds =
        (widget.technicianData['repairExpertise'] as List<dynamic>? ?? [])
            .map((e) => e is Map ? e['_id'] as String : e as String)
            .toSet();

    final newBrands = _selectedBrandIds.difference(existingBrandIds).toList();
    final newIssues = _selectedIssueIds.difference(existingIssueIds).toList();

    if (newBrands.isEmpty && newIssues.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select new brands or issues to request'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await _apiService.submitExpertiseRequest(
        technicianId: widget.technicianData['_id'],
        brandExpertise: newBrands,
        repairExpertise: newIssues,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request submitted to admin for approval'),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to submit request: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Add More Expertise',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          indicatorColor: AppColors.primaryButton,
          tabs: const [
            Tab(text: 'Brands'),
            Tab(text: 'Repair Issues'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildBrandsGrid(), _buildIssuesGrid()],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24),
        child: ElevatedButton(
          onPressed: _isSaving ? null : _submitRequest,
          child: _isSaving
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text('Submit Request'),
        ),
      ),
    );
  }

  Widget _buildBrandsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 24,
        childAspectRatio: 0.8,
      ),
      itemCount: _allBrands.length,
      itemBuilder: (context, index) {
        final brand = _allBrands[index];
        final id = brand['_id'] as String;
        final isSelected = _selectedBrandIds.contains(id);
        final isAlreadyExpert =
            (widget.technicianData['brandExpertise'] as List<dynamic>? ?? [])
                .any((e) => (e is Map ? e['_id'] : e) == id);

        return GestureDetector(
          onTap: isAlreadyExpert
              ? null
              : () {
                  setState(() {
                    if (isSelected)
                      _selectedBrandIds.remove(id);
                    else
                      _selectedBrandIds.add(id);
                  });
                },
          child: Opacity(
            opacity: isAlreadyExpert ? 0.5 : 1.0,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.grey.shade200,
                        width: isSelected ? 2 : 1.5,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Image.network(
                              brand['imageUrl'] ?? '',
                              fit: BoxFit.contain,
                              errorBuilder: (c, e, s) =>
                                  const Icon(Icons.broken_image),
                            ),
                          ),
                        ),
                        if (isSelected || isAlreadyExpert)
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Icon(
                              isAlreadyExpert
                                  ? LucideIcons.checkCircle
                                  : LucideIcons.circleDot,
                              color: isAlreadyExpert
                                  ? Colors.green
                                  : Colors.black,
                              size: 24,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  brand['title'] ?? '',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIssuesGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 24,
        childAspectRatio: 0.8,
      ),
      itemCount: _allIssues.length,
      itemBuilder: (context, index) {
        final issue = _allIssues[index];
        final id = issue['_id'] as String;
        final isSelected = _selectedIssueIds.contains(id);
        final isAlreadyExpert =
            (widget.technicianData['repairExpertise'] as List<dynamic>? ?? [])
                .any((e) => (e is Map ? e['_id'] : e) == id);

        return GestureDetector(
          onTap: isAlreadyExpert
              ? null
              : () {
                  setState(() {
                    if (isSelected)
                      _selectedIssueIds.remove(id);
                    else
                      _selectedIssueIds.add(id);
                  });
                },
          child: Opacity(
            opacity: isAlreadyExpert ? 0.5 : 1.0,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.grey.shade200,
                        width: isSelected ? 2 : 1.5,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child:
                                issue['imageUrl'] != null &&
                                    issue['imageUrl'].isNotEmpty
                                ? Image.network(
                                    issue['imageUrl'],
                                    fit: BoxFit.contain,
                                  )
                                : const Icon(
                                    LucideIcons.wrench,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                          ),
                        ),
                        if (isSelected || isAlreadyExpert)
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Icon(
                              isAlreadyExpert
                                  ? LucideIcons.checkCircle
                                  : LucideIcons.circleDot,
                              color: isAlreadyExpert
                                  ? Colors.green
                                  : Colors.black,
                              size: 24,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  issue['name'] ?? '',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                ),
                Text(
                  issue['category'] ?? '',
                  style: GoogleFonts.inter(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
