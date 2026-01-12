import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryButton,
              AppColors.primaryButton.withAlpha(200),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            LucideIcons.zap,
                            color: AppColors.primaryButton,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Ziyonstar',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Device Repair Experts',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        color: Colors.white.withAlpha(200),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white24, height: 1),
              const SizedBox(height: 16),
              // Menu Items
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildDrawerItem(
                      icon: LucideIcons.home,
                      title: 'Home',
                      isActive: true,
                      onTap: () => Navigator.pop(context),
                    ),
                    _buildDrawerItem(
                      icon: LucideIcons.shoppingBag,
                      title: 'Sell Device',
                      onTap: () {},
                    ),
                    _buildDrawerItem(
                      icon: LucideIcons.wrench,
                      title: 'Repair Services',
                      onTap: () {},
                    ),
                    _buildDrawerItem(
                      icon: LucideIcons.users,
                      title: 'Community',
                      onTap: () {},
                    ),
                    _buildDrawerItem(
                      icon: LucideIcons.shield,
                      title: 'Warranty Info',
                      onTap: () {},
                    ),
                    _buildDrawerItem(
                      icon: LucideIcons.mapPin,
                      title: 'Locations',
                      onTap: () {},
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 16),
                    _buildDrawerItem(
                      icon: LucideIcons.info,
                      title: 'About Us',
                      onTap: () {},
                    ),
                    _buildDrawerItem(
                      icon: LucideIcons.phone,
                      title: 'Contact',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              // Footer
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primaryButton,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(LucideIcons.user, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Sign In',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '© 2024 Ziyonstar',
                      style: GoogleFonts.manrope(
                        color: Colors.white.withAlpha(180),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive ? Colors.white : Colors.white.withAlpha(180),
          size: 22,
        ),
        title: Text(
          title,
          style: GoogleFonts.manrope(
            color: isActive ? Colors.white : Colors.white.withAlpha(180),
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            fontSize: 16,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: isActive ? Colors.white.withAlpha(25) : Colors.transparent,
        onTap: onTap,
      ),
    );
  }
}
