import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';

class MobileBottomNav extends StatelessWidget {
  final int currentIndex;

  const MobileBottomNav({super.key, required this.currentIndex});

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/bookings');
        break;
      case 2:
        context.go('/repair');
        break;
      case 3:
        context.go('/about');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primaryButton,
        unselectedItemColor: Colors.grey[400],
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 10),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(LucideIcons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(LucideIcons.calendar),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryButton, Color(0xFF8B5CF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryButton.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                LucideIcons.wrench,
                color: Colors.white,
                size: 24,
              ),
            ),
            label: 'Repair',
          ),
          const BottomNavigationBarItem(
            icon: Icon(LucideIcons.info),
            label: 'About',
          ),
          const BottomNavigationBarItem(
            icon: Icon(LucideIcons.user),
            label: 'Profile',
          ),
        ],
        currentIndex: currentIndex,
        onTap: (index) => _onTap(context, index),
      ),
    );
  }
}
