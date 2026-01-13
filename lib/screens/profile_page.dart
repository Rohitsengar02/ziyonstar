import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme.dart';
import '../responsive.dart';
import '../widgets/navbar.dart';
import '../widgets/app_drawer.dart';
import '../widgets/footer.dart';
import 'edit_profile_page.dart';
import 'my_bookings_screen.dart';
import 'repair_page.dart';
import 'about_page.dart';
import 'contact_page.dart';
import '../widgets/mobile_bottom_nav.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveLayout.isDesktop(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: const AppDrawer(),
      bottomNavigationBar: isDesktop
          ? null
          : const MobileBottomNav(currentIndex: 4),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Navbar
            if (isDesktop)
              Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 80 : 20,
                  vertical: isDesktop ? 20 : 16,
                ),
                child: Navbar(scaffoldKey: _scaffoldKey),
              ),

            // Profile Header
            _buildProfileHeader(isDesktop),

            // Profile Actions Grid
            _buildProfileActions(isDesktop),

            // Account Settings
            _buildAccountSettings(isDesktop),

            if (isDesktop) const Footer(),
            if (!isDesktop) const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(bool isDesktop) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : 20,
        vertical: isDesktop ? 80 : 100,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF667eea),
            const Color(0xFF764ba2),
            AppColors.primaryButton,
          ],
        ),
      ),
      child: Column(
        children: [
          // Avatar with Animated Glow
          Stack(
            alignment: Alignment.center,
            children: [
              // Glow effect
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Colors.white.withOpacity(0.3), Colors.transparent],
                  ),
                ),
              ),
              // Avatar with gradient border
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFffecd2), Color(0xFFfcb69f)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 112,
                    height: 112,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF667eea).withOpacity(0.8),
                          const Color(0xFF764ba2).withOpacity(0.8),
                        ],
                      ),
                    ),
                    child: const Icon(
                      LucideIcons.user,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Name
          Text(
            'John Doe',
            style: GoogleFonts.poppins(
              fontSize: isDesktop ? 36 : 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          // Email
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  LucideIcons.mail,
                  size: 16,
                  color: Colors.white.withOpacity(0.9),
                ),
                const SizedBox(width: 8),
                Text(
                  'john.doe@example.com',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.95),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Phone
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  LucideIcons.phone,
                  size: 16,
                  color: Colors.white.withOpacity(0.9),
                ),
                const SizedBox(width: 8),
                Text(
                  '+1 (555) 123-4567',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.95),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          // Edit Profile Button
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfilePage(),
                ),
              );
            },
            icon: const Icon(LucideIcons.edit, size: 18),
            label: Text(
              'Edit Profile',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF667eea),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 8,
              shadowColor: Colors.black.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileActions(bool isDesktop) {
    final actions = [
      {
        'icon': LucideIcons.calendarClock,
        'title': 'My Bookings',
        'subtitle': 'View all your repair bookings',
        'gradient': [const Color(0xFF667eea), const Color(0xFF764ba2)],
        'page': const MyBookingsScreen(),
      },
      {
        'icon': LucideIcons.wrench,
        'title': 'Repair Services',
        'subtitle': 'Book a new repair service',
        'gradient': [const Color(0xFFf093fb), const Color(0xFFF5576c)],
        'page': const RepairPage(),
      },
      {
        'icon': LucideIcons.info,
        'title': 'About Us',
        'subtitle': 'Learn more about Ziyonstar',
        'gradient': [const Color(0xFF4facfe), const Color(0xFF00f2fe)],
        'page': const AboutPage(),
      },
      {
        'icon': LucideIcons.messageCircle,
        'title': 'Contact Us',
        'subtitle': 'Get in touch with support',
        'gradient': [const Color(0xFF43e97b), const Color(0xFF38f9d7)],
        'page': const ContactPage(),
      },
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : 20,
        vertical: isDesktop ? 60 : 40,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Access',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textHeading,
            ),
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isDesktop ? 4 : 2,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: isDesktop ? 1 : 1.1,
            ),
            itemCount: actions.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => actions[index]['page'] as Widget,
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: actions[index]['gradient'] as List<Color>,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: (actions[index]['gradient'] as List<Color>)[0]
                            .withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            actions[index]['icon'] as IconData,
                            size: 28,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          actions[index]['title'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          actions[index]['subtitle'] as String,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.9),
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSettings(bool isDesktop) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : 20,
        vertical: isDesktop ? 60 : 40,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account Settings',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textHeading,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200, width: 1),
            ),
            child: Column(
              children: [
                _buildSettingTile(
                  icon: LucideIcons.lock,
                  title: 'Change Password',
                  subtitle: 'Update your password',
                  onTap: () {},
                ),
                _buildDivider(),
                _buildSettingTile(
                  icon: LucideIcons.smartphone,
                  title: 'My Devices',
                  subtitle: 'View registered devices',
                  onTap: () {},
                ),
                _buildDivider(),
                _buildSettingTile(
                  icon: LucideIcons.creditCard,
                  title: 'Payment Methods',
                  subtitle: 'Manage saved payment methods',
                  onTap: () {},
                ),
                _buildDivider(),
                _buildSettingTile(
                  icon: LucideIcons.helpCircle,
                  title: 'Help & Support',
                  subtitle: 'Get help with your account',
                  onTap: () {},
                ),
                _buildDivider(),
                _buildSettingTile(
                  icon: LucideIcons.logOut,
                  title: 'Log Out',
                  subtitle: 'Sign out of your account',
                  onTap: () {},
                  isDestructive: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDestructive
                    ? Colors.red.withOpacity(0.1)
                    : AppColors.primaryButton.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 24,
                color: isDestructive ? Colors.red : AppColors.primaryButton,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDestructive ? Colors.red : AppColors.textHeading,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textBody,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              size: 20,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.shade200,
      indent: 68,
    );
  }
}
