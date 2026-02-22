import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme.dart';
import '../widgets/mobile_bottom_nav.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MobileHomeScreen extends StatefulWidget {
  const MobileHomeScreen({super.key});

  @override
  State<MobileHomeScreen> createState() => _MobileHomeScreenState();
}

class _MobileHomeScreenState extends State<MobileHomeScreen> {
  int _currentBannerIndex = 0;
  final PageController _bannerController = PageController();
  Timer? _timer;
  String? _selectedBrand;
  String? _selectedModel;
  final ApiService _apiService = ApiService();
  List<dynamic> _apiIssues = [];
  List<dynamic> _apiBrands = [];
  List<dynamic> _apiModels = [];
  bool _isLoadingIssues = true;
  bool _isLoadingBrands = true;
  bool _isLoadingModels = false;
  int _notificationCount = 0; // Track unread notifications
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _defaultAddress;

  final List<Map<String, String>> _banners = [
    {
      'image': 'assets/images/issues/issue_screen.png',
      'title': 'Cracked Screen?',
      'subtitle': 'Expert screen replacement in 30 mins',
    },
    {
      'image': 'assets/images/issues/issue_battery.png',
      'title': 'Battery Draining Fast?',
      'subtitle': 'Get a brand new battery today',
    },
    {
      'image': 'assets/images/issues/issue_water.png',
      'title': 'Water Damage?',
      'subtitle': 'We fix liquid damaged devices',
    },
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_currentBannerIndex < _banners.length - 1) {
        _currentBannerIndex++;
      } else {
        _currentBannerIndex = 0;
      }

