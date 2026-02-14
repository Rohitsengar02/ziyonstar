import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:math' as math;

class AuthSidebar extends StatefulWidget {
  final int currentStep;
  final int totalSteps;
  const AuthSidebar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  State<AuthSidebar> createState() => _AuthSidebarState();
}

class _AuthSidebarState extends State<AuthSidebar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> _stepInfo = [
    {
      'title': 'Join the Elite',
      'subtitle': 'Partner with the leading on-demand repair platform.',
      'icon': LucideIcons.shieldCheck,
      'color': const Color(0xFF6366F1), // Indigo
    },
    {
      'title': 'Profile Setup',
      'subtitle': 'Tell us more about yourself and your expertise.',
      'icon': LucideIcons.user,
      'color': const Color(0xFF8B5CF6), // Violet
    },
    {
      'title': 'Identity Verification',
      'subtitle': 'Secure and fast KYC to ensure trust in our network.',
      'icon': LucideIcons.fileSearch,
      'color': const Color(0xFFEC4899), // Pink
    },
    {
      'title': 'Brand Expertise',
      'subtitle': 'Select the brands you are comfortable working with.',
      'icon': LucideIcons.smartphone,
      'color': const Color(0xFFF59E0B), // Amber
    },
    {
      'title': 'Skill Selection',
      'subtitle': 'Identify the specific repair skills you possess.',
      'icon': LucideIcons.wrench,
      'color': const Color(0xFF10B981), // Emerald
    },
    {
      'title': 'Service Configuration',
      'subtitle': 'Choose your service types and coverage areas.',
      'icon': LucideIcons.mapPin,
      'color': const Color(0xFF3B82F6), // Blue
    },
    {
      'title': 'Payout Details',
      'subtitle': 'Set up your bank account for weekly earnings.',
      'icon': LucideIcons.banknote,
      'color': const Color(0xFFEF4444), // Red
    },
    {
      'title': 'Legal Agreement',
      'subtitle': 'Review our terms and conditions for partnership.',
      'icon': LucideIcons.fileText,
      'color': const Color(0xFF6B7280), // Gray
    },
    {
      'title': 'Final Review',
      'subtitle': 'Your application is ready for verification.',
      'icon': LucideIcons.checkCircle,
      'color': const Color(0xFF06B6D4), // Cyan
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Determine the color based on current step
    // Handle step 0 as Register, 1-8 as Onboarding
    final int infoIndex = widget.currentStep.clamp(0, _stepInfo.length - 1);
    final currentInfo = _stepInfo[infoIndex];
    final Color primaryColor = currentInfo['color'];

    return Container(
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: primaryColor.withOpacity(0.05),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Dynamic Background Animation
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Stack(
                children: [
                  Positioned(
                    top:
                        -100 + (math.sin(_controller.value * math.pi * 2) * 50),
                    left:
                        -100 + (math.cos(_controller.value * math.pi * 2) * 50),
                    child: _buildBlurCircle(primaryColor.withOpacity(0.3), 300),
                  ),
                  Positioned(
                    bottom:
                        -100 + (math.cos(_controller.value * math.pi * 2) * 50),
                    right:
                        -100 + (math.sin(_controller.value * math.pi * 2) * 50),
                    child: _buildBlurCircle(primaryColor.withOpacity(0.2), 400),
                  ),
                ],
              );
            },
          ),

          // Content Wrapper
          Padding(
            padding: const EdgeInsets.all(48.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Step Indicator (Small)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'STEP ${infoIndex == 0 ? "INTRO" : infoIndex}',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Animated Card
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 600),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position:
                                Tween<Offset>(
                                  begin: const Offset(0.0, 0.1),
                                  end: Offset.zero,
                                ).animate(
                                  CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOutCubic,
                                  ),
                                ),
                            child: child,
                          ),
                        );
                      },
                  child: Column(
                    key: ValueKey(infoIndex),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.15),
                              blurRadius: 40,
                              offset: const Offset(0, 20),
                            ),
                          ],
                        ),
                        child: Icon(
                          currentInfo['icon'],
                          size: 40,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 48),
                      Text(
                        currentInfo['title'],
                        style: GoogleFonts.poppins(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        currentInfo['subtitle'],
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          color: Colors.grey[600],
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 64),

                // Progress Dots
                Row(
                  children: List.generate(_stepInfo.length, (index) {
                    final bool isCurrent = index == infoIndex;
                    final bool isPast = index < infoIndex;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 8),
                      width: isCurrent ? 32 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? primaryColor
                            : (isPast
                                  ? primaryColor.withOpacity(0.4)
                                  : Colors.grey[200]),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlurCircle(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: Center(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [color, color.withOpacity(0.5), Colors.transparent],
            ),
          ),
        ),
      ),
    );
  }
}
