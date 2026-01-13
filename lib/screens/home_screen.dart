import 'dart:ui';
import 'dart:async';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:ziyonstar/theme.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ziyonstar/responsive.dart';

import 'package:ziyonstar/widgets/navbar.dart';
import 'package:ziyonstar/widgets/footer.dart';
import 'package:ziyonstar/widgets/app_drawer.dart';
import 'package:ziyonstar/screens/mobile_home_screen.dart';

import 'package:ziyonstar/screens/repair_page.dart';

// Scroll-triggered animation wrapper for cards
class FadeInScaleCard extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;

  const FadeInScaleCard({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  State<FadeInScaleCard> createState() => _FadeInScaleCardState();
}

class _FadeInScaleCardState extends State<FadeInScaleCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Start animation after delay
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(opacity: _opacityAnimation.value, child: child),
        );
      },
      child: widget.child,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _showPreloader = true;

  @override
  Widget build(BuildContext context) {
    // Show Mobile Design on small screens
    if (ResponsiveLayout.isMobile(context)) {
      return const MobileHomeScreen();
    }

    return Stack(
      children: [
        Scaffold(
          key: _scaffoldKey,
          drawer: const AppDrawer(),
          body: SingleChildScrollView(
            child: Column(
              children: [
                _HeroSection(scaffoldKey: _scaffoldKey),
                _HorizontalSearchSection(),
                _StatsBar(),
                _CarouselSection(),
                _BrandSelectionSection(),
                _RepairCategoriesSection(),
                _InstantQuoteSection(),
                _RepairProcessSection(),
                _WarrantySection(),
                _TestimonialsSection(),
                _DeliveryOptionsSection(),
                const Footer(),
              ],
            ),
          ),
        ),
        if (_showPreloader)
          _Preloader(
            onComplete: () {
              setState(() {
                _showPreloader = false;
              });
            },
          ),
      ],
    );
  }
}

class _HeroSection extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const _HeroSection({required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveLayout.isDesktop(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final double horizontalPadding = isDesktop ? screenWidth * 0.08 : 20;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            const Color(0xFFF9FAFB),
            const Color(0xFFF3F4F6),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: isDesktop ? 20 : 16,
            ),
            child: Navbar(scaffoldKey: scaffoldKey),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              isDesktop ? 60 : 30,
              horizontalPadding,
              isDesktop ? 80 : 50,
            ),
            child: isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(flex: 5, child: _TextContent()),
                      const SizedBox(width: 60),
                      Expanded(flex: 6, child: _VisualContent()),
                    ],
                  )
                : Column(
                    children: [
                      _TextContent(),
                      const SizedBox(height: 40),
                      _VisualContent(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _TextContent extends StatelessWidget {
  const _TextContent();

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveLayout.isDesktop(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: isDesktop
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        // Badge
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 16 : 12,
            vertical: isDesktop ? 8 : 6,
          ),
          decoration: BoxDecoration(
            color: AppColors.accentRed.withAlpha(25),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppColors.accentRed.withAlpha(50)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                LucideIcons.flame,
                size: isDesktop ? 16 : 14,
                color: AppColors.accentRed,
              ),
              SizedBox(width: isDesktop ? 8 : 6),
              Text(
                'Top Rated Platform 2026',
                style: GoogleFonts.inter(
                  fontSize: isDesktop ? 12 : 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accentRed,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.1, end: 0),
        SizedBox(height: isDesktop ? 24 : 16),
        // Heading with responsive font size
        RichText(
          textAlign: isDesktop ? TextAlign.left : TextAlign.center,
          text: TextSpan(
            style: GoogleFonts.inter(
              fontSize: isDesktop ? 56 : (screenWidth < 360 ? 28 : 32),
              fontWeight: FontWeight.bold,
              color: AppColors.textHeading,
              height: 1.2,
            ),
            children: [
              if (isDesktop)
                const WidgetSpan(
                  child: Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(
                        'https://i.pravatar.cc/150?u=a042581f4e29026024d',
                      ),
                    ),
                  ),
                  alignment: PlaceholderAlignment.middle,
                ),
              const TextSpan(text: 'Selling '),
              TextSpan(
                text: 'Old\n${isDesktop ? "Things " : ""}',
                style: const TextStyle(color: AppColors.accentRed),
              ),
              TextSpan(text: '${isDesktop ? "" : "Things "}becomes\n'),
              TextSpan(text: '${isDesktop ? "——— " : ""}More Fun '),
              if (isDesktop)
                WidgetSpan(
                  child:
                      Icon(Icons.sunny, color: AppColors.accentYellow, size: 50)
                          .animate(onPlay: (controller) => controller.repeat())
                          .rotate(duration: 10.seconds),
                  alignment: PlaceholderAlignment.middle,
                ),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
        SizedBox(height: isDesktop ? 32 : 20),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isDesktop ? 500 : double.infinity,
          ),
          child: Text(
            'We ensure the best price for your used gadgets. Simple, fast, and secure process to sell or repair your devices.',
            textAlign: isDesktop ? TextAlign.left : TextAlign.center,
            style: TextStyle(
              fontSize: isDesktop ? 16 : 14,
              color: AppColors.textBody,
              height: 1.6,
            ),
          ),
        ).animate().fadeIn(delay: 400.ms),
        SizedBox(height: isDesktop ? 24 : 20),

        SizedBox(height: isDesktop ? 40 : 30),
        Row(
          mainAxisAlignment: isDesktop
              ? MainAxisAlignment.start
              : MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryButton,
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 32 : 24,
                  vertical: isDesktop ? 16 : 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'Sell Now',
                style: TextStyle(
                  fontSize: isDesktop ? 16 : 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ).animate().scale(
              delay: 800.ms,
              duration: 400.ms,
              curve: Curves.easeOutBack,
            ),
            SizedBox(width: isDesktop ? 32 : 16),
            TextButton(
              onPressed: () {},
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Browse Services',
                    style: TextStyle(
                      color: AppColors.textHeading,
                      fontWeight: FontWeight.bold,
                      fontSize: isDesktop ? 16 : 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    LucideIcons.arrowRight,
                    color: AppColors.textHeading,
                    size: isDesktop ? 20 : 18,
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 1000.ms),
          ],
        ),
      ],
    );
  }
}