      if (_bannerController.hasClients) {
        _bannerController.animateToPage(
          _currentBannerIndex,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
    _fetchIssues();
    _fetchBrands();
    _loadNotificationCount();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? uid;
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        uid = user.uid;
      } else {
        uid = prefs.getString('user_uid') ?? prefs.getString('user_id');
      }

      if (uid != null) {
        final userData = await _apiService.getUser(uid);
        if (userData != null) {
          final addresses = await _apiService.getAddresses(userData['_id']);
          Map<String, dynamic>? defaultAddr;
          if (addresses.isNotEmpty) {
            defaultAddr = addresses.firstWhere(
              (a) => a['isDefault'] == true,
              orElse: () => addresses.first,
            );
          }
          if (mounted) {
            setState(() {
              _userData = userData;
              _defaultAddress = defaultAddr;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    }
  }

  Future<void> _loadNotificationCount() async {
    final count = await NotificationService.getUnseenCount();
    if (mounted) {
      setState(() => _notificationCount = count);
    }
  }

  Future<void> _fetchBrands() async {
    try {
      final brands = await _apiService.getBrands();
      if (mounted) {
        setState(() {
          _apiBrands = brands;
          _isLoadingBrands = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching brands: $e');
      if (mounted) setState(() => _isLoadingBrands = false);
    }
  }

  Future<void> _fetchModels(String brandId) async {
    setState(() => _isLoadingModels = true);
    try {
      final models = await _apiService.getModels(brandId);
      if (mounted) {
        setState(() {
          _apiModels = models;
          _isLoadingModels = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching models: $e');
      if (mounted) setState(() => _isLoadingModels = false);
    }
  }

  Future<void> _fetchIssues() async {
    try {
      final issues = await _apiService.getIssues();
      if (mounted) {
        setState(() {
          _apiIssues = issues;
          _isLoadingIssues = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching issues: $e');
      if (mounted) setState(() => _isLoadingIssues = false);
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

  @override
  void dispose() {
    _timer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  // Getter for 5 issues + More button
  List<Map<String, dynamic>> get _gridItems {
    final List<Map<String, dynamic>> items = [];

    if (_apiIssues.isNotEmpty) {
      items.addAll(
        _apiIssues
            .take(5)
            .map(
              (e) => {
                'type': 'issue',
                'name': e['name'],
                'image': _getIssueImagePath(
                  (e['name'] ?? '').toString(),
                  e['imageUrl']?.toString(),
                ),
                'icon': _getIcon(e['icon']),
              },
            ),
      );
    } else if (!_isLoadingIssues) {
      // Fallback or empty state handled in UI
    }

    items.add({
      'type': 'more',
      'name': 'View All',
      'icon': LucideIcons.layoutGrid,
      'image': null,
    });
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBannerCarousel(),
            const SizedBox(height: 24),
            _buildMenuGrid(),
            const SizedBox(height: 24),
            _buildDeviceSelector(),
            const SizedBox(height: 24),
            _buildSectionTitle('Brand Gallery'),
            const SizedBox(height: 16),
            _buildBrandGallery(),
            const SizedBox(height: 32),
            _buildSectionTitle('Exclusive Offers'),
            const SizedBox(height: 16),
            _buildOfferSection(),
            const SizedBox(height: 32),
            _buildStatsSection(),
            const SizedBox(height: 32),
            _buildSectionTitle('How It Works'),
            const SizedBox(height: 16),
            _buildHowItWorksCarousel(),
            const SizedBox(height: 32),
            _buildSectionTitle('Why Choose Us'),
            const SizedBox(height: 16),
            _buildWhyChooseUs(),
            const SizedBox(height: 32),
            _buildSectionTitle('Happy Clients'),
            const SizedBox(height: 16),
            _buildTestimonials(),
            const SizedBox(height: 100), // Spacing for bottom nav
          ],
        ),
      ),
      bottomNavigationBar: const MobileBottomNav(currentIndex: 0),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: 90,
      leadingWidth: 0,
      titleSpacing: 0,
      title: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            // Left: Address Pill
            GestureDetector(
              onTap: () async {
                final result = await context.push<bool>('/addresses');
                if (result == true) {
                  _fetchUserData();
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      LucideIcons.mapPin,
                      size: 14,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        _defaultAddress != null
                            ? (_defaultAddress!['label'] ?? 'Home')
                            : 'Home',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(
                      LucideIcons.chevronDown,
                      size: 12,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            // Center: Title
            Image.asset(
              'assets/images/app_logo.png',
              height: 80,
              fit: BoxFit.contain,
            ),
            const Spacer(),
            // Right: Icons
            GestureDetector(
              onTap: () async {
                await context.push('/notifications');
                _loadNotificationCount();
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(LucideIcons.bell, color: Colors.black, size: 24),
                  if (_notificationCount > 0)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                        child: Text(
                          _notificationCount > 9
                              ? '9+'
                              : _notificationCount.toString(),
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 7,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () {
                context.push('/profile').then((_) => _fetchUserData());
              },
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey[200],
                backgroundImage:
                    _userData != null &&
                        _userData!['photoUrl'] != null &&
                        _userData!['photoUrl'].toString().isNotEmpty
                    ? NetworkImage(_userData!['photoUrl'])
                    : const AssetImage('assets/images/tech_avatar_1.png')
                          as ImageProvider,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerCarousel() {
    return Column(
      children: [
        SizedBox(
          height: 250,
          child: PageView.builder(
            controller: _bannerController,
            onPageChanged: (index) =>
                setState(() => _currentBannerIndex = index),
            itemCount: _banners.length,
            itemBuilder: (context, index) {
              final banner = _banners[index]; // Use the defined _banners
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: AssetImage(banner['image'] ?? ''),
                    fit: BoxFit.cover,
                    onError: (e, s) {},
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Featured',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        banner['title'] ?? '',
                        style: GoogleFonts.poppins(
                          color: const Color.fromARGB(255, 78, 78, 78),
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        banner['subtitle'] ?? '',
                        style: GoogleFonts.inter(
                          color: const Color.fromARGB(221, 145, 145, 145),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // Dots Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_banners.length, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentBannerIndex == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentBannerIndex == index
                    ? AppColors.primaryButton
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }

  void _showDeviceSelectModal({String? initialIssue}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.only(top: 100),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: _buildDeviceSelector(initialIssue: initialIssue),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _gridItems.length,
      itemBuilder: (context, index) {
        final item = _gridItems[index];
        final isMore = item['type'] == 'more';

        return GestureDetector(
          onTap: () {
            _showDeviceSelectModal(initialIssue: isMore ? null : item['name'] as String);
          },
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: isMore
                        ? AppColors.primaryButton.withValues(alpha: 0.1)
                        : Colors.grey.shade100,
                    border: Border.all(
                      color: isMore
                          ? const Color.fromARGB(
                              255,
                              222,
                              222,
                              222,
                            ).withValues(alpha: 0.3)
                          : const Color.fromARGB(255, 246, 246, 246),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: isMore
                        ? Container(
                            color: const Color.fromARGB(
                              255,
                              243,
                              243,
                              243,
                            ), // Solid Primary Color
                            child: Center(
                              child: Icon(
                                item['icon'] as IconData,
                                color: const Color.fromARGB(
                                  255,
                                  161,
                                  161,
                                  161,
                                ), // White Icon
                                size: 32,
                              ),
                            ),
                          )
                        : (item['image'] != null &&
                              (item['image'] as String).isNotEmpty)
                        ? ((item['image'] as String).startsWith('http')
                              ? Image.network(
                                  item['image'] as String,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Center(
                                        child: Icon(
                                          item['icon'] as IconData,
                                          size: 40,
                                          color: Colors.blue.withValues(
                                            alpha: 0.5,
                                          ),
                                        ),
                                      ),
                                )
                              : Image.asset(
                                  (item['image'] as String).startsWith('assets')
                                      ? (item['image'] as String)
                                      : 'assets/images/issues/${item['image']}',
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Center(
                                        child: Icon(
                                          item['icon'] as IconData,
                                          size: 40,
                                          color: Colors.blue.withValues(
                                            alpha: 0.5,
                                          ),
                                        ),
                                      ),
                                ))
                        : Center(
                            child: Icon(
                              item['icon'] as IconData,
                              size: 40,
                              color: Colors.blue.withValues(alpha: 0.5),
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item['name'] as String,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: isMore
                      ? AppColors.primaryButton
                      : Colors.grey.shade800,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textHeading,
        ),
      ),
    );
  }

  Widget _buildDeviceSelector({String? initialIssue}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryButton.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  LucideIcons.smartphone,
                  color: AppColors.primaryButton,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Your Device',
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Get an instant repair quote',
                      style: GoogleFonts.inter(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Brand Dropdown
          _isLoadingBrands
              ? const Center(child: CircularProgressIndicator())
              : _buildDropdownField(
                  hint: 'Select Brand',
                  value: _selectedBrand,
                  items: _apiBrands
                      .map((b) => (b['title'] ?? '') as String)
                      .where((name) => name.isNotEmpty)
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      final brand = _apiBrands.firstWhere(
                        (b) => b['title'] == value,
                      );
                      setState(() {
                        _selectedBrand = value;
                        _selectedModel = null;
                        _apiModels = [];
                      });
                      _fetchModels(brand['_id']);
                    }
                  },
                ),
          const SizedBox(height: 16),
          _isLoadingModels
              ? const Center(child: CircularProgressIndicator())
              : _buildDropdownField(
                  hint: 'Select Model',
                  value: _selectedModel,
                  items: _apiModels
                      .map((m) => (m['name'] ?? '') as String)
                      .where((name) => name.isNotEmpty)
                      .toList(),
                  onChanged: (value) => setState(() => _selectedModel = value),
                  isEnabled: _selectedBrand != null,
                ),

          if (_selectedModel != null) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final extraMap = <String, dynamic>{
                    'initialBrand': _selectedBrand,
                    'initialModel': _selectedModel,
                  };
                  if (initialIssue != null) {
                    extraMap['initialIssue'] = initialIssue;
                  }
                  context.go('/repair', extra: extraMap);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryButton,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Get Instant Quote',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required String hint,
    required List<String> items,
    required Function(String?) onChanged,
    bool isEnabled = true,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50, // Light grey input
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hint,
            style: GoogleFonts.inter(color: Colors.grey.shade500, fontSize: 13),
          ),
          isExpanded: true,
          icon: Icon(
            LucideIcons.chevronDown,
            color: isEnabled ? Colors.grey.shade700 : Colors.grey.shade300,
            size: 20,
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade900,
                ),
              ),
            );
          }).toList(),
          onChanged: isEnabled ? onChanged : null,
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(16),
          style: GoogleFonts.inter(color: Colors.black, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildBrandGallery() {
    if (_isLoadingBrands) {
      return const SizedBox(
        height: 160,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return SizedBox(
      height: 160,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _apiBrands.length,
        itemBuilder: (context, index) {
          final brand = _apiBrands[index];
          final name = (brand['title'] ?? '') as String;
          final imagePath = 'assets/images/brand_${name.toLowerCase()}.png';

          return Container(
            width: 110,
            margin: const EdgeInsets.only(right: 12),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey.shade100,
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child:
                          (brand['imageUrl'] != null &&
                              brand['imageUrl'].isNotEmpty)
                          ? Image.network(
                              brand['imageUrl'],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) =>
                                  Center(
                                    child: Icon(
                                      LucideIcons.smartphone,
                                      size: 32,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                            )
                          : Image.asset(
                              imagePath,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) =>
                                  Center(
                                    child: Icon(
                                      LucideIcons.smartphone,
                                      size: 32,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOfferSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Opacity(
              opacity: 0.1,
              child: Icon(LucideIcons.zap, size: 150, color: Colors.white),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'LIMITED TIME',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Get 20% Off',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'On your first screen repair',
                        style: GoogleFonts.inter(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Claim',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF6366F1),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('5k+', 'Repairs'),
          Container(width: 1, height: 40, color: Colors.grey.shade200),
          _buildStatItem('4.8', 'Rating'),
          Container(width: 1, height: 40, color: Colors.grey.shade200),
          _buildStatItem('24h', 'Turnaround'),
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
            fontSize: 20,
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

  Widget _buildHowItWorksCarousel() {
    final List<Map<String, dynamic>> steps = [
      {
        'title': 'Select Device',
        'desc': 'Choose your model & issue',
        'icon': LucideIcons.smartphone,
      },
      {
        'title': 'Book Repair',
        'desc': 'We come to you or mail-in',
        'icon': LucideIcons.calendar,
      },
      {
        'title': 'Get Fixed',
        'desc': 'Expert repair in minutes',
        'icon': LucideIcons.hammer,
      },
    ];

    return SizedBox(
      height: 160,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: steps.length,
        itemBuilder: (context, index) {
          final step = steps[index];
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryButton.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    step['icon'] as IconData,
                    color: AppColors.primaryButton,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  step['title'] as String,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  step['desc'] as String,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWhyChooseUs() {
    final features = [
      {
        'icon': LucideIcons.shieldCheck,
        'title': 'Warranty',
        'desc': 'Lifetime warranty',
      },
      {'icon': LucideIcons.clock, 'title': 'Fast', 'desc': 'Under 30 mins'},
      {'icon': LucideIcons.award, 'title': 'Expert', 'desc': 'Certified techs'},
      {
        'icon': LucideIcons.dollarSign,
        'title': 'Best Price',
        'desc': 'Price match',
      },
    ];

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.0,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feat = features[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  feat['icon'] as IconData,
                  size: 20,
                  color: AppColors.primaryButton,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      feat['title'] as String,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      feat['desc'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTestimonials() {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            width: 280,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: const AssetImage(
                        'assets/images/tech_avatar_1.png',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'John Doe',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        Row(
                          children: List.generate(
                            5,
                            (i) => const Icon(
                              LucideIcons.star,
                              size: 10,
                              color: Colors.amber,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  "Amazing service! Fixed my phone screen in just 20 minutes. The technician was very professional.",
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getIssueImagePath(String issueName, String? existingImg) {
    if (existingImg != null && existingImg.isNotEmpty) return existingImg;

    final name = issueName.toLowerCase();
    if (name.contains('front camera')) {
      return 'assets/images/issues/issue_frontcamera.png';
    }
    if (name.contains('camera')) return 'issue_camera.png';
    if (name.contains('battery')) return 'issue_battery.png';
    if (name.contains('screen') || name.contains('display')) {
      return 'issue_screen.png';
    }
    if (name.contains('charging') ||
        name.contains('jack') ||
        name.contains('port')) {
      return 'issue_charging.png';
    }
    if (name.contains('mic')) return 'issue_mic.png';
    if (name.contains('receiver') || name.contains('ear speaker')) {
      return 'issue_speaker.png';
    }
    if (name.contains('speaker')) {
      return 'assets/images/issues/issue_speakerback.png';
    }
    if (name.contains('face id')) return 'issue_faceid.png';
    if (name.contains('water') || name.contains('liquid')) {
      return 'issue_water.png';
    }
    if (name.contains('software')) return 'issue_software.png';
    if (name.contains('motherboard') || name.contains('ic')) {
      return 'issue_motherboard.png';
    }
    if (name.contains('sensor')) return 'issue_sensors.png';
    if (name.contains('glass')) return 'issue_backglass.png';

    return '';
  }
}
