import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../data/device_data.dart';
import '../theme.dart';
import 'profile_page.dart';
import 'mobile_repair_page.dart';
import '../widgets/mobile_bottom_nav.dart';

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
  }

  @override
  void dispose() {
    _timer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  // Getter for 5 issues + More button
  List<Map<String, dynamic>> get _gridItems {
    final issues = DeviceData.issueData.entries
        .take(5)
        .map(
          (e) => {
            'type': 'issue',
            'name': e.key,
            'image': e.value['image'],
            'icon': e.value['icon'],
          },
        )
        .toList();

    issues.add({
      'type': 'more',
      'name': 'View All',
      'icon': LucideIcons.layoutGrid,
      'image': null,
    });
    return issues;
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
      toolbarHeight: 80,
      leadingWidth: 0,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        LucideIcons.mapPin,
                        size: 14,
                        color: AppColors.primaryButton,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'NYC',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.black,
                        ),
                      ),
                      const Icon(
                        LucideIcons.chevronDown,
                        size: 12,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Text(
              'ZiyonStar',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w900,
                fontSize: 20,
                color: Colors.black,
                letterSpacing: -0.5,
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(
                      LucideIcons.bell,
                      color: Colors.black,
                      size: 24,
                    ),
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (c) => const ProfilePage()),
                      );
                    },
                    child: const CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.grey,
                      backgroundImage: AssetImage(
                        'assets/images/tech_avatar_1.png',
                      ),
                    ),
                  ),
                ],
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
                    image: AssetImage(banner['image']!),
                    fit: BoxFit.cover,
                    onError: (e, s) {},
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
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
                          color: AppColors.primaryButton,
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
                        banner['title']!,
                        style: GoogleFonts.poppins(
                          color: const Color.fromARGB(255, 78, 78, 78),
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        banner['subtitle']!,
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
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
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
            if (isMore) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (c) => const MobileRepairPage()),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (c) =>
                      MobileRepairPage(initialIssue: item['name'] as String),
                ),
              );
            }
          },
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: isMore
                        ? AppColors.primaryButton.withOpacity(0.1)
                        : Colors.grey[100],
                    border: Border.all(
                      color: isMore
                          ? const Color.fromARGB(
                              255,
                              222,
                              222,
                              222,
                            ).withOpacity(0.3)
                          : const Color.fromARGB(255, 246, 246, 246)!,
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
                        : Image.asset(
                            item['image'] as String,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) =>
                                Center(
                                  child: Icon(
                                    item['icon'] as IconData,
                                    size: 40,
                                    color: Colors.blue.withOpacity(0.5),
                                  ),
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
                  color: isMore ? AppColors.primaryButton : Colors.grey[800],
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

  Widget _buildDeviceSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryButton.withOpacity(0.1),
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
                        color: Colors.grey[600],
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
          _buildDropdown(
            value: _selectedBrand,
            hint: 'Select Brand',
            items: DeviceData.brands.map((b) => b['name'] as String).toList(),
            onChanged: (val) {
              setState(() {
                _selectedBrand = val;
                _selectedModel = null;
              });
            },
          ),
          const SizedBox(height: 16),

          // Model Dropdown
          _buildDropdown(
            value: _selectedModel,
            hint: 'Select Model',
            items: _selectedBrand == null
                ? []
                : (DeviceData.modelsByBrand[_selectedBrand] ?? []),
            isEnabled: _selectedBrand != null,
            onChanged: (val) {
              setState(() => _selectedModel = val);
            },
          ),

          if (_selectedModel != null) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (c) => MobileRepairPage(
                        initialBrand: _selectedBrand,
                        initialModel: _selectedModel,
                      ),
                    ),
                  );
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

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required Function(String?) onChanged,
    bool isEnabled = true,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50], // Light grey input
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hint,
            style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 13),
          ),
          isExpanded: true,
          icon: Icon(
            LucideIcons.chevronDown,
            color: isEnabled ? Colors.grey[700] : Colors.grey[300],
            size: 20,
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[900],
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
    return SizedBox(
      height: 160,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: DeviceData.brands.length,
        itemBuilder: (context, index) {
          final brand = DeviceData.brands[index];
          final name = brand['name'] as String;
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
                      color: Colors.grey[100],
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Icon(
                            brand['icon'] as IconData,
                            size: 32,
                            color: Colors.grey[400],
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
                    color: Colors.grey[800],
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
            color: const Color(0xFF6366F1).withOpacity(0.3),
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
                          color: Colors.white.withOpacity(0.2),
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
                          color: Colors.white.withOpacity(0.9),
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
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('5k+', 'Repairs'),
          Container(width: 1, height: 40, color: Colors.grey[200]),
          _buildStatItem('4.8', 'Rating'),
          Container(width: 1, height: 40, color: Colors.grey[200]),
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
          style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[500]),
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
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryButton.withOpacity(0.1),
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
                    color: Colors.grey[500],
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
            border: Border.all(color: Colors.grey[100]!),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
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
                        color: Colors.grey[500],
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
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.grey[200],
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
                    color: Colors.grey[600],
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
}
