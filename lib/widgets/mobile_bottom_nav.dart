import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme.dart';
import '../screens/mobile_home_screen.dart';
import '../screens/my_bookings_screen.dart';
import '../screens/mobile_about_page.dart';
import '../screens/mobile_profile_page.dart';
import '../screens/mobile_repair_page.dart';

class MobileBottomNav extends StatelessWidget {
  final int currentIndex;

  const MobileBottomNav({super.key, required this.currentIndex});

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget page;
    switch (index) {
      case 0:
        page = const MobileHomeScreen();
        break;
      case 1:
        page = const MyBookingsScreen();
        break;
      case 2:
        page = const MobileRepairPage();
        break;
      case 3:
        page = const MobileAboutPage();
        break;
      case 4:
        page = const MobileProfilePage();
        break;
      default:
        return; // TODO: Implement other pages
    }

    // Use pushAndRemoveUntil for Home to clear stack, or push for others
    if (index == 0) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (c) => page),
        (r) => false,
      );
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (c) => page));
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
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.calendar),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryButton, Color(0xFF8B5CF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryButton.withOpacity(0.4),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(LucideIcons.wrench, color: Colors.white, size: 24),
            ),
            label: 'Repair',
          ),
          BottomNavigationBarItem(icon: Icon(LucideIcons.info), label: 'About'),
          BottomNavigationBarItem(
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
