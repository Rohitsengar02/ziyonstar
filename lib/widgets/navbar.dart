import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';
import '../responsive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Navbar extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  static final ValueNotifier<bool> locationRefreshNotifier =
      ValueNotifier<bool>(false);

  const Navbar({super.key, required this.scaffoldKey});

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  String _currentLocation = 'Select Location';
  List<dynamic> _savedAddresses = [];
  bool _isLoadingLocation = false;
  final ApiService _apiService = ApiService();
  StreamSubscription<User?>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _loadSavedLocation();
    _fetchUserAddresses();

    // Listen for auth changes to fetch addresses when user logs in
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _fetchUserAddresses();
      } else {
        setState(() {
          _savedAddresses = [];
        });
      }
    });

    // Listen for manual location refreshes
    Navbar.locationRefreshNotifier.addListener(_onLocationRefresh);
  }

  void _onLocationRefresh() {
    if (mounted) {
      _loadSavedLocation();
      _fetchUserAddresses();
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    Navbar.locationRefreshNotifier.removeListener(_onLocationRefresh);
    super.dispose();
  }

  Future<void> _loadSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentLocation =
          prefs.getString('selected_location_label') ??
          prefs.getString('selected_location_name') ??
          'Select Location';
    });
  }

  Future<void> _fetchUserAddresses() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoadingLocation = true);
    try {
      final addresses = await _apiService.getAddresses(user.uid);

      if (addresses.isEmpty) {
        final mongoUser = await _apiService.getUser(user.uid);
        if (mongoUser != null) {
          final mongoAddresses = await _apiService.getAddresses(
            mongoUser['_id'],
          );
          if (mongoAddresses.isNotEmpty) {
            setState(() {
              _savedAddresses = mongoAddresses;
            });
            return;
          }
        }
      }

      setState(() {
        _savedAddresses = addresses;
      });
    } catch (e) {
      debugPrint('Error fetching addresses in Navbar: $e');
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _selectAddress(Map<String, dynamic> address) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_location_label', address['label']);
    await prefs.setString('selected_location_address', address['fullAddress']);
    await prefs.setString('selected_location_id', address['_id']);

    setState(() {
      _currentLocation = address['label'];
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location updated to ${address['label']}'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showLocationPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(LucideIcons.mapPin, color: AppColors.primaryButton),
            const SizedBox(width: 12),
            Text(
              'Select Location',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Container(
          width: 400,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (_savedAddresses.isEmpty && !_isLoadingLocation)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Column(
                            children: [
                              Icon(
                                LucideIcons.map,
                                size: 48,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No saved locations found',
                                style: GoogleFonts.inter(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (_isLoadingLocation)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: CircularProgressIndicator(),
                        ),
                      ..._savedAddresses.map((addr) {
                        final bool isSelected =
                            _currentLocation == addr['label'];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                            onTap: () {
                              _selectAddress(addr);
                              Navigator.pop(context);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryButton.withOpacity(0.05)
                                    : Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primaryButton.withOpacity(0.3)
                                      : Colors.transparent,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    addr['label'] == 'Home'
                                        ? LucideIcons.home
                                        : addr['label'] == 'Work'
                                        ? LucideIcons.briefcase
                                        : LucideIcons.mapPin,
                                    size: 18,
                                    color: isSelected
                                        ? AppColors.primaryButton
                                        : Colors.grey[600],
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          addr['label'],
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.bold,
                                            color: isSelected
                                                ? AppColors.primaryButton
                                                : AppColors.textHeading,
                                          ),
                                        ),
                                        Text(
                                          addr['fullAddress'],
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(
                                      Icons.check_circle,
                                      color: AppColors.primaryButton,
                                      size: 18,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      await context.push('/address-picker?userId=${user.uid}');
                      _fetchUserAddresses();
                    } else {
                      context.push('/login');
                    }
                  },
                  icon: const Icon(LucideIcons.plus, size: 18),
                  label: const Text('Add New Location'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryButton,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveLayout.isDesktop(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100),
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
          Row(
            children: [
              InkWell(
                onTap: () {
                  context.go('/');
                },
                child: Row(
                  children: [
                    Container(
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset(
                        'assets/images/app_logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
              if (isDesktop) ...[
                const SizedBox(width: 32),
                Container(height: 24, width: 1, color: Colors.grey.shade200),
                const SizedBox(width: 24),
                // Location Selector
                InkWell(
                  onTap: () => _showLocationPicker(context),
                  borderRadius: BorderRadius.circular(30),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.heroBg,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: AppColors.primaryButton.withOpacity(0.1),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          LucideIcons.mapPin,
                          size: 16,
                          color: AppColors.accentRed,
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Service Location',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[500],
                              ),
                            ),
                            Text(
                              _currentLocation,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textHeading,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.keyboard_arrow_down,
                          size: 18,
                          color: AppColors.textBody,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (isDesktop)
            Row(
              children: [
                _navLink(
                  'Home',
                  active: true,
                  onPressed: () => context.go('/'),
                ),
                _navLink('Repair', onPressed: () => context.go('/repair')),
                _navLink('About', onPressed: () => context.go('/about')),
                _navLink('Bookings', onPressed: () => context.go('/bookings')),
                _navLink('Contact', onPressed: () => context.go('/contact')),
              ],
            ),
          StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              final user = snapshot.data;
              final isLoggedIn = user != null;

              return Row(
                children: [
                  if (isLoggedIn) ...[
                    InkWell(
                      onTap: () {
                        context.push('/profile');
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primaryButton,
                              AppColors.primaryButton.withOpacity(0.7),
                            ],
                          ),
                          border: Border.all(
                            color: AppColors.primaryButton.withOpacity(0.2),
                            width: 2,
                          ),
                          image: user.photoURL != null
                              ? DecorationImage(
                                  image: NetworkImage(user.photoURL!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: user.photoURL == null
                            ? const Center(
                                child: Icon(
                                  LucideIcons.user,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ] else ...[
                    TextButton(
                      onPressed: () => context.push('/login'),
                      child: Text(
                        'Sign In',
                        style: GoogleFonts.inter(
                          color: AppColors.textHeading,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  if (isDesktop) ...[
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (isLoggedIn) {
                          context.push('/repair');
                        } else {
                          context.push('/login');
                        }
                      },
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
                      child: Text(isLoggedIn ? 'Book Now' : 'Get Started'),
                    ),
                  ],
                  if (!isDesktop)
                    IconButton(
                      onPressed: () {
                        widget.scaffoldKey.currentState?.openDrawer();
                      },
                      icon: const Icon(
                        LucideIcons.menu,
                        color: AppColors.textHeading,
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _navLink(String text, {bool active = false, VoidCallback? onPressed}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: TextButton(
        onPressed: onPressed ?? () {},
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