class _BenefitItem extends StatelessWidget {
  final String text;
  final int delay;

  const _BenefitItem({required this.text, required this.delay});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(LucideIcons.checkCircle, color: Colors.green, size: 18),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ],
    ).animate().fadeIn(delay: delay.ms).slideX(begin: -0.2, end: 0);
  }
}

class _VisualContent extends StatelessWidget {
  const _VisualContent();

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveLayout.isDesktop(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      height: isDesktop ? 600 : (screenWidth < 360 ? 350 : 400),
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Animated Background Blobs
          if (isDesktop)
            Positioned(
              top: 50,
              left: 50,
              child:
                  Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.orange.withAlpha(20),
                          shape: BoxShape.circle,
                        ),
                      )
                      .animate(
                        onPlay: (controller) =>
                            controller.repeat(reverse: true),
                      )
                      .scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1.2, 1.2),
                        duration: 3.seconds,
                      ),
            ),
          Positioned(
            bottom: 100,
            right: 150,
            child:
                Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.purple.withAlpha(20),
                        shape: BoxShape.circle,
                      ),
                    )
                    .animate(
                      onPlay: (controller) => controller.repeat(reverse: true),
                    )
                    .scale(
                      begin: const Offset(1.1, 1.1),
                      end: const Offset(0.9, 0.9),
                      duration: 4.seconds,
                    ),
          ),

          // Background Shape
          Positioned(
            right: 0,
            bottom: 0,
            left: 100,
            top: 40,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF3F4F6),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(60),
                  bottomLeft: Radius.circular(60),
                  topRight: Radius.circular(200),
                  bottomRight: Radius.circular(60),
                ),
              ),
            ).animate().fadeIn(duration: 800.ms),
          ),

          // Main Image (Hand holding phone)
          Image.asset(
                'assets/images/hero_user.png',
                height: 650,
                fit: BoxFit.contain,
              )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .moveY(
                begin: 0,
                end: -10,
                duration: 8.seconds,
                curve: Curves.easeInOut,
              )
              .animate() // One-time entrance animation
              .fadeIn(duration: 1500.ms, curve: Curves.easeOut)
              .slideY(
                begin: 0.2, // Start from 20% down
                end: 0,
                duration: 1500.ms,
                curve: Curves.easeOut,
              ),

          // Floating Cards with Hover Effect
          Positioned(
            top: 100,
            right: 40,
            child:
                _FloatingCard(
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              'https://images.unsplash.com/photo-1550009158-9ebf69173e03?w=100',
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Video Guide',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                'How to sell?',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                    .animate(
                      onPlay: (controller) => controller.repeat(reverse: true),
                    )
                    .moveY(
                      begin: 0,
                      end: -15,
                      duration: 3.5.seconds,
                      delay: 1.seconds,
                    ),
          ),

          Positioned(
            bottom: 120,
            left: 0,
            child:
                Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryButton,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(50),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(51),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              LucideIcons.check,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Device Verified',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Due in 2 days',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            LucideIcons.arrowRight,
                            color: Colors.white,
                            size: 16,
                          ),
                        ],
                      ),
                    )
                    .animate(
                      onPlay: (controller) => controller.repeat(reverse: true),
                    )
                    .moveY(
                      begin: 0,
                      end: 10,
                      duration: 4.seconds,
                      delay: 0.5.seconds,
                    ),
          ),

          Positioned(
            bottom: 60,
            right: 0,
            child:
                _FloatingCard(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              LucideIcons.wallet,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Total Value',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                              Row(
                                children: const [
                                  Text(
                                    '\$1,250',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 40,
                                  ), // Spacer for progress bar visual
                                ],
                              ),
                              const SizedBox(height: 4),
                              Container(
                                width: 100,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.orange.withAlpha(51),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                    .animate(
                      onPlay: (controller) => controller.repeat(reverse: true),
                    )
                    .moveY(
                      begin: 0,
                      end: -12,
                      duration: 3.seconds,
                      delay: 1.5.seconds,
                    ),
          ),
        ],
      ),
    );
  }
}

class _FloatingCard extends StatelessWidget {
  final Widget child;
  const _FloatingCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

// Horizontal Search Section
class _HorizontalSearchSection extends StatelessWidget {
  const _HorizontalSearchSection();

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveLayout.isDesktop(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final double horizontalPadding = isDesktop ? screenWidth * 0.08 : 20;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        left: horizontalPadding,
        right: horizontalPadding,
        top: 0,
        bottom: isDesktop ? 60 : 40,
      ),
      child: const _DeviceSearchWidget(),
    ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.1, end: 0);
  }
}

