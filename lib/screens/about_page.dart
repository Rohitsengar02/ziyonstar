import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme.dart';
import '../responsive.dart';
import '../widgets/navbar.dart';
import '../widgets/app_drawer.dart';
import '../widgets/footer.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveLayout.isDesktop(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: isDesktop
          ? null
          : AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(LucideIcons.arrowLeft, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'About Us',
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
            ),
      drawer: const AppDrawer(),
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

            // Hero Section
            _buildHeroSection(isDesktop),

            // Mission & Vision
            _buildMissionVision(isDesktop),

            // Stats Section
            _buildStatsSection(isDesktop),

            // Services
            _buildServicesSection(isDesktop),

            // Why Choose Us
            _buildWhyChooseUs(isDesktop),

            // Team Section
            _buildTeamSection(isDesktop),

            // Footer
            if (isDesktop) const Footer(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(bool isDesktop) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : 20,
        vertical: isDesktop ? 100 : 60,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryButton.withOpacity(0.05),
            Colors.white,
            const Color(0xFFF9FAFB),
          ],
        ),
      ),
      child: isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 5, child: _buildHeroContent()),
                const SizedBox(width: 60),
                Expanded(flex: 5, child: _buildHeroImage()),
              ],
            )
          : Column(
              children: [
                _buildHeroContent(),
                const SizedBox(height: 40),
                _buildHeroImage(),
              ],
            ),
    );
  }

  Widget _buildHeroContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About Ziyonstar',
          style: GoogleFonts.poppins(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: AppColors.textHeading,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Your Trusted Partner in Device Repair Excellence',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryButton,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'We are a leading device repair service provider dedicated to bringing your devices back to life with expert care and precision. With years of experience and a team of certified technicians, we ensure quality repairs at your doorstep.',
          style: GoogleFonts.inter(
            fontSize: 16,
            color: AppColors.textBody,
            height: 1.7,
          ),
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryButton.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                LucideIcons.shield,
                color: AppColors.primaryButton,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                '100% Genuine Parts\n& 1 Year Warranty',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textHeading,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroImage() {
    return Container(
      width: 500,
      height: 500,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryButton.withOpacity(0.3),
            AppColors.primaryButton.withOpacity(0.1),
            Colors.purple.withOpacity(0.2),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset('assets/images/hero_hand.png', fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget _buildMissionVision(bool isDesktop) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : 20,
        vertical: isDesktop ? 80 : 60,
      ),
      child: isDesktop
          ? Row(
              children: [
                Expanded(child: _buildMissionCard()),
                const SizedBox(width: 40),
                Expanded(child: _buildVisionCard()),
              ],
            )
          : Column(
              children: [
                _buildMissionCard(),
                const SizedBox(height: 24),
                _buildVisionCard(),
              ],
            ),
    );
  }

  Widget _buildMissionCard() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              LucideIcons.target,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Our Mission',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'To provide fast, reliable, and affordable device repair services that exceed customer expectations. We aim to make quality repairs accessible to everyone.',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisionCard() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF059669), Color(0xFF10B981)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(LucideIcons.eye, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 24),
          Text(
            'Our Vision',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'To become the most trusted name in device repair across the nation, known for innovation, quality, and exceptional customer service.',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(bool isDesktop) {
    final stats = [
      {'number': '50K+', 'label': 'Happy Customers', 'icon': LucideIcons.users},
      {'number': '100K+', 'label': 'Repairs Done', 'icon': LucideIcons.wrench},
      {
        'number': '98%',
        'label': 'Success Rate',
        'icon': LucideIcons.trendingUp,
      },
      {'number': '24/7', 'label': 'Support', 'icon': LucideIcons.headphones},
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : 20,
        vertical: isDesktop ? 60 : 40,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFFF9FAFB), Colors.white],
        ),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isDesktop ? 4 : 2,
          mainAxisSpacing: 24,
          crossAxisSpacing: 24,
          childAspectRatio: isDesktop ? 1.2 : 1.1,
        ),
        itemCount: stats.length,
        itemBuilder: (context, index) {
          return Container(
            padding: EdgeInsets.all(isDesktop ? 24 : 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primaryButton.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(
                    255,
                    177,
                    27,
                    179,
                  ).withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  stats[index]['icon'] as IconData,
                  size: isDesktop ? 40 : 32,
                  color: AppColors.primaryButton,
                ),
                SizedBox(height: isDesktop ? 16 : 12),
                Text(
                  stats[index]['number'] as String,
                  style: GoogleFonts.poppins(
                    fontSize: isDesktop ? 32 : 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textHeading,
                  ),
                ),
                SizedBox(height: isDesktop ? 8 : 6),
                Text(
                  stats[index]['label'] as String,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: isDesktop ? 14 : 12,
                    color: AppColors.textBody,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildServicesSection(bool isDesktop) {
    final services = [
      {
        'icon': LucideIcons.smartphone,
        'title': 'Mobile Repair',
        'description':
            'Expert repair for all smartphone brands including screen, battery, and more.',
      },
      {
        'icon': LucideIcons.laptop,
        'title': 'Laptop Repair',
        'description':
            'Professional laptop servicing and hardware upgrades for all models.',
      },
      {
        'icon': LucideIcons.tablet,
        'title': 'Tablet Repair',
        'description':
            'Fast and reliable repairs for iPads and Android tablets.',
      },
      {
        'icon': LucideIcons.home,
        'title': 'Doorstep Service',
        'description':
            'Get your device repaired at your home or office for your convenience.',
      },
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : 20,
        vertical: isDesktop ? 80 : 60,
      ),
      color: Colors.white,
      child: Column(
        children: [
          Text(
            'Our Services',
            style: GoogleFonts.poppins(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: AppColors.textHeading,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Comprehensive repair solutions for all your devices',
            style: GoogleFonts.inter(fontSize: 16, color: AppColors.textBody),
          ),
          const SizedBox(height: 48),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isDesktop ? 4 : 2,
              mainAxisSpacing: 24,
              crossAxisSpacing: 24,
              childAspectRatio: isDesktop ? 0.9 : 0.85,
            ),
            itemCount: services.length,
            itemBuilder: (context, index) {
              return Container(
                padding: EdgeInsets.all(isDesktop ? 28 : 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(isDesktop ? 16 : 12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryButton.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        services[index]['icon'] as IconData,
                        size: isDesktop ? 32 : 28,
                        color: AppColors.primaryButton,
                      ),
                    ),
                    SizedBox(height: isDesktop ? 20 : 16),
                    Text(
                      services[index]['title'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: isDesktop ? 18 : 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textHeading,
                      ),
                    ),
                    SizedBox(height: isDesktop ? 12 : 10),
                    Text(
                      services[index]['description'] as String,
                      style: GoogleFonts.inter(
                        fontSize: isDesktop ? 14 : 13,
                        color: AppColors.textBody,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWhyChooseUs(bool isDesktop) {
    final reasons = [
      {
        'icon': LucideIcons.award,
        'title': 'Certified Experts',
        'description':
            'All our technicians are factory-trained and certified professionals.',
      },
      {
        'icon': LucideIcons.shield,
        'title': 'Genuine Parts',
        'description': 'We only use 100% genuine parts with 1-year warranty.',
      },
      {
        'icon': LucideIcons.zap,
        'title': 'Fast Service',
        'description': 'Same-day repair service for most common issues.',
      },
      {
        'icon': LucideIcons.dollarSign,
        'title': 'Best Prices',
        'description': 'Competitive pricing with no hidden charges.',
      },
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : 20,
        vertical: isDesktop ? 80 : 60,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0xFFF9FAFB), Colors.white],
        ),
      ),
      child: Column(
        children: [
          Text(
            'Why Choose Ziyonstar?',
            style: GoogleFonts.poppins(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: AppColors.textHeading,
            ),
          ),
          const SizedBox(height: 48),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isDesktop ? 4 : 1,
              mainAxisSpacing: 24,
              crossAxisSpacing: 24,
              childAspectRatio: isDesktop ? 0.95 : 2.5,
            ),
            itemCount: reasons.length,
            itemBuilder: (context, index) {
              return Container(
                padding: EdgeInsets.all(isDesktop ? 32 : 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color.fromARGB(
                      255,
                      127,
                      127,
                      127,
                    ).withOpacity(0.1),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryButton.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(isDesktop ? 20 : 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryButton,
                            AppColors.primaryButton.withOpacity(0.7),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        reasons[index]['icon'] as IconData,
                        size: isDesktop ? 32 : 28,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: isDesktop ? 20 : 16),
                    Text(
                      reasons[index]['title'] as String,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: isDesktop ? 18 : 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textHeading,
                      ),
                    ),
                    SizedBox(height: isDesktop ? 12 : 10),
                    Text(
                      reasons[index]['description'] as String,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: isDesktop ? 14 : 13,
                        color: AppColors.textBody,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTeamSection(bool isDesktop) {
    final teamMembers = [
      {
        'name': 'David Miller',
        'role': 'Senior Technician',
        'image': 'assets/images/tech_avatar_1.png',
      },
      {
        'name': 'Maria Garcia',
        'role': 'Hardware Specialist',
        'image': 'assets/images/tech_avatar_2.png',
      },
      {
        'name': 'Robert Fox',
        'role': 'Master Technician',
        'image': 'assets/images/tech_avatar_3.png',
      },
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : 20,
        vertical: isDesktop ? 80 : 60,
      ),
      color: Colors.white,
      child: Column(
        children: [
          Text(
            'Meet Our Expert Team',
            style: GoogleFonts.poppins(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: AppColors.textHeading,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Passionate professionals dedicated to excellence',
            style: GoogleFonts.inter(fontSize: 16, color: AppColors.textBody),
          ),
          const SizedBox(height: 48),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isDesktop ? 3 : 1,
              mainAxisSpacing: 24,
              crossAxisSpacing: 24,
              childAspectRatio: isDesktop ? 0.95 : 1.3,
            ),
            itemCount: teamMembers.length,
            itemBuilder: (context, index) {
              return Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [const Color(0xFFF9FAFB), const Color(0xFFEFF6FF)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.primaryButton.withOpacity(0.1),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryButton.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primaryButton,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryButton.withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          teamMembers[index]['image']!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      teamMembers[index]['name']!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textHeading,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      teamMembers[index]['role']!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textBody,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFEFF6FF), Color(0xFFF9FAFB)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  LucideIcons.users,
                  size: 40,
                  color: AppColors.primaryButton.withOpacity(0.7),
                ),
                const SizedBox(width: 16),
                Flexible(
                  child: Text(
                    'Plus 47+ more certified technicians ready to serve you',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: AppColors.textBody,
                      fontWeight: FontWeight.w500,
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
}
