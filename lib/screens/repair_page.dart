import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme.dart';
import '../responsive.dart';
import 'technician_selection_period.dart';
import '../widgets/navbar.dart';
import '../widgets/footer.dart';
import '../widgets/app_drawer.dart';
import '../services/api_service.dart';

class RepairPage extends StatefulWidget {
  final String deviceBrand;
  final String deviceModel;

  const RepairPage({
    super.key,
    this.deviceBrand = 'Apple',
    this.deviceModel = 'iPhone 13 Pro',
  });

  @override
  State<RepairPage> createState() => _RepairPageState();
}

class _RepairPageState extends State<RepairPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late String _currentBrand;
  late String _currentModel;
  final Set<String> _selectedIssues = {};
  final ApiService _apiService = ApiService();
  List<dynamic> _apiIssues = [];
  List<dynamic> _apiBrands = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentBrand = widget.deviceBrand;
    _currentModel = widget.deviceModel;
    _fetchIssues();
    _fetchBrands();
  }

  Future<void> _fetchBrands() async {
    try {
      final brands = await _apiService.getBrands();
      if (mounted) {
        setState(() {
          _apiBrands = brands;
        });
      }
    } catch (e) {
      debugPrint('Error fetching brands: $e');
    }
  }

  Future<void> _fetchIssues() async {
    try {
      final issues = await _apiService.getIssues();
      if (mounted) {
        setState(() {
          _apiIssues = issues;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching issues: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  IconData _getIcon(String? iconName) {
    switch (iconName) {
      case 'smartphone':
        return LucideIcons.smartphone;
      case 'battery':
        return LucideIcons.battery;
      case 'plug':
        return LucideIcons.plug;
      case 'camera':
        return LucideIcons.camera;
      case 'speaker':
        return LucideIcons.speaker;
      case 'cpu':
        return LucideIcons.cpu;
      case 'droplet':
        return LucideIcons.droplet;
      case 'scanFace':
        return LucideIcons.scanFace;
      case 'hardDrive':
        return LucideIcons.hardDrive;
      case 'wrench':
        return LucideIcons.wrench;
      case 'mic':
        return LucideIcons.mic;
      default:
        return LucideIcons.wrench;
    }
  }

  String _repairOption = 'Doorstep';

  void _showChangeModelDialog() {
    final bool isDesktop = ResponsiveLayout.isDesktop(context);
    String tempBrand = _currentBrand;
    String tempModel = _currentModel;

    Widget buildContent(StateSetter setStateDialog) {
      // Local state for the dialog to handle model fetching
      List<dynamic> models = [];
      bool isLoadingModels = false;

      Future<void> fetchModelsForBrand(String brandName) async {
        final brand = _apiBrands.firstWhere(
          (b) => b['title'] == brandName,
          orElse: () => null,
        );
        if (brand == null) return;

        setStateDialog(() => isLoadingModels = true);
        try {
          final fetchedModels = await _apiService.getModels(brand['_id']);
          setStateDialog(() {
            models = fetchedModels;
            isLoadingModels = false;
            if (models.isNotEmpty) {
              tempModel = models.first['name'];
            } else {
              tempModel = 'No Models';
            }
          });
        } catch (e) {
          debugPrint('Error fetching models: $e');
          setStateDialog(() => isLoadingModels = false);
        }
      }

      return Container(
        padding: const EdgeInsets.all(24),
        width: isDesktop ? 400 : double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Device',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textHeading,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(LucideIcons.x),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Brand Selection
            Text(
              'Brand',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColors.textHeading,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _apiBrands.any((b) => (b['title'] ?? '') == tempBrand)
                      ? tempBrand
                      : null,
                  hint: const Text('Select Brand'),
                  isExpanded: true,
                  items: _apiBrands
                      .map((brand) {
                        final name = (brand['title'] ?? '') as String;
                        if (name.isEmpty) return null;
                        return DropdownMenuItem<String>(
                          value: name,
                          child: Row(
                            children: [
                              Icon(LucideIcons.smartphone, size: 20),
                              const SizedBox(width: 12),
                              Text(name),
                            ],
                          ),
                        );
                      })
                      .whereType<DropdownMenuItem<String>>()
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setStateDialog(() {
                        tempBrand = value;
                      });
                      fetchModelsForBrand(value);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Model Selection
            Text(
              'Model',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColors.textHeading,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: isLoadingModels
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      )
                    : DropdownButton<String>(
                        value: models.any((m) => (m['name'] ?? '') == tempModel)
                            ? tempModel
                            : null,
                        hint: const Text('Select Model'),
                        isExpanded: true,
                        items: models
                            .map((model) {
                              final name = (model['name'] ?? '') as String;
                              if (name.isEmpty) return null;
                              return DropdownMenuItem<String>(
                                value: name,
                                child: Text(name),
                              );
                            })
                            .whereType<DropdownMenuItem<String>>()
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setStateDialog(() {
                              tempModel = value;
                            });
                          }
                        },
                      ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _currentBrand = tempBrand;
                    _currentModel = tempModel;
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryButton,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Update Device',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (isDesktop) {
      showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: buildContent(setStateDialog),
            );
          },
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) => StatefulBuilder(
          builder: (context, setStateDialog) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: buildContent(setStateDialog),
            );
          },
        ),
      );
    }
  }

  // Mock Data with Images

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveLayout.isDesktop(context);
    final double padding = isDesktop ? 80.0 : 20.0;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF9FAFB),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, const Color(0xFFF3F4F6)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: padding,
                  vertical: 20,
                ),
                child: Navbar(scaffoldKey: _scaffoldKey),
              ),
            ),

            // Device Header Section
            _buildDeviceHeader(isDesktop, padding),

            // Main Content
            Padding(
              padding: EdgeInsets.symmetric(horizontal: padding, vertical: 40),
              child: isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Column: Issues & Details
                        Expanded(flex: 3, child: _buildLeftColumn()),
                        const SizedBox(width: 40),
                        // Right Column: Summary & Checkout
                        Expanded(flex: 2, child: _buildRightColumn()),
                      ],
                    )
                  : Column(
                      children: [
                        _buildLeftColumn(),
                        const SizedBox(height: 40),
                        _buildRightColumn(),
                      ],
                    ),
            ),

            // Trust Badges Section
            _buildTrustSection(isDesktop, padding),

            const Footer(),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceHeader(bool isDesktop, double padding) {
    if (!isDesktop) {
      return Container(
        width: double.infinity,
        color: Colors.white,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    LucideIcons.smartphone,
                    size: 24,
                    color: AppColors.textHeading,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$_currentBrand $_currentModel',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textHeading,
                        ),
                      ),
                      Text(
                        '128GB • Graphite',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textBody,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _showChangeModelDialog,
                icon: const Icon(LucideIcons.refreshCw, size: 16),
                label: const Text('Change Model'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryButton,
                  side: const BorderSide(color: AppColors.primaryButton),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  LucideIcons.smartphone,
                  size: 32,
                  color: AppColors.textHeading,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$_currentBrand $_currentModel',
                    style: GoogleFonts.inter(
                      fontSize: 24, // Desktop font size
                      fontWeight: FontWeight.bold,
                      color: AppColors.textHeading,
                    ),
                  ),
                  Text(
                    '128GB • Graphite',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textBody,
                    ),
                  ),
                ],
              ),
            ],
          ),
          TextButton.icon(
            onPressed: _showChangeModelDialog,
            icon: const Icon(LucideIcons.refreshCw, size: 16),
            label: const Text('Change Model'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryButton,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('What\'s wrong with your device?'),
        const SizedBox(height: 24),
        _buildIssuesGrid(),
        const SizedBox(height: 40),
        _buildOfferSection(),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildIssuesGrid() {
    final bool isDesktop = ResponsiveLayout.isDesktop(context);
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_apiIssues.isEmpty) {
      return const Center(child: Text('No repair issues found in database'));
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 4 : 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: _apiIssues.length,
      itemBuilder: (context, index) {
        final item = _apiIssues[index];
        final key = item['name'] as String;
        final isSelected = _selectedIssues.contains(key);

        // Map API data to what _IssueCard expects (wrapped in a map for legacy compatibility if needed)
        final data = {
          'icon': _getIcon(item['icon']),
          'imageUrl': item['imageUrl'],
          'price': item['base_price'],
          'warranty': '6 Months', // Default
          'time': '45 mins', // Default
        };

        return _IssueCard(
          title: key,
          data: data,
          isSelected: isSelected,
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedIssues.remove(key);
              } else {
                _selectedIssues.add(key);
              }
            });
            if (!isSelected) _showIssueDetails(key, data);
          },
        );
      },
    );
  }

  Widget _buildRightColumn() {
    return Column(
      children: [
        // Checkout Card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(5),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Booking Summary',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textHeading,
                ),
              ),
              const SizedBox(height: 24),

              // Selected Issues List
              if (_selectedIssues.isEmpty)
                Text(
                  'No issues selected',
                  style: GoogleFonts.inter(color: Colors.grey),
                )
              else
                ..._selectedIssues.map((issue) {
                  final item = _apiIssues.firstWhere((i) => i['name'] == issue);
                  final data = {
                    'imageUrl': item['imageUrl'],
                    'price': item['base_price'],
                    'warranty': '6 Months',
                    'time': '45 mins',
                  };
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade100),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image
                        Container(
                          width: 50,
                          height: 50,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child:
                              (item['imageUrl'] != null &&
                                  item['imageUrl'].isNotEmpty)
                              ? Image.network(
                                  item['imageUrl'],
                                  fit: BoxFit.contain,
                                )
                              : Icon(_getIcon(item['icon']), size: 24),
                        ),
                        const SizedBox(width: 12),
                        // Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                issue,
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textHeading,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${data['warranty']} Warranty • ${data['time']}',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Price
                        Text(
                          '₹${data['price']}',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryButton,
                          ),
                        ),
                      ],
                    ),
                  );
                }),

              const Divider(height: 32),

              // Repair Options
              Text(
                'Repair Mode',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: ['Doorstep', 'Pickup', 'Walk-in'].map((mode) {
                        final isSelected = _repairOption == mode;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _repairOption = mode),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withAlpha(10),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Text(
                                mode,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? AppColors.textHeading
                                      : Colors.grey[600],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),
              // Availability
              Row(
                children: [
                  const Icon(LucideIcons.clock, size: 16, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    'Earliest Slot: Today, 4:00 PM',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const Divider(height: 32),

              // Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount',
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '₹${_calculateTotal()}',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryButton,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedIssues.isNotEmpty
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TechnicianSelectionScreen(
                                deviceName: '$_currentBrand $_currentModel',
                                selectedIssues: _selectedIssues.toList(),
                                totalPrice: _calculateTotal().toDouble(),
                                repairMode: _repairOption,
                              ),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryButton,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Proceed to Schedule',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),
        _buildFAQSection(),
        const SizedBox(height: 24),
        // Support Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFDBEAFE)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.headphones,
                  color: AppColors.primaryButton,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Need Help?',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E40AF),
                    ),
                  ),
                  Text(
                    'Talk to our expert now',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF3B82F6),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              TextButton(onPressed: () {}, child: const Text('Call Now')),
            ],
          ),
        ),
      ],
    );
  }

  void _showIssueDetails(String title, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 140,
                  width: 140,
                  margin: const EdgeInsets.only(bottom: 24),
                  child:
                      (data['imageUrl'] != null && data['imageUrl'].isNotEmpty)
                      ? Image.network(data['imageUrl'], fit: BoxFit.contain)
                      : Icon(data['icon'], size: 80, color: Colors.grey),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textHeading,
                        ),
                      ),
                      Text(
                        '₹${data['price']}',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryButton,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryButton.withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      data['icon'] as IconData,
                      color: AppColors.primaryButton,
                      size: 28,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Common Symptoms:',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (data['symptoms'] as List)
                    .map(
                      (s) => Chip(
                        label: Text(s as String),
                        backgroundColor: Colors.grey[100],
                        labelStyle: GoogleFonts.inter(fontSize: 12),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _detailItem(LucideIcons.clock, 'Time', data['time']),
                  _detailItem(
                    LucideIcons.shieldCheck,
                    'Warranty',
                    data['warranty'],
                  ),
                  _detailItem(LucideIcons.badgeCheck, 'Parts', 'Original'),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryButton,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Add Issue'),
                ),
              ),
              const SizedBox(height: 20), // Extra padding for safe area
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
        Text(
          value,
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildOfferSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFFFFF7ED), const Color(0xFFFFEDD5)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.percent, color: Color(0xFFEA580C)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Special Offer Unlocked!',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF9A3412),
                  ),
                ),
                Text(
                  'Get ₹200 OFF on Screen Replacement today.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFFC2410C),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withAlpha(40),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Part (Purple)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(20),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        LucideIcons.helpCircle,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'SUPPORT',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Frequently Asked Questions',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Everything you need to know about our services.',
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          // Content Part (White Card inside)
          Container(
            margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                _buildFAQItem(
                  'What if my phone is water damaged?',
                  'We perform a diagnostic first. If it\'s repairable, we proceed. No fix, no fee.',
                ),
                _buildFAQItem(
                  'Will my data be safe?',
                  'Yes, we follow strict data privacy protocols. However, we recommend a backup.',
                ),
                _buildFAQItem(
                  'Are the parts original?',
                  'We use high-quality OEM equivalent or original parts with warranty.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String q, String a) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            q,
            style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            a,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.grey.shade100),
        ],
      ),
    );
  }

  Widget _buildTrustSection(bool isDesktop, double padding) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 40),
      child: Wrap(
        spacing: 40,
        runSpacing: 40,
        alignment: WrapAlignment.center,
        children: [
          _buildTrustBadge(
            LucideIcons.award,
            'Certified Techs',
            'Expertly trained',
          ),
          _buildTrustBadge(
            LucideIcons.shieldCheck,
            'Warranty',
            'Up to 6 months',
          ),
          _buildTrustBadge(
            LucideIcons.badgeCheck,
            'Original Parts',
            'Quality guaranteed',
          ),
          _buildTrustBadge(LucideIcons.lock, 'Data Privacy', '100% Secure'),
        ],
      ),
    );
  }

  Widget _buildTrustBadge(IconData icon, String title, String sub) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryButton.withAlpha(10),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primaryButton, size: 24),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            Text(
              sub,
              style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: _buildSectionTitleStyle());
  }

  TextStyle _buildSectionTitleStyle() {
    return GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: AppColors.textHeading,
    );
  }

  int _calculateTotal() {
    int total = 0;
    for (var issueName in _selectedIssues) {
      final item = _apiIssues.firstWhere(
        (i) => i['name'] == issueName,
        orElse: () => null,
      );
      if (item != null) {
        total += int.tryParse(item['base_price'].toString()) ?? 0;
      }
    }
    return total;
  }
}

