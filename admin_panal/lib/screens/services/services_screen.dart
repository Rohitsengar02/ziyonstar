import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/api_service.dart';
import 'package:flutter/foundation.dart';
import 'brand_detail_screen.dart'; // Import the new screen

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final ApiService _apiService = ApiService();
  int _selectedTabIndex = 0;
  List<dynamic> _brands = []; // Dynamic from API
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBrands();
    _loadIssues();
  }

  Future<void> _loadBrands() async {
    try {
      final fetchedBrands = await _apiService.getBrands();
      setState(() {
        _brands = fetchedBrands;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // Handle error cleanly or just show static data
    }
  }

  List<dynamic> _issues = [];

  // List of available icons for selection
  final List<Map<String, dynamic>> _availableIcons = [
    {'name': 'smartphone', 'icon': LucideIcons.smartphone},
    {'name': 'laptop', 'icon': LucideIcons.laptop},
    {'name': 'watch', 'icon': LucideIcons.watch},
    {'name': 'tablet', 'icon': LucideIcons.tablet},
    {'name': 'headphones', 'icon': LucideIcons.headphones},
    {'name': 'camera', 'icon': LucideIcons.camera},
    {'name': 'speaker', 'icon': LucideIcons.speaker},
    {'name': 'tv', 'icon': LucideIcons.tv},
    {'name': 'wifi', 'icon': LucideIcons.wifi},
    {'name': 'bluetooth', 'icon': LucideIcons.bluetooth},
    {'name': 'battery-charging', 'icon': LucideIcons.batteryCharging},
    {'name': 'cpu', 'icon': LucideIcons.cpu},
    {'name': 'database', 'icon': LucideIcons.database},
    {'name': 'hard-drive', 'icon': LucideIcons.hardDrive},
    {'name': 'keyboard', 'icon': LucideIcons.keyboard},
    {'name': 'monitor', 'icon': LucideIcons.monitor},
    {'name': 'mouse', 'icon': LucideIcons.mouse},
    {'name': 'printer', 'icon': LucideIcons.printer},
    {'name': 'radio', 'icon': LucideIcons.radio},
    {'name': 'server', 'icon': LucideIcons.server},
    {'name': 'settings', 'icon': LucideIcons.settings},
    {'name': 'shield', 'icon': LucideIcons.shield},
    {'name': 'zap', 'icon': LucideIcons.zap},
    {'name': 'activity', 'icon': LucideIcons.activity},
    {'name': 'alarm-clock', 'icon': LucideIcons.alarmClock},
    {'name': 'archive', 'icon': LucideIcons.archive},
    {'name': 'award', 'icon': LucideIcons.award},
    {'name': 'bell', 'icon': LucideIcons.bell},
    {'name': 'book', 'icon': LucideIcons.book},
    {'name': 'box', 'icon': LucideIcons.box},
    {'name': 'briefcase', 'icon': LucideIcons.briefcase},
    {'name': 'calendar', 'icon': LucideIcons.calendar},
    {'name': 'check-circle', 'icon': LucideIcons.checkCircle},
    {'name': 'circle', 'icon': LucideIcons.circle},
    {'name': 'clock', 'icon': LucideIcons.clock},
    {'name': 'cloud', 'icon': LucideIcons.cloud},
    {'name': 'code', 'icon': LucideIcons.code},
    {'name': 'compass', 'icon': LucideIcons.compass},
    {'name': 'copy', 'icon': LucideIcons.copy},
    {'name': 'credit-card', 'icon': LucideIcons.creditCard},
    {'name': 'download', 'icon': LucideIcons.download},
    {'name': 'eye', 'icon': LucideIcons.eye},
    {'name': 'file', 'icon': LucideIcons.file},
    {'name': 'flag', 'icon': LucideIcons.flag},
    {'name': 'folder', 'icon': LucideIcons.folder},
    {'name': 'gift', 'icon': LucideIcons.gift},
    {'name': 'globe', 'icon': LucideIcons.globe},
    {'name': 'heart', 'icon': LucideIcons.heart},
    {'name': 'home', 'icon': LucideIcons.home},
    {'name': 'image', 'icon': LucideIcons.image},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: Text(
          'Services & Pricing',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              if (_selectedTabIndex == 0) {
                _showAddBrandDialog();
              } else {
                _showAddIssueDialog();
              }
            },
            icon: const Icon(LucideIcons.plusCircle, size: 22),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTabSwitcher(),
          Expanded(
            child: IndexedStack(
              index: _selectedTabIndex,
              children: [_buildBrandsList(), _buildIssuesList()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSwitcher() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTabItem(0, 'Brands', LucideIcons.tag),
          _buildTabItem(1, 'Issues', LucideIcons.alertCircle),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String label, IconData icon) {
    bool isActive = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isActive ? Colors.white : Colors.grey),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.white : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_brands.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.box, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              "No brands added yet",
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            TextButton(
              onPressed: _showAddBrandDialog,
              child: Text(
                "Add your first brand",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBrands,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _brands.length,
        itemBuilder: (context, index) {
          final brand = _brands[index];
          // Safely handle nulls for string operations
          final brandName =
              brand['Name'] ?? brand['name'] ?? brand['title'] ?? 'Unknown';
          final brandDesc =
              brand['Description'] ?? brand['description'] ?? 'No description';
          final brandIcon = brand['Icon'] ?? brand['icon'] ?? 'smartphone';

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BrandDetailScreen(brand: brand),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: brand['imageUrl'] != null
                        ? Image.network(
                            brand['imageUrl'],
                            width: 24,
                            height: 24,
                            errorBuilder: (c, e, s) =>
                                const Icon(LucideIcons.image, size: 20),
                          )
                        : Icon(_getIconData(brandIcon), size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          brandName,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          brandDesc,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(LucideIcons.edit3, size: 18),
                    onPressed: () => _showAddBrandDialog(brand: brand),
                  ),
                  IconButton(
                    icon: const Icon(
                      LucideIcons.trash2,
                      size: 18,
                      color: Colors.red,
                    ),
                    onPressed: () => _confirmDelete(brand['_id'], 'brand'),
                  ),
                  const Icon(
                    LucideIcons.chevronRight,
                    size: 18,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper to map string name to IconData
  IconData _getIconData(String iconName) {
    if (_availableIcons.isEmpty) return LucideIcons.smartphone;
    final iconEntry = _availableIcons.firstWhere(
      (element) => element['name'] == iconName,
      orElse: () => {'icon': LucideIcons.smartphone},
    );
    return iconEntry['icon'] as IconData;
  }

  Future<void> _loadIssues() async {
    try {
      final fetchedIssues = await _apiService.getIssues();
      setState(() => _issues = fetchedIssues);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _confirmDelete(String id, String type) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete $type?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        if (type == 'brand') await _apiService.deleteBrand(id);
        if (type == 'issue') await _apiService.deleteIssue(id);

        if (type == 'brand') _loadBrands();
        if (type == 'issue') _loadIssues();

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$type deleted')));
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Widget _buildIssuesList() {
    if (_issues.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.alertCircle,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              "No issues configured",
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            TextButton(
              onPressed: () => _showAddIssueDialog(),
              child: Text(
                "Add your first issue",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadIssues,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _issues.length,
        itemBuilder: (context, index) {
          final issue = _issues[index];
          final issueIcon = issue['icon'] ?? 'wrench';
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: issue['imageUrl'] != null
                      ? Image.network(
                          issue['imageUrl'],
                          width: 24,
                          height: 24,
                          errorBuilder: (c, e, s) => Icon(
                            _getIconData(issueIcon),
                            size: 20,
                            color: Colors.red,
                          ),
                        )
                      : Icon(
                          _getIconData(issueIcon),
                          size: 20,
                          color: Colors.red,
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
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        issue['category'],
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '₹${issue['base_price']}',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(LucideIcons.edit3, size: 18),
                  onPressed: () => _showAddIssueDialog(issue: issue),
                ),
                IconButton(
                  icon: const Icon(
                    LucideIcons.trash2,
                    size: 18,
                    color: Colors.red,
                  ),
                  onPressed: () => _confirmDelete(issue['_id'], 'issue'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showAddIssueDialog({Map<String, dynamic>? issue}) async {
    final nameController = TextEditingController(text: issue?['name']);
    final catController = TextEditingController(text: issue?['category']);
    final priceController = TextEditingController(text: issue?['base_price']);
    String _selectedIcon = issue?['icon'] ?? 'wrench';
    XFile? _imageFile;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                issue == null ? 'Add New Issue' : 'Edit Issue',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Image Picker
                      GestureDetector(
                        onTap: () async {
                          final picker = ImagePicker();
                          final picked = await picker.pickImage(
                            source: ImageSource.gallery,
                          );
                          if (picked != null) {
                            setState(() => _imageFile = picked);
                          }
                        },
                        child: Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: _imageFile != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: FutureBuilder<Uint8List>(
                                    future: _imageFile!.readAsBytes(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData)
                                        return Image.memory(
                                          snapshot.data!,
                                          fit: BoxFit.cover,
                                        );
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    },
                                  ),
                                )
                              : (issue != null && issue['imageUrl'] != null)
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.network(
                                    issue['imageUrl'],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Center(
                                        child: Icon(
                                          LucideIcons.image,
                                          size: 40,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      LucideIcons.image,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                    Text(
                                      'Upload Issue Image',
                                      style: GoogleFonts.inter(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Icon Chooser
                      SizedBox(
                        height: 80,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _availableIcons.length,
                          itemBuilder: (context, index) {
                            final iconData = _availableIcons[index];
                            final isSelected =
                                _selectedIcon == iconData['name'];
                            return GestureDetector(
                              onTap: () => setState(
                                () => _selectedIcon = iconData['name'],
                              ),
                              child: Container(
                                margin: const EdgeInsets.only(right: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.black
                                      : Colors.grey.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  iconData['icon'],
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black54,
                                  size: 20,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildTextField(
                        nameController,
                        'Issue Name',
                        'e.g. Broken Screen',
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        catController,
                        'Category',
                        'e.g. Display',
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        priceController,
                        'Base Price',
                        'e.g. 500',
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty ||
                        priceController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Name and Price are required'),
                        ),
                      );
                      return;
                    }
                    try {
                      Navigator.pop(context);
                      if (issue == null) {
                        await _apiService.createIssue(
                          nameController.text,
                          catController.text,
                          priceController.text,
                          _selectedIcon,
                          _imageFile,
                        );
                      } else {
                        await _apiService.updateIssue(
                          issue['_id'],
                          nameController.text,
                          catController.text,
                          priceController.text,
                          _selectedIcon,
                          _imageFile,
                        );
                      }
                      _loadIssues();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            issue == null ? 'Issue added' : 'Issue updated',
                          ),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Error: $e')));
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
                    issue == null ? 'Save Issue' : 'Update Issue',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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

  Future<void> _showAddBrandDialog({Map<String, dynamic>? brand}) async {
    final titleController = TextEditingController(
      text: brand?['title'] ?? brand?['name'],
    );
    final descController = TextEditingController(text: brand?['description']);
    XFile? _imageFile;
    String _selectedIcon = brand?['icon'] ?? 'smartphone';

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                brand == null ? 'Add New Brand' : 'Edit Brand',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Picker (Removed as helper method to keep complexity down for now, or just use inline)
                      GestureDetector(
                        onTap: () async {
                          final picker = ImagePicker();
                          final picked = await picker.pickImage(
                            source: ImageSource.gallery,
                          );
                          if (picked != null) {
                            setState(() => _imageFile = picked);
                          }
                        },
                        child: Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: _imageFile != null
                              ? FutureBuilder<Uint8List>(
                                  future: _imageFile!.readAsBytes(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                            ConnectionState.done &&
                                        snapshot.data != null) {
                                      return ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Image.memory(
                                          snapshot.data!,
                                          fit: BoxFit.cover,
                                        ),
                                      );
                                    } else {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                  },
                                )
                              : (brand != null && brand['imageUrl'] != null)
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.network(
                                    brand['imageUrl'],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Center(
                                        child: Icon(
                                          LucideIcons.image,
                                          size: 40,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      LucideIcons.image,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Tap to upload image',
                                      style: GoogleFonts.inter(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Icon Selection Section
                      Text(
                        'Select Icon',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 200, // Fixed height for grid
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 5,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                              ),
                          itemCount: _availableIcons.length,
                          itemBuilder: (context, index) {
                            final iconData = _availableIcons[index];
                            final isSelected =
                                _selectedIcon == iconData['name'];
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedIcon = iconData['name'];
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.black
                                      : Colors.grey.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  iconData['icon'],
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black54,
                                  size: 20,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 16),
                      _buildTextField(
                        titleController,
                        'Brand Name',
                        'e.g. Apple',
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        descController,
                        'Description (Optional)',
                        'Short description',
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (titleController.text.isEmpty ||
                        (_imageFile == null && brand == null)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Name and Image are required'),
                        ),
                      );
                      return;
                    }
                    try {
                      Navigator.pop(context); // Close dialog first
                      if (brand == null) {
                        // Create
                        await _apiService.createBrand(
                          titleController.text,
                          descController.text,
                          _selectedIcon,
                          _imageFile!,
                        );
                      } else {
                        // Update
                        await _apiService.updateBrand(
                          brand['_id'],
                          titleController.text,
                          descController.text,
                          _selectedIcon,
                          _imageFile,
                        );
                      }

                      _loadBrands(); // Refresh list
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            brand == null
                                ? 'Brand added successfully'
                                : 'Brand updated successfully',
                          ),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Error: $e')));
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
                    brand == null ? 'Save Brand' : 'Update Brand',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint,
  ) {
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
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