class _StatsBar extends StatelessWidget {
  const _StatsBar();

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveLayout.isDesktop(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final double padding = isDesktop ? screenWidth * 0.08 : 20;

    final stats = [
      {
        'icon': LucideIcons.smartphone,
        'number': '100k+',
        'label': 'Devices Sold',
      },
      {
        'icon': LucideIcons.smile,
        'number': '500k+',
        'label': 'Happy Customers',
      },
      {
        'icon': LucideIcons.shieldCheck,
        'number': '10k+',
        'label': 'Verified Partners',
      },
      {'icon': LucideIcons.mapPin, 'number': '50+', 'label': 'Cities Covered'},
      {'icon': LucideIcons.timer, 'number': '24h', 'label': 'Fast Payout'},
    ];

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.darkSection,
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: padding,
        vertical: isDesktop ? 60 : 40,
      ),
      child: isDesktop
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (int i = 0; i < stats.length; i++) ...[
                  Expanded(
                    child: _statItem(
                      stats[i]['icon'] as IconData,
                      stats[i]['number'] as String,
                      stats[i]['label'] as String,
                      isDesktop: isDesktop,
                      delay: i * 100,
                    ),
                  ),
                  if (i < stats.length - 1) _divider(),
                ],
              ],
            )
          : Wrap(
              spacing: 16,
              runSpacing: 24,
              alignment: WrapAlignment.center,
              children: [
                for (int i = 0; i < stats.length; i++)
                  SizedBox(
                    width: screenWidth < 400
                        ? (screenWidth - 40 - 16) /
                              2 // 2 columns on very small screens
                        : (screenWidth - 40 - 32) /
                              3, // 3 columns on larger mobile
                    child: _statItem(
                      stats[i]['icon'] as IconData,
                      stats[i]['number'] as String,
                      stats[i]['label'] as String,
                      isDesktop: isDesktop,
                      delay: i * 100,
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _divider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.white.withAlpha(25),
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _statItem(
    IconData icon,
    String number,
    String label, {
    required bool isDesktop,
    required int delay,
  }) {
    return FadeInScaleCard(
      delay: Duration(milliseconds: delay + 400),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(isDesktop ? 12 : 10),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(25),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withAlpha(10)),
            ),
            child: Icon(
              icon,
              color: AppColors.accentYellow,
              size: isDesktop ? 28 : 24,
            ),
          ),
          SizedBox(height: isDesktop ? 16 : 12),
          Text(
            number,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: isDesktop ? 28 : 24,
              fontWeight: FontWeight.bold,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: isDesktop ? 13 : 11,
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _RepairCategoriesSection extends StatefulWidget {
  const _RepairCategoriesSection();

  @override
  State<_RepairCategoriesSection> createState() =>
      _RepairCategoriesSectionState();
}

class _RepairCategoriesSectionState extends State<_RepairCategoriesSection> {
  final ScrollController _scrollController = ScrollController();
  Timer? _timer;
  bool _isUserScrolling = false;

  final List<Map<String, dynamic>> categories = [
    {
      'icon': LucideIcons.smartphone,
      'label': 'Screen Repair',
      'desc': 'Cracked screen replacement',
      'color': Color(0xFF8B5CF6), // Violet
    },
    {
      'icon': LucideIcons.battery,
      'label': 'Battery Change',
      'desc': 'New battery installation',
      'color': Color(0xFFEC4899), // Pink
    },
    {
      'icon': LucideIcons.plug,
      'label': 'Charging Port',
      'desc': 'Fix connection issues',
      'color': Color(0xFF3B82F6), // Blue
    },
    {
      'icon': LucideIcons.camera,
      'label': 'Camera Repair',
      'desc': 'Lens and sensor fix',
      'color': Color(0xFF10B981), // Green
    },
    {
      'icon': LucideIcons.smartphone,
      'label': 'Back Glass',
      'desc': 'Rear housing replacement',
      'color': Color(0xFFF59E0B), // Amber
    },
    {
      'icon': LucideIcons.speaker,
      'label': 'Speaker / Mic',
      'desc': 'Audio component repair',
      'color': Color(0xFF06B6D4), // Cyan
    },
    {
      'icon': LucideIcons.cpu,
      'label': 'Motherboard',
      'desc': 'Chip level diagnosis',
      'color': Color(0xFF6366F1), // Indigo
    },
    {
      'icon': LucideIcons.droplet,
      'label': 'Water Damage',
      'desc': 'Liquid damage treatment',
      'color': Color(0xFF38BDF8), // Light Blue
    },
    {
      'icon': LucideIcons.scanFace,
      'label': 'Face ID',
      'desc': 'Biometric sensor repair',
      'color': Color(0xFF8B5CF6), // Violet
    },
    {
      'icon': LucideIcons.hardDrive,
      'label': 'Data Recovery',
      'desc': 'Retrieve lost files',
      'color': Color(0xFFEC4899), // Pink
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startAutoScroll());
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (!_scrollController.hasClients || _isUserScrolling) return;
      double newOffset = _scrollController.offset + 1.0;
      if (_scrollController.position.maxScrollExtent - newOffset < 50) {
        // Reset or infinite scroll logic could be improved here
      }
      _scrollController.jumpTo(newOffset);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30),
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Our Repair Services',
              style: GoogleFonts.inter(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.textHeading,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Professional repairs for every issue',
              style: GoogleFonts.inter(fontSize: 16, color: AppColors.textBody),
            ),
          ),
          const SizedBox(height: 60),
          SizedBox(
            height: 380,
            child: NotificationListener<UserScrollNotification>(
              onNotification: (notification) {
                if (notification.direction == ScrollDirection.idle) {
                  _isUserScrolling = false;
                } else {
                  _isUserScrolling = true;
                }
                return false;
              },
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                  },
                ),
                child: ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: 1000000,
                  itemBuilder: (context, index) {
                    final cat = categories[index % categories.length];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildCategoryCard(cat),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> cat) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.grey.withAlpha(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Half - Image Area
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Center(
              child: _build3DSphere(
                cat['icon'] as IconData,
                cat['color'] as Color,
              ),
            ),
          ),
          // Bottom Half - Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cat['label'] as String,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.textHeading,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    cat['desc'] as String,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textBody,
                      height: 1.5,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.withAlpha(50)),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      'Learn more',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textHeading,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().scale(
      delay: 100.ms,
      duration: 400.ms,
      curve: Curves.easeOutBack,
    );
  }

  Widget _build3DSphere(IconData icon, Color color) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withAlpha(150), // Highlight
            color, // Base
            color.withAlpha(255), // Shadow edge
          ],
          center: Alignment(-0.3, -0.3),
          radius: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(100),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.white.withAlpha(100),
            blurRadius: 10,
            offset: const Offset(-5, -5),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          icon,
          color: Colors.white,
          size: 40,
        ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
      ),
    );
  }
}

