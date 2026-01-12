import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme.dart';
import '../responsive.dart';

class Navbar extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const Navbar({super.key, required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveLayout.isDesktop(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100), // Pill shape
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 40,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Logo & Location
          Row(
            children: [
              // Logo
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryButton, Colors.black],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.zap,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              if (isDesktop) ...[
                Text(
                  'Ziyonstar',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textHeading,
                  ),
                ),
                const SizedBox(width: 32),
                Container(
                  height: 24,
                  width: 1,
                  color: Colors.grey.shade200,
                ), // Divider
                const SizedBox(width: 24),
                // Location Selector
                InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.heroBg,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          LucideIcons.mapPin,
                          size: 16,
                          color: AppColors.accentRed,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'New York, USA',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textHeading,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.keyboard_arrow_down,
                          size: 16,
                          color: AppColors.textBody,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),

          // Center: Navigation (Desktop)
          if (isDesktop)
            Row(
              children: [
                _navLink('Home', active: true),
                _navLink('Sell'),
                _navLink('Repair'),
                _navLink('Community'),
              ],
            ),

          // Right: Actions
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  LucideIcons.search,
                  color: AppColors.textBody,
                  size: 22,
                ),
              ),
              const SizedBox(width: 8),
              Stack(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      LucideIcons.shoppingBag,
                      color: AppColors.textBody,
                      size: 22,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.accentRed,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              if (isDesktop) ...[
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryButton,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('Get Started'),
                ),
              ],
              if (!isDesktop) // Mobile menu icon
                IconButton(
                  onPressed: () {
                    scaffoldKey.currentState?.openDrawer();
                  },
                  icon: const Icon(
                    LucideIcons.menu,
                    color: AppColors.textHeading,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _navLink(String text, {bool active = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: TextButton(
        onPressed: () {},
        style: TextButton.styleFrom(
          backgroundColor: active
              ? Colors.black.withAlpha(10)
              : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: active ? AppColors.textHeading : AppColors.textBody,
            fontWeight: active ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
