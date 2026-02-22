import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
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
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Image.asset(
                            'assets/images/app_logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Device Repair Experts',
                      style: GoogleFonts.inter(
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
                      onTap: () {
                        Navigator.pop(context);
                        context.go('/');
                      },
                    ),
                    _buildDrawerItem(
                      icon: LucideIcons.wrench,
                      title: 'Repair Services',
                      onTap: () {
                        Navigator.pop(context);
                        context.go('/repair');
                      },
                    ),
                    _buildDrawerItem(
                      icon: LucideIcons.calendarClock,
                      title: 'My Bookings',
                      onTap: () {
                        Navigator.pop(context);
                        context.go('/bookings');
                      },
                    ),
                    _buildDrawerItem(
                      icon: LucideIcons.user,
                      title: 'My Profile',
                      onTap: () {
                        Navigator.pop(context);
                        context.go('/profile');
                      },
                    ),
                    _buildDrawerItem(
                      icon: LucideIcons.bell,
                      title: 'Notifications',
                      onTap: () {
                        Navigator.pop(context);
                        context.go('/notifications');
                      },
                    ),
                    _buildDrawerItem(
                      icon: LucideIcons.info,
                      title: 'About Us',
                      onTap: () {
                        Navigator.pop(context);
                        context.go('/about');
                      },
                    ),
                    _buildDrawerItem(
                      icon: LucideIcons.phoneCall,
                      title: 'Contact Us',
                      onTap: () {
                        Navigator.pop(context);
                        context.go('/contact');
                      },
                    ),
                    const SizedBox(height: 16),
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
                        onPressed: () {
                          Navigator.pop(context);
                          context.go('/login');
                        },
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
                              style: GoogleFonts.inter(
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
                      '© 2026 Ziyonstar',
                      style: GoogleFonts.inter(
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
          style: GoogleFonts.inter(
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