class _InstantQuoteSection extends StatelessWidget {
  const _InstantQuoteSection();

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveLayout.isDesktop(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF667eea).withAlpha(15),
            Color(0xFF764ba2).withAlpha(15),
            Color(0xFF667eea).withAlpha(10),
          ],
        ),
      ),
      padding: EdgeInsets.symmetric(
        vertical: isDesktop ? 30 : 40,
        horizontal: isDesktop ? 0 : 20,
      ),
      child: isDesktop
          ? _buildDesktopLayout(context)
          : _buildMobileLayout(context),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60),
      child: Row(
        children: [
          // Left side - Beautiful gradient card with content
          Expanded(
            flex: 5,
            child: Container(
              height: 650,
              padding: const EdgeInsets.all(50),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF667eea).withAlpha(60),
                    blurRadius: 40,
                    offset: const Offset(-10, 20),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(50),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '🎯 INSTANT QUOTE',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Get Your\nRepair Price\nIn Seconds',
                        style: GoogleFonts.inter(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Fast, transparent, and hassle-free pricing for all your device repairs.',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          color: Colors.white.withAlpha(230),
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                  // Stats
                  Column(
                    children: [
                      Row(
                        children: [
                          _buildStat('50K+', 'Repairs Done'),
                          const SizedBox(width: 40),
                          _buildStat('4.9★', 'Rating'),
                          const SizedBox(width: 40),
                          _buildStat('24Hr', 'Turnaround'),
                        ],
                      ),
                      const SizedBox(height: 40),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(30),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              LucideIcons.checkCircle,
                              color: Colors.white,
                              size: 24,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                'Free diagnostics • No hidden fees • Warranty included',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.2, end: 0),
          ),
          const SizedBox(width: 40),
          // Right side - Form
          Expanded(flex: 5, child: _buildForm(context)),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Padding(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              '🎯 INSTANT QUOTE',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
          ).animate().fadeIn(duration: 600.ms).scale(delay: 200.ms),
          const SizedBox(height: 24),
          Text(
            'Get Your Repair Price',
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textHeading,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3, end: 0),
          const SizedBox(height: 16),
          Text(
            'Transparent pricing, no hidden fees. Get your quote in seconds!',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textBody,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 32),
          _buildForm(context, isDesktop: false),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.white.withAlpha(200),
          ),
        ),
      ],
    );
  }

  Widget _buildForm(BuildContext context, {bool isDesktop = true}) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 40 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isDesktop ? 32 : 24),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF667eea).withAlpha(40),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInput(
            'Device Model',
            'e.g. iPhone 13 Pro',
            LucideIcons.smartphone,
            Color(0xFF667eea),
          ),
          const SizedBox(height: 24),
          _buildInput(
            'Issue Description',
            'e.g. Cracked Screen',
            LucideIcons.alertCircle,
            Color(0xFFf093fb),
          ),
          const SizedBox(height: 24),
          _buildInput(
            'City / Zip Code',
            'e.g. New York, 10001',
            LucideIcons.mapPin,
            Color(0xFF43e97b),
          ),
          const SizedBox(height: 24),
          _buildDropdown(
            'Service Type',
            ['Pickup Service', 'Walk-in'],
            LucideIcons.truck,
            Color(0xFF4facfe),
          ),
          const SizedBox(height: 40),
          Container(
            width: double.infinity,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF667eea).withAlpha(100),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RepairPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.zap, size: 24, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(
                    'Get Instant Quote',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ).animate().scale(delay: 600.ms, duration: 400.ms),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.shieldCheck, size: 16, color: Color(0xFF10B981)),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Free quote • No commitment',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textBody,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildInput(
    String label,
    String hint,
    IconData icon,
    Color accentColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: accentColor.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: accentColor),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.textHeading,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              color: Colors.grey.withAlpha(150),
              fontSize: 15,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.withAlpha(50)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.withAlpha(50)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: accentColor, width: 2),
            ),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    IconData icon,
    Color accentColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: accentColor.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: accentColor),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.textHeading,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item, style: GoogleFonts.inter(fontSize: 15)),
            );
          }).toList(),
          onChanged: (val) {},
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.withAlpha(50)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.withAlpha(50)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: accentColor, width: 2),
            ),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
          ),
        ),
      ],
    );
  }
}

class _CarouselSection extends StatefulWidget {
  const _CarouselSection();

  @override
  State<_CarouselSection> createState() => _CarouselSectionState();
}

class _CarouselSectionState extends State<_CarouselSection> {
  final ScrollController _scrollController = ScrollController();
  Timer? _timer;