class _IssueCard extends StatefulWidget {
  final String title;
  final Map<String, dynamic> data;
  final bool isSelected;
  final VoidCallback onTap;

  const _IssueCard({
    required this.title,
    required this.data,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_IssueCard> createState() => _IssueCardState();
}

class _IssueCardState extends State<_IssueCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.diagonal3Values(
            _isHovering || widget.isSelected ? 1.05 : 1.0,
            _isHovering || widget.isSelected ? 1.05 : 1.0,
            1.0,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isSelected
                  ? AppColors.primaryButton
                  : (_isHovering
                        ? AppColors.primaryButton.withValues(alpha: 0.5)
                        : Colors.transparent),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.isSelected
                    ? AppColors.primaryButton.withAlpha(30)
                    : (_isHovering
                          ? Colors.black.withAlpha(20)
                          : Colors.black.withAlpha(10)),
                blurRadius: _isHovering ? 20 : 12,
                offset: const Offset(0, 8),
              ),
            ],
            image: DecorationImage(
              image: AssetImage(widget.data['image']),
              fit: BoxFit.contain, // Show full 3D icon
              alignment: const Alignment(
                0,
                -0.3,
              ), // Shift up slightly to leave room for text
              opacity: 1.0,
            ),
          ),
          child: Stack(
            children: [
              // Gradient overly at bottom to ensure text readability
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(18),
                      bottomRight: Radius.circular(18),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.0),
                        Colors.white.withValues(alpha: 0.9),
                        Colors.white,
                      ],
                    ),
                  ),
                ),
              ),
              // Text Content
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.title,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.textHeading,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        '₹${widget.data['price']}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.primaryButton,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Check Icon
              if (widget.isSelected)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryButton,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 4),
                      ],
                    ),
                    child: const Icon(
                      LucideIcons.check,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
