import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import 'contact_admin_page.dart';
import 'login_screen.dart';
import 'profile/personal_info_screen.dart';
import 'profile/kyc_documents_screen.dart';
import 'profile/skills_expertise_screen.dart';
import 'profile/service_areas_screen.dart';
import 'profile/bank_details_screen.dart';
import 'profile/subscription_fees_screen.dart';
import 'profile/notifications_prefs_screen.dart';
import 'profile/terms_conditions_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _apiService = ApiService();
  Map<String, dynamic>? _technician;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTechnicianData();
  }

  Future<void> _fetchTechnicianData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final data = await _apiService.getTechnician(user.uid);
        if (mounted) {
          setState(() {
            _technician = data;
            _isLoading = false;
          });
        }
      } catch (e) {
        debugPrint('Error fetching technician: $e');
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _updatePhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _isLoading = true);
      try {
        final url = await _apiService.uploadImage(image);
        if (url != null) {
          await _apiService.updateTechnicianProfile(
            firebaseUid: _technician!['firebaseUid'],
            data: {'photoUrl': url},
          );
          _fetchTechnicianData();
        }
      } catch (e) {
        debugPrint('Error updating photo: $e');
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth >= 900;

        if (_isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (_technician == null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Failed to load profile data'),
                  TextButton(
                    onPressed: _fetchTechnicianData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF6F8FA),
          appBar: isDesktop
              ? null
              : AppBar(
                  title: Text(
                    'Profile',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  centerTitle: false,
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  actions: [
                    IconButton(
                      onPressed: () => _fetchTechnicianData(),
                      icon: const Icon(LucideIcons.refreshCw, size: 20),
                    ),
                  ],
                ),
          body: RefreshIndicator(
            onRefresh: _fetchTechnicianData,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 900),
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 40 : 20,
                    vertical: isDesktop ? 40 : 20,
                  ),
                  child: Column(
                    children: [
                      // Profile Header
                      _buildProfileHeader(isDesktop),
                      const SizedBox(height: 40),

                      if (isDesktop)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  _buildMenuGroup('Account Settings', [
                                    _buildMenuItem(
                                      LucideIcons.user,
                                      'Personal Information',
                                      'Name, Email, Phone',
                                      onTap: () async {
                                        final updated = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                PersonalInformationScreen(
                                                  technicianData: _technician!,
                                                ),
                                          ),
                                        );
                                        if (updated == true)
                                          _fetchTechnicianData();
                                      },
                                    ),
                                    _buildMenuItem(
                                      LucideIcons.shieldCheck,
                                      'KYC Documents',
                                      _technician!['status'] == 'approved'
                                          ? 'Verified'
                                          : 'Status: ${_technician!['status']}',
                                      trailing:
                                          _technician!['status'] == 'approved'
                                          ? const Icon(
                                              LucideIcons.checkCircle,
                                              color: Colors.green,
                                              size: 18,
                                            )
                                          : const Icon(
                                              LucideIcons.clock,
                                              color: Colors.orange,
                                              size: 18,
                                            ),
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              KycDocumentsScreen(
                                                technicianData: _technician!,
                                              ),
                                        ),
                                      ),
                                    ),
                                    _buildMenuItem(
                                      LucideIcons.briefcase,
                                      'Skills & Expertise',
                                      '${(_technician!['brandExpertise'] as List?)?.length ?? 0} Brands, ${(_technician!['repairExpertise'] as List?)?.length ?? 0} Repairs',
                                      onTap: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                SkillsExpertiseScreen(
                                                  technicianData: _technician!,
                                                ),
                                          ),
                                        );
                                        _fetchTechnicianData();
                                      },
                                    ),
                                    _buildMenuItem(
                                      LucideIcons.mapPin,
                                      'Service Areas',
                                      '${(_technician!['coverageAreas'] as List?)?.length ?? 0} Areas covered',
                                      onTap: () async {
                                        final updated = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ServiceAreasScreen(
                                                  technicianData: _technician!,
                                                ),
                                          ),
                                        );
                                        if (updated == true)
                                          _fetchTechnicianData();
                                      },
                                    ),
                                  ]),
                                ],
                              ),
                            ),
                            const SizedBox(width: 40),
                            Expanded(
                              child: Column(
                                children: [
                                  _buildMenuGroup('Financials', [
                                    _buildMenuItem(
                                      LucideIcons.building,
                                      'Bank Details',
                                      _technician!['bankName'] ??
                                          'Payout bank account',
                                      onTap: () async {
                                        final updated = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                BankDetailsScreen(
                                                  technicianData: _technician!,
                                                ),
                                          ),
                                        );
                                        if (updated == true)
                                          _fetchTechnicianData();
                                      },
                                    ),
                                    _buildMenuItem(
                                      LucideIcons.creditCard,
                                      'Subscription / Fees',
                                      'Platform fee settings',
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              SubscriptionFeesScreen(
                                                technicianData: _technician!,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ]),
                                  _buildMenuGroup('Support', [
                                    _buildMenuItem(
                                      LucideIcons.bell,
                                      'Notifications',
                                      'Order and system alerts',
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const NotificationsPrefsScreen(),
                                        ),
                                      ),
                                    ),
                                    _buildMenuItem(
                                      LucideIcons.helpCircle,
                                      'Help & Support',
                                      'FAQs, Chat with admin',
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const ContactAdminPage(),
                                        ),
                                      ),
                                    ),
                                  ]),
                                ],
                              ),
                            ),
                          ],
                        )
                      else ...[
                        _buildMenuGroup('Account Settings', [
                          _buildMenuItem(
                            LucideIcons.user,
                            'Personal Information',
                            'Name, Email, Phone',
                            onTap: () async {
                              final updated = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PersonalInformationScreen(
                                        technicianData: _technician!,
                                      ),
                                ),
                              );
                              if (updated == true) _fetchTechnicianData();
                            },
                          ),
                          _buildMenuItem(
                            LucideIcons.shieldCheck,
                            'KYC Documents',
                            _technician!['status'] == 'approved'
                                ? 'Verified'
                                : 'Status: ${_technician!['status']}',
                            trailing: _technician!['status'] == 'approved'
                                ? const Icon(
                                    LucideIcons.checkCircle,
                                    color: Colors.green,
                                    size: 18,
                                  )
                                : const Icon(
                                    LucideIcons.clock,
                                    color: Colors.orange,
                                    size: 18,
                                  ),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => KycDocumentsScreen(
                                  technicianData: _technician!,
                                ),
                              ),
                            ),
                          ),
                          _buildMenuItem(
                            LucideIcons.briefcase,
                            'Skills & Expertise',
                            '${(_technician!['brandExpertise'] as List?)?.length ?? 0} Brands, ${(_technician!['repairExpertise'] as List?)?.length ?? 0} Repairs',
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SkillsExpertiseScreen(
                                    technicianData: _technician!,
                                  ),
                                ),
                              );
                              _fetchTechnicianData();
                            },
                          ),
                          _buildMenuItem(
                            LucideIcons.mapPin,
                            'Service Areas',
                            '${(_technician!['coverageAreas'] as List?)?.length ?? 0} Areas covered',
                            onTap: () async {
                              final updated = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ServiceAreasScreen(
                                    technicianData: _technician!,
                                  ),
                                ),
                              );
                              if (updated == true) _fetchTechnicianData();
                            },
                          ),
                        ]),
                        _buildMenuGroup('Financials', [
                          _buildMenuItem(
                            LucideIcons.building,
                            'Bank Details',
                            _technician!['bankName'] ?? 'Payout bank account',
                            onTap: () async {
                              final updated = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BankDetailsScreen(
                                    technicianData: _technician!,
                                  ),
                                ),
                              );
                              if (updated == true) _fetchTechnicianData();
                            },
                          ),
                          _buildMenuItem(
                            LucideIcons.creditCard,
                            'Subscription / Fees',
                            'Platform fee settings',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SubscriptionFeesScreen(
                                  technicianData: _technician!,
                                ),
                              ),
                            ),
                          ),
                        ]),
                        _buildMenuGroup('Preferences & Support', [
                          _buildMenuItem(
                            LucideIcons.bell,
                            'Notifications',
                            'Order and system alerts',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const NotificationsPrefsScreen(),
                              ),
                            ),
                          ),
                          _buildMenuItem(
                            LucideIcons.helpCircle,
                            'Help & Support',
                            'FAQs, Chat with admin',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ContactAdminPage(),
                              ),
                            ),
                          ),
                          _buildMenuItem(
                            LucideIcons.messageSquare,
                            'Contact Admin',
                            'Direct support for technicians',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ContactAdminPage(),
                              ),
                            ),
                          ),
                          _buildMenuItem(
                            LucideIcons.fileText,
                            'Terms & Conditions',
                            'Legal agreements',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const TermsConditionsScreen(),
                              ),
                            ),
                          ),
                        ]),
                      ],

                      const SizedBox(height: 40),
                      // Logout
                      SizedBox(
                        width: isDesktop ? 300 : double.infinity,
                        child: ElevatedButton(
                          onPressed: _logout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.red,
                            elevation: 0,
                            side: const BorderSide(
                              color: Colors.red,
                              width: 1.5,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(LucideIcons.logOut, size: 20),
                              const SizedBox(width: 12),
                              Text(
                                'Logout Account',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(bool isDesktop) {
    final photoUrl = _technician!['photoUrl'];
    return Column(
      children: [
        GestureDetector(
          onTap: _updatePhoto,
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                      ? NetworkImage(photoUrl)
                      : null,
                  child: photoUrl == null || photoUrl.isEmpty
                      ? const Icon(
                          LucideIcons.user,
                          size: 40,
                          color: Colors.grey,
                        )
                      : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.camera,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _technician!['name'] ?? 'No Name',
          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 18),
            const SizedBox(width: 4),
            Text(
              '4.8', // Rating could be added to model later
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              ' (850 Repairs)', // Statistics could be added to model later
              style: GoogleFonts.inter(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuGroup(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Text(
            title.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1,
            ),
          ),
        ),
        ...items,
        const Divider(height: 1),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    String sub, {
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap ?? () {},
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.black, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15),
      ),
      subtitle: Text(
        sub,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(color: Colors.grey, fontSize: 13),
      ),
      trailing:
          trailing ??
          const Icon(LucideIcons.chevronRight, size: 18, color: Colors.grey),
    );
  }
}