  final List<Map<String, String>> _items = [
    {
      'image': 'assets/images/card_1.png',
      'title': 'Screen Replacement',
      'subtitle': 'Cracked screen repair from \$49',
    },
    {
      'image': 'assets/images/card_2.png',
      'title': 'Battery Replacement',
      'subtitle': 'New battery installation from \$29',
    },
    {
      'image': 'assets/images/card_3.png',
      'title': 'Water Damage',
      'subtitle': 'Diagnostic & cleaning from \$0',
    },
    {
      'image': 'assets/images/card_4.png',
      'title': 'Charging Port',
      'subtitle': 'Fix charging issues from \$35',
    },
    {
      'image': 'assets/images/card_5.png',
      'title': 'Camera Repair',
      'subtitle': 'Lens & sensor fix from \$59',
    },
    {
      'image': 'assets/images/card_6.png',
      'title': 'Software Issues',
      'subtitle': 'System recovery from \$25',
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startAutoScroll());
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(milliseconds: 20), (timer) {
      if (!_scrollController.hasClients) return;
      double newOffset = _scrollController.offset + 1.0;
      _scrollController.jumpTo(newOffset);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 80),
      height: 560,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 1000000,
        itemBuilder: (context, index) {
          final item = _items[index % _items.length];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: _carouselCard(item),
          );
        },
      ),
    );
  }

  Widget _carouselCard(Map<String, String> item) {
    return Container(
      width: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: DecorationImage(
          image: AssetImage(item['image']!),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [Colors.black.withAlpha(200), Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                stops: const [0.0, 0.6],
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title']!,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.accentYellow,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        LucideIcons.wrench,
                        size: 16,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      item['subtitle']!,
                      style: GoogleFonts.inter(
                        color: Colors.white.withAlpha(230),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandSelectionSection extends StatefulWidget {
  const _BrandSelectionSection();

  @override
  State<_BrandSelectionSection> createState() => _BrandSelectionSectionState();
}

class _BrandSelectionSectionState extends State<_BrandSelectionSection> {
  final ScrollController _scrollController = ScrollController();
  Timer? _timer;
  bool _isUserScrolling = false;

  final List<Map<String, String>> _brands = [
    {'image': 'assets/images/brand_apple.png', 'name': 'Apple'},
    {'image': 'assets/images/brand_samsung.png', 'name': 'Samsung'},
    {'image': 'assets/images/brand_google.png', 'name': 'Google'},
    {'image': 'assets/images/brand_oneplus.png', 'name': 'OnePlus'},
    {'image': 'assets/images/brand_xiaomi.png', 'name': 'Xiaomi'},
    {'image': 'assets/images/brand_oppo.png', 'name': 'Oppo'},
    {'image': 'assets/images/brand_vivo.png', 'name': 'Vivo'},
    {'image': 'assets/images/brand_realme.png', 'name': 'Realme'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startAutoScroll());
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (!_scrollController.hasClients || _isUserScrolling) return;
      double newOffset = _scrollController.offset + 0.5;
      _scrollController.jumpTo(newOffset);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Container(
      color: const Color(0xFFFAFAFA),
      padding: EdgeInsets.symmetric(vertical: isDesktop ? 60 : 40),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Repair by Brand',
              style: GoogleFonts.inter(
                fontSize: isDesktop ? 32 : 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textHeading,
              ),
            ),
          ),
          SizedBox(height: isDesktop ? 40 : 24),
          SizedBox(
            height: isDesktop ? 180 : 140,
            child: NotificationListener<UserScrollNotification>(
              onNotification: (notification) {
                if (notification.direction == ScrollDirection.idle) {
                  _isUserScrolling = false;
                } else {
                  _isUserScrolling = true;
                }
                return false;
              },
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                  },
                ),
                child: ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: 1000000,
                  itemBuilder: (context, index) {
                    final brand = _brands[index % _brands.length];
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 16 : 10,
                      ),
                      child: _brandCard(brand, isDesktop),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _brandCard(Map<String, String> brand, bool isDesktop) {
    return Container(
      width: isDesktop ? 280 : 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Image.asset(
              brand['image']!,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withAlpha(200)],
                    stops: const [0.6, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Text(
                brand['name']!,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 4,
                      color: Colors.black.withAlpha(128),
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().scale(
      delay: 100.ms,
      duration: 400.ms,
      curve: Curves.easeOutBack,
    );
  }
}

class _RepairProcessSection extends StatelessWidget {
  const _RepairProcessSection();

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveLayout.isDesktop(context);

    final steps = [
      {
        'icon': LucideIcons.smartphone,
        'title': 'Select Device',
        'desc': 'Choose your model & issue details',
        'color': const Color(0xFF8B5CF6),
        'bg': [const Color(0xFF8B5CF6), const Color(0xFFC4B5FD)],
      },
      {
        'icon': LucideIcons.search,
        'title': 'Free Diagnosis',
        'desc': 'Get an instant quote for repair',
        'color': const Color(0xFFEC4899),
        'bg': [const Color(0xFFEC4899), const Color(0xFFFBCFE8)],
      },
      {
        'icon': LucideIcons.truck,
        'title': 'Pickup / Visit',
        'desc': 'We come to you or you visit us',
        'color': const Color(0xFF3B82F6),
        'bg': [const Color(0xFF3B82F6), const Color(0xFFBFDBFE)],
      },
      {
        'icon': LucideIcons.wrench,
        'title': 'Expert Repair',
        'desc': 'Most repairs done in <30 mins',
        'color': const Color(0xFF10B981),
        'bg': [const Color(0xFF10B981), const Color(0xFFA7F3D0)],
      },
      {
        'icon': LucideIcons.checkCircle,
        'title': 'Pay & Enjoy',
        'desc': 'Pay only when you are satisfied',
        'color': const Color(0xFFF59E0B),
        'bg': [const Color(0xFFF59E0B), const Color(0xFFFDE68A)],
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 24),
      color: const Color(0xFFFAFAFA),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryButton.withAlpha(20),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'SIMPLE PROCESS',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryButton,
                letterSpacing: 1.5,
              ),
            ),
          ).animate().fadeIn(duration: 600.ms),
          const SizedBox(height: 16),
          Text(
            'How It Works',
            style: GoogleFonts.inter(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: AppColors.textHeading,
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 12),
          Text(
            'Your device repaired in 5 easy steps',
            style: GoogleFonts.inter(fontSize: 16, color: AppColors.textBody),
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 40),
          isDesktop
              ? Row(
                  children: steps.asMap().entries.map((entry) {
                    final index = entry.key;
                    final step = entry.value;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: index != steps.length - 1 ? 20 : 0,
                        ),
                        child: _buildProcessCard(step, index),
                      ),
                    );
                  }).toList(),
                )
              : Column(
                  children: steps.asMap().entries.map((entry) {
                    final index = entry.key;
                    final step = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: _buildProcessCard(step, index),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildProcessCard(Map<String, dynamic> step, int index) {
    return FadeInScaleCard(
      delay: Duration(milliseconds: index * 150 + 400),
      child: Container(
        height: 280,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Illustration Area (Simulating an Image)
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: step['bg'] as List<Color>,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: Stack(
                  children: [
                    // Abstract Background Pattern
                    Positioned(
                      right: -20,
                      top: -20,
                      child: Icon(
                        step['icon'] as IconData,
                        size: 120,
                        color: Colors.white.withAlpha(30),
                      ),
                    ),
                    Positioned(
                      left: 20,
                      bottom: 20,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(50),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Text(
                          '${index + 1}',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Icon(
                        step['icon'] as IconData,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Content Area
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      step['title'] as String,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.textHeading,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      step['desc'] as String,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textBody,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WarrantySection extends StatelessWidget {
  const _WarrantySection();

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveLayout.isDesktop(context);
    final badges = [
      {
        'icon': LucideIcons.shieldCheck,
        'label': '6 Months Warranty',
        'desc': 'Peace of mind on every repair',
        'color': const Color(0xFF8B5CF6),
      },
      {
        'icon': LucideIcons.cpu,
        'label': 'Original Parts',
        'desc': 'Only high-quality spares used',
        'color': const Color(0xFFEC4899),
      },
      {
        'icon': LucideIcons.userCheck,
        'label': 'Expert Techs',
        'desc': 'Certified & experienced team',
        'color': const Color(0xFF3B82F6),
      },
      {
        'icon': LucideIcons.lock,
        'label': 'Data Privacy',
        'desc': 'Your data is 100% secure',
        'color': const Color(0xFF10B981),
      },
      {
        'icon': LucideIcons.dollarSign,
        'label': 'No Fix No Fee',
        'desc': 'You only pay when it\'s fixed',
        'color': const Color(0xFFF59E0B),
      },
    ];

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: isDesktop ? 60 : 40),
      width: double.infinity,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withAlpha(20),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'WHY CHOOSE ZIYONSTAR',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF8B5CF6),
                letterSpacing: 1.5,
              ),
            ),
          ).animate().fadeIn(),
          SizedBox(height: isDesktop ? 20 : 16),
          Text(
            'The Ziyonstar Promise',
            style: GoogleFonts.inter(
              fontSize: isDesktop ? 36 : 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textHeading,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Text(
              'Premium service standards you can trust',
              style: GoogleFonts.inter(
                fontSize: isDesktop ? 16 : 14,
                color: AppColors.textBody,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 300.ms),
          ),
          SizedBox(height: isDesktop ? 60 : 40),
          Wrap(
            spacing: isDesktop ? 24 : 16,
            runSpacing: isDesktop ? 24 : 16,
            alignment: WrapAlignment.center,
            children: badges.asMap().entries.map((entry) {
              return _WarrantyCard(badge: entry.value, index: entry.key);
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _WarrantyCard extends StatefulWidget {
  final Map<String, dynamic> badge;
  final int index;
  const _WarrantyCard({super.key, required this.badge, required this.index});

  @override
  State<_WarrantyCard> createState() => _WarrantyCardState();
}

class _WarrantyCardState extends State<_WarrantyCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final color = widget.badge['color'] as Color;

    return MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isDesktop ? 220 : 160,
            height: isDesktop ? 220 : 200,
            padding: EdgeInsets.all(isDesktop ? 24 : 16),
            decoration: BoxDecoration(
              color: _isHovered ? color : Colors.white,
              gradient: _isHovered
                  ? LinearGradient(
                      colors: [color, color.withAlpha(200)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: _isHovered
                      ? color.withAlpha(100)
                      : color.withAlpha(15),
                  blurRadius: _isHovered ? 40 : 30,
                  offset: _isHovered
                      ? const Offset(0, 20)
                      : const Offset(0, 15),
                  spreadRadius: 2,
                ),
              ],
              border: Border.all(
                color: _isHovered
                    ? Colors.white.withAlpha(50)
                    : color.withAlpha(20),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.all(isDesktop ? 16 : 12),
                  decoration: BoxDecoration(
                    color: _isHovered
                        ? Colors.white.withAlpha(50)
                        : color.withAlpha(15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.badge['icon'] as IconData,
                    color: _isHovered ? Colors.white : color,
                    size: isDesktop ? 32 : 24,
                  ),
                ),
                SizedBox(height: isDesktop ? 20 : 12),
                Text(
                  widget.badge['label'] as String,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: isDesktop ? 16 : 14,
                    fontWeight: FontWeight.bold,
                    color: _isHovered ? Colors.white : AppColors.textHeading,
                  ),
                ),
                SizedBox(height: isDesktop ? 8 : 4),
                Text(
                  widget.badge['desc'] as String,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: isDesktop ? 12 : 11,
                    color: _isHovered
                        ? Colors.white.withAlpha(200)
                        : AppColors.textBody,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(delay: (widget.index * 100 + 200).ms)
        .slideY(begin: 0.1, end: 0);
  }
}

class _TestimonialsSection extends StatefulWidget {
  const _TestimonialsSection();

  @override
  State<_TestimonialsSection> createState() => _TestimonialsSectionState();
}

class _TestimonialsSectionState extends State<_TestimonialsSection> {
  late final ScrollController _scrollController;
  Timer? _timer;

  final reviews = [
    {
      'name': 'Sarah Johnson',
      'rating': 5,
      'text':
          'Fixed my iPhone screen in 20 minutes! Super professional and my data stayed safe. Highly recommend Ziyonstar!',
      'date': '2 days ago',
      'color': const Color(0xFF8B5CF6),
    },
    {
      'name': 'Michael Chen',
      'rating': 5,
      'text':
          'Best repair shop in town. They even fixed my charging port for free while replacing the battery. Amazing service!',
      'date': '1 week ago',
      'color': const Color(0xFFEC4899),
    },
    {
      'name': 'Emily Davis',
      'rating': 5,
      'text':
          'The pickup and drop service was a lifesaver for my busy schedule. Got my MacBook back the same day.',
      'date': '3 weeks ago',
      'color': const Color(0xFF3B82F6),
    },
    {
      'name': 'David Kim',
      'rating': 5,
      'text':
          'Thought my iPad was a goner after water damage. They brought it back to life! Honest pricing and great tech skills.',
      'date': '1 month ago',
      'color': const Color(0xFF10B981),
    },
    {
      'name': 'Lisa Wang',
      'rating': 4,
      'text':
          'Fast service for my console repair. Keeps ignoring my calls sometimes but the repair quality is top notch.',
      'date': '2 months ago',
      'color': const Color(0xFFF59E0B),
    },
    {
      'name': 'James Wilson',
      'rating': 5,
      'text':
          'Professional, certified technicians. You can tell they know what they are doing. Will definitely come back.',
      'date': '2 months ago',
      'color': const Color(0xFF6366F1),
    },
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startAutoScroll());
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_scrollController.hasClients) {
        if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent) {
          _scrollController.jumpTo(0);
        } else {
          _scrollController.jumpTo(_scrollController.offset + 1);
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveLayout.isDesktop(context);

    return Container(
      color: const Color(0xFFFAFAFA),
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEC4899).withAlpha(20),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'TESTIMONIALS',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFEC4899),
                      letterSpacing: 1.5,
                    ),
                  ),
                ).animate().fadeIn(),
                const SizedBox(height: 16),
                Text(
                  'Customer Love',
                  style: GoogleFonts.inter(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textHeading,
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      '4.9/5 Average Rating',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textHeading,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(2,400+ reviews)',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textBody,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 50),
          SizedBox(
            height: 300,
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: reviews.length * 100, // Infinite loop illusion
              itemBuilder: (context, index) {
                final review = reviews[index % reviews.length];
                final color = review['color'] as Color;

                return Container(
                  width: isDesktop ? 380 : 320,
                  margin: EdgeInsets.only(
                    left: index == 0 ? 24 : 0,
                    right: 24,
                    bottom: 20,
                    top: 10,
                  ),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(10),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    border: Border.all(color: Colors.grey.withAlpha(10)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [color, color.withAlpha(150)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                review['name'].toString().substring(0, 1),
                                style: GoogleFonts.inter(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  review['name'] as String,
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: AppColors.textHeading,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: List.generate(
                                    5,
                                    (i) => Icon(
                                      Icons.star,
                                      size: 14,
                                      color: i < (review['rating'] as int)
                                          ? const Color(0xFFF59E0B)
                                          : Colors.grey.withAlpha(50),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            LucideIcons.quote,
                            color: color.withAlpha(30),
                            size: 40,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: Text(
                          '"${review['text']}"',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            color: AppColors.textBody,
                            height: 1.6,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        review['date'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
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

class _DeliveryOptionsSection extends StatefulWidget {
  const _DeliveryOptionsSection();

  @override
  State<_DeliveryOptionsSection> createState() =>
      _DeliveryOptionsSectionState();
}

class _DeliveryOptionsSectionState extends State<_DeliveryOptionsSection> {
  late final ScrollController _scrollController;
  Timer? _timer;

  final options = [
    {
      'icon': LucideIcons.home,
      'title': 'Doorstep Repair',
      'desc':
          'Our expert technicians come to your location with all tools and parts',
      'color': const Color(0xFF10B981),
      'gradient': [const Color(0xFF10B981), const Color(0xFF059669)],
    },
    {
      'icon': LucideIcons.bike,
      'title': 'Pickup & Drop',
      'desc': 'Free collection from your doorstep and same-day delivery',
      'color': const Color(0xFF3B82F6),
      'gradient': [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
    },
    {
      'icon': LucideIcons.store,
      'title': 'In-Store Service',
      'desc': 'Visit our service center and get instant diagnosis',
      'color': const Color(0xFF8B5CF6),
      'gradient': [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)],
    },
    {
      'icon': LucideIcons.clock,
      'title': 'Same Day Express',
      'desc': 'Most repairs completed within 2-3 hours with priority service',
      'color': const Color(0xFFF59E0B),
      'gradient': [const Color(0xFFF59E0B), const Color(0xFFD97706)],
    },
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startAutoScroll());
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (_scrollController.hasClients) {
        if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent) {
          _scrollController.jumpTo(0);
        } else {
          _scrollController.jumpTo(_scrollController.offset + 0.5);
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveLayout.isDesktop(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withAlpha(20),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'SERVICE OPTIONS',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF3B82F6),
                      letterSpacing: 1.5,
                    ),
                  ),
                ).animate().fadeIn(),
                const SizedBox(height: 20),
                Text(
                  'Flexible Service Options',
                  style: GoogleFonts.inter(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textHeading,
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
                const SizedBox(height: 12),
                Text(
                  'Choose how you want to get your device fixed',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: AppColors.textBody,
                  ),
                ).animate().fadeIn(delay: 300.ms),
              ],
            ),
          ),
          const SizedBox(height: 50),
          SizedBox(
            height: isDesktop ? 200 : 240,
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: options.length * 100,
              itemBuilder: (context, index) {
                final option = options[index % options.length];
                final color = option['color'] as Color;
                final gradient = option['gradient'] as List<Color>;

                return Container(
                  width: isDesktop ? 420 : 340,
                  margin: EdgeInsets.only(
                    left: index == 0 ? 24 : 0,
                    right: 24,
                    bottom: 20,
                    top: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: color.withAlpha(40),
                        blurRadius: 25,
                        offset: const Offset(0, 10),
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(30),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withAlpha(60),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              option['icon'] as IconData,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                option['title'] as String,
                                style: GoogleFonts.inter(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                option['desc'] as String,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Colors.white.withAlpha(230),
                                  height: 1.5,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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

// Device Search Widget for Hero Section
class _DeviceSearchWidget extends StatefulWidget {
  const _DeviceSearchWidget();

  @override
  State<_DeviceSearchWidget> createState() => _DeviceSearchWidgetState();
}

class _DeviceSearchWidgetState extends State<_DeviceSearchWidget> {
  String? selectedBrand;
  String? selectedModel;

  final Map<String, List<String>> brandModels = {
    'Apple': [
      'iPhone 15 Pro Max',
      'iPhone 15 Pro',
      'iPhone 15',
      'iPhone 14 Pro Max',
      'iPhone 14 Pro',
      'iPhone 14',
      'iPhone 13 Pro Max',
      'iPhone 13',
      'iPhone 12',
    ],
    'Samsung': [
      'Galaxy S24 Ultra',
      'Galaxy S24+',
      'Galaxy S24',
      'Galaxy S23 Ultra',
      'Galaxy S23',
      'Galaxy Z Fold 5',
      'Galaxy Z Flip 5',
      'Galaxy A54',
    ],
    'Google': [
      'Pixel 8 Pro',
      'Pixel 8',
      'Pixel 7 Pro',
      'Pixel 7',
      'Pixel 6 Pro',
      'Pixel 6',
    ],
    'OnePlus': [
      'OnePlus 12',
      'OnePlus 11',
      'OnePlus 10 Pro',
      'OnePlus 9 Pro',
      'OnePlus Nord 3',
    ],
    'Xiaomi': [
      'Xiaomi 14 Pro',
      'Xiaomi 13 Pro',
      'Xiaomi 12 Pro',
      'Redmi Note 13 Pro',
      'Redmi Note 12 Pro',
    ],
    'Oppo': ['Find X6 Pro', 'Find X5 Pro', 'Reno 11 Pro', 'Reno 10 Pro', 'A78'],
    'Vivo': ['X100 Pro', 'X90 Pro', 'V29 Pro', 'V27 Pro', 'Y100'],
  };

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveLayout.isDesktop(context);

    return FadeInScaleCard(
      delay: const Duration(milliseconds: 600),
      child: Container(
        padding: EdgeInsets.all(isDesktop ? 24 : 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, const Color(0xFFF9FAFB)],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryButton.withAlpha(15),
              blurRadius: 30,
              offset: const Offset(0, 10),
              spreadRadius: 2,
            ),
          ],
          border: Border.all(color: Colors.grey.withAlpha(20), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryButton.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    LucideIcons.search,
                    color: AppColors.primaryButton,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Find Your Device',
                  style: GoogleFonts.inter(
                    fontSize: isDesktop ? 18 : 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textHeading,
                  ),
                ),
              ],
            ),
            SizedBox(height: isDesktop ? 20 : 16),

            // Brand Dropdown
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: selectedBrand,
                  hint: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Icon(
                          LucideIcons.smartphone,
                          size: 18,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Select Brand',
                          style: GoogleFonts.inter(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  icon: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  items: brandModels.keys.map((String brand) {
                    return DropdownMenuItem<String>(
                      value: brand,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            const Icon(
                              LucideIcons.smartphone,
                              size: 18,
                              color: AppColors.primaryButton,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              brand,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedBrand = newValue;
                      selectedModel = null;
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  dropdownColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Model Dropdown
            Container(
              decoration: BoxDecoration(
                color: selectedBrand == null
                    ? Colors.grey.shade50
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selectedBrand == null
                      ? Colors.grey.shade100
                      : Colors.grey.shade200,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: selectedModel,
                  hint: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Icon(
                          LucideIcons.tablet,
                          size: 18,
                          color: selectedBrand == null
                              ? Colors.grey.shade300
                              : Colors.grey.shade400,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          selectedBrand == null
                              ? 'Select Brand First'
                              : 'Select Model',
                          style: GoogleFonts.inter(
                            color: selectedBrand == null
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  icon: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: selectedBrand == null
                          ? Colors.grey.shade300
                          : Colors.grey.shade400,
                    ),
                  ),
                  items: selectedBrand == null
                      ? []
                      : brandModels[selectedBrand]!.map((String model) {
                          return DropdownMenuItem<String>(
                            value: model,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                model,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  onChanged: selectedBrand == null
                      ? null
                      : (String? newValue) {
                          setState(() {
                            selectedModel = newValue;
                          });
                        },
                  borderRadius: BorderRadius.circular(16),
                  dropdownColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),

            SizedBox(height: isDesktop ? 20 : 16),

            // Search Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedBrand != null && selectedModel != null
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RepairPage(),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryButton,
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding: EdgeInsets.symmetric(vertical: isDesktop ? 18 : 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: selectedBrand != null && selectedModel != null
                      ? 2
                      : 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.search,
                      size: 20,
                      color: selectedBrand != null && selectedModel != null
                          ? Colors.white
                          : Colors.grey.shade500,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Get Repair Quote',
                      style: GoogleFonts.inter(
                        fontSize: isDesktop ? 16 : 14,
                        fontWeight: FontWeight.bold,
                        color: selectedBrand != null && selectedModel != null
                            ? Colors.white
                            : Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Preloader Animation Widget
class _Preloader extends StatefulWidget {
  final VoidCallback onComplete;
  const _Preloader({required this.onComplete});

  @override
  State<_Preloader> createState() => _PreloaderState();
}

class _PreloaderState extends State<_Preloader>
    with SingleTickerProviderStateMixin {
  late AnimationController _exitController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Curtain roll up animation (Slide Up)
    _slideAnimation =
        Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(0, -1.2), // Move completely off screen
        ).animate(
          CurvedAnimation(
            parent: _exitController,
            curve: Curves.easeInOutCubic, // Smooth acceleration/deceleration
          ),
        );

    // Animation Sequence
    _runAnimationSequence();
  }

  void _runAnimationSequence() async {
    // Total duration of entrance animations:
    // Logo: 600ms
    // Text: Starts at 400ms, last letter (9 letters) starts at 400 + 900 = 1300ms
    // Text fade duration: 400ms. Total text finish ~ 1700ms.

    // Wait for entrance animations to complete + some hold time
    await Future.delayed(const Duration(milliseconds: 2800));

    // Trigger curtain roll up
    if (mounted) {
      await _exitController.forward();
      widget.onComplete();
    }
  }

  @override
  void dispose() {
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const String title = "Ziyonstar";

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        color: Colors.white,
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background Elements (Optional subtle pattern)
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryButton.withAlpha(10),
                ),
              ),
            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Logo
                Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primaryButton, Color(0xFF4c1d95)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryButton.withAlpha(60),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        LucideIcons.zap,
                        size: 48,
                        color: Colors.white,
                      ),
                    )
                    .animate()
                    .scale(duration: 600.ms, curve: Curves.easeOutBack)
                    .fadeIn(duration: 400.ms)
                    .shimmer(
                      delay: 1500.ms,
                      duration: 1000.ms,
                      color: Colors.white.withAlpha(100),
                    ),

                const SizedBox(height: 32),

                // Animated Text (Letter by Letter)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: title.split('').asMap().entries.map((entry) {
                    return Text(
                          entry.value,
                          style: GoogleFonts.inter(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textHeading,
                            letterSpacing: -1,
                          ),
                        )
                        .animate()
                        .fadeIn(
                          delay: (400 + (entry.key * 100)).ms,
                          duration: 400.ms,
                        )
                        .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuad);
                  }).toList(),
                ),

                const SizedBox(height: 16),

                // Tagline
                Text(
                  'Future of Repair',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textBody,
                    letterSpacing: 4,
                  ),
                ).animate().fadeIn(delay: 2000.ms, duration: 600.ms),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
