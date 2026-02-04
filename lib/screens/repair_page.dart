import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme.dart';
import '../responsive.dart';

import '../widgets/navbar.dart';
import '../widgets/footer.dart';
import '../widgets/app_drawer.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'booking_success_screen.dart';
import 'address_picker_screen.dart';
import 'sign_in_screen.dart';

class RepairPage extends StatefulWidget {
  final String deviceBrand;
  final String deviceModel;
  final Map<String, dynamic>? modelData;
  final String? initialIssue;

  const RepairPage({
    super.key,
    this.deviceBrand = 'Apple',
    this.deviceModel = 'iPhone 13 Pro',
    this.modelData,
    this.initialIssue,
  });

  @override
  State<RepairPage> createState() => _RepairPageState();
}

class _RepairPageState extends State<RepairPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Removed - now using _currentStep instead

  String _currentBrand = '';
  String _currentModel = '';
  Map<String, dynamic>? _modelData;
  List<dynamic> _brandModels = []; // Models for selected brand
  bool _isLoadingModels = false;

  final Set<String> _selectedIssues = {};
  final ApiService _apiService = ApiService();
  List<dynamic> _apiIssues = [];
  List<dynamic> _apiBrands = [];
  bool _isLoading = true;

  // Step 0: Brand, Step 1: Model, Step 2: Issues, Step 3: Technician, Step 4: Schedule
  int _currentStep = 0;
  List<dynamic> _apiTechnicians = [];
  bool _isLoadingTechs = false;
  List<dynamic> _savedAddresses = [];
  bool _isLoadingAddresses = false;
  int? _selectedTechIndex;
  DateTime _selectedDate = DateTime.now();
  String? _selectedTimeSlot;
  Map<String, dynamic>? _selectedAddress;
  String _currentPaymentMethod = 'Cash on Delivery';
  String _userId = 'guest_user';
  String _userName = 'App User';
  String _userEmail = '';
  bool _isBookingLoading = false;

  final List<String> _timeSlots = [
    '09:00 AM - 10:00 AM',
    '10:00 AM - 11:00 AM',
    '11:00 AM - 12:00 PM',
    '12:00 PM - 01:00 PM',
    '01:00 PM - 02:00 PM',
    '02:00 PM - 03:00 PM',
    '03:00 PM - 04:00 PM',
    '04:00 PM - 05:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    _currentBrand = widget.deviceBrand;
    _currentModel = widget.deviceModel;
    _modelData = widget.modelData;

    // If brand and model are provided, skip to issues step
    if (_currentBrand.isNotEmpty && _currentModel.isNotEmpty) {
      _currentStep = 2; // Jump to issues step
    }

    if (widget.initialIssue != null && widget.initialIssue!.isNotEmpty) {
      _selectedIssues.add(widget.initialIssue!);
    }

    _initUserInfo();
    _fetchBrands();
    _fetchIssues();
  }

  Future<void> _initUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userId = user.uid;
        _userName = user.displayName ?? 'App User';
        _userEmail = user.email ?? '';
      });
    } else {
      final prefs = await SharedPreferences.getInstance();
      String? storedId =
          prefs.getString('user_uid') ?? prefs.getString('user_id');
      if (storedId == null) {
        storedId = 'user_${DateTime.now().millisecondsSinceEpoch}';
        await prefs.setString('user_id', storedId);
      }
      setState(() {
        _userId = storedId!;
        _userName = prefs.getString('user_name') ?? 'App User';
        _userEmail = prefs.getString('user_email') ?? 'user_$_userId@ziyon.com';
      });
    }
  }

  Future<void> _fetchTechnicians() async {
    setState(() => _isLoadingTechs = true);
    try {
      final techs = await _apiService.getTechnicians();
      if (mounted) {
        setState(() {
          _apiTechnicians = techs
              .where(
                (t) => t['status'] == 'approved' || t['status'] == 'active',
              )
              .toList();
          _isLoadingTechs = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching technicians: $e');
      if (mounted) setState(() => _isLoadingTechs = false);
    }
  }

  Future<void> _fetchAddresses() async {
    setState(() => _isLoadingAddresses = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLocationId = prefs.getString('selected_location_id');

      final addresses = await _apiService.getAddresses(_userId);
      if (mounted) {
        setState(() {
          _savedAddresses = addresses;
          _isLoadingAddresses = false;

          if (_savedAddresses.isNotEmpty) {
            // 1. Try to find the globally selected address
            if (savedLocationId != null) {
              final selected = _savedAddresses.firstWhere(
                (a) => a['_id'] == savedLocationId,
                orElse: () => {},
              );
              if (selected.isNotEmpty) {
                _selectedAddress = selected;
                return;
              }
            }

            // 2. Fallback to default or first
            if (_selectedAddress == null) {
              final defaultAddr = _savedAddresses.firstWhere(
                (a) => a['isDefault'] == true,
                orElse: () => _savedAddresses.first,
              );
              _selectedAddress = defaultAddr;
            }
          }
        });
      }
    } catch (e) {
      debugPrint('Error fetching addresses: $e');
    }
  }

  bool get _isLoggedIn => FirebaseAuth.instance.currentUser != null;

  void _showLoginPrompt() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Login Required',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Please login to continue with your booking and save your addresses.',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SignInScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryButton,
            ),
            child: Text('Login Now'),
          ),
        ],
      ),
    );
  }

  // Helper methods for step-based navigation
  VoidCallback? _getNextStepAction() {
    if (_isBookingLoading) return null;

    switch (_currentStep) {
      case 0: // Brand selection
        return null; // No button needed, click on brand to proceed
      case 1: // Model selection
        return null; // No button needed, click on model to proceed
      case 2: // Issues selection
        return _selectedIssues.isEmpty
            ? null
            : () {
                setState(() => _currentStep = 3);
                _fetchTechnicians();
              };
      case 3: // Technician selection
        return _selectedTechIndex == null
            ? null
            : () {
                setState(() => _currentStep = 4);
                _fetchAddresses();
              };
      case 4: // Schedule & address
        return (_selectedTimeSlot == null || _selectedAddress == null)
            ? null
            : _confirmBooking;
      default:
        return null;
    }
  }

  String _getNextStepLabel() {
    switch (_currentStep) {
      case 0:
        return 'Select a Brand';
      case 1:
        return 'Select a Model';
      case 2:
        return 'Next: Choose Technician';
      case 3:
        return 'Next: Schedule Appointment';
      case 4:
        return 'Confirm Booking';
      default:
        return 'Next Step';
    }
  }

  Future<void> _confirmBooking() async {
    if (!_isLoggedIn) {
      _showLoginPrompt();
      return;
    }
    if (_selectedTechIndex == null || _selectedTimeSlot == null) return;
    setState(() => _isBookingLoading = true);

    try {
      final technician = _apiTechnicians[_selectedTechIndex!];
      String dbUserId;

      // 1. Verify User
      final userData = {
        'name': _userName,
        'email': _userEmail,
        'firebaseUid': _userId,
        'phone': _selectedAddress?['phone'] ?? '',
      };

      final userResult = await _apiService.registerUser(userData);
      if (userResult != null && userResult['user'] != null) {
        dbUserId = userResult['user']['_id'];
      } else {
        throw 'User registration failed';
      }

      // 2. Create Booking
      final bookingData = {
        'userId': dbUserId,
        'technicianId': technician['_id'],
        'deviceBrand': _currentBrand,
        'deviceModel': _currentModel,
        'issues': _selectedIssues
            .map(
              (i) => {
                'issueName': i,
                'price': 0, // Simplified for now
              },
            )
            .toList(),
        'totalPrice': _calculateTotal().toDouble(),
        'scheduledDate': _selectedDate.toIso8601String(),
        'timeSlot': _selectedTimeSlot,
        'addressDetails':
            _selectedAddress?['fullAddress'] ?? 'No address provided',
        'address': _selectedAddress?['_id'],
        'paymentStatus': 'Pending',
        'status': 'Pending_Assignment',
      };

      final result = await _apiService.createBooking(bookingData);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BookingSuccessScreen(
              deviceName: '$_currentBrand $_currentModel',
              technicianName: technician['name'] ?? 'Technician',
              technicianImage: technician['photoUrl'] ?? '',
              selectedIssues: _selectedIssues.toList(),
              timeSlot: _selectedTimeSlot!,
              date: _selectedDate,
              amount: _calculateTotal().toDouble(),
              otp: result?['otp']?.toString() ?? '000000',
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Booking confirmation failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to book: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isBookingLoading = false);
    }
  }

  Future<void> _fetchModelData() async {
    try {
      // Get brand to find its ID
      final brands = await _apiService.getBrands();
      final brand = brands.firstWhere(
        (b) => b['title'] == _currentBrand,
        orElse: () => null,
      );
      if (brand != null) {
        final models = await _apiService.getModels(brand['_id']);
        final model = models.firstWhere(
          (m) => m['name'] == _currentModel,
          orElse: () => null,
        );
        if (mounted && model != null) {
          setState(() {
            _modelData = model;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching model data: $e');
    }
  }

  Future<void> _fetchBrands() async {
    try {
      final brands = await _apiService.getBrands();
      if (mounted) {
        setState(() {
          _apiBrands = brands;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching brands: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  IconData _getIcon(String? iconName) {
    switch (iconName) {
      case 'smartphone':
        return LucideIcons.smartphone;
      case 'battery':
        return LucideIcons.battery;
      case 'plug':
        return LucideIcons.plug;
      case 'camera':
        return LucideIcons.camera;
      case 'speaker':
        return LucideIcons.speaker;
      case 'cpu':
        return LucideIcons.cpu;
      case 'droplet':
        return LucideIcons.droplet;
      case 'scanFace':
        return LucideIcons.scanFace;
      case 'hardDrive':
        return LucideIcons.hardDrive;
      case 'wrench':
        return LucideIcons.wrench;
      case 'mic':
        return LucideIcons.mic;
      default:
        return LucideIcons.wrench;
    }
  }

  // Helper function to safely parse API values to int
  int _parseToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      final cleanValue = value.replaceAll('%', '').trim();
      return int.tryParse(cleanValue) ?? 0;
    }
    return 0;
  }

  void _showChangeModelDialog() {
    final bool isDesktop = ResponsiveLayout.isDesktop(context);
    String tempBrand = _currentBrand;
    String tempModel = _currentModel;
    List<dynamic> models = [];
    bool isLoadingModels = false;

    Future<void> fetchModels(String brandId, StateSetter setStateDialog) async {
      setStateDialog(() => isLoadingModels = true);
      try {
        final fetchedModels = await _apiService.getModels(brandId);
        setStateDialog(() {
          models = fetchedModels;
          isLoadingModels = false;
        });
      } catch (e) {
        debugPrint('Error fetching models: $e');
        setStateDialog(() => isLoadingModels = false);
      }
    }

    Widget buildDesktopDialog(StateSetter setStateDialog) {
      return Container(
        width: 900,
        height: 600,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            // Left Side: Brands
            Container(
              width: 250,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(right: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Select Brand',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textHeading,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _apiBrands.length,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemBuilder: (context, index) {
                        final brand = _apiBrands[index];
                        final isSelected = tempBrand == brand['title'];
                        return ListTile(
                          onTap: () {
                            setStateDialog(() {
                              tempBrand = brand['title'];
                              tempModel = ''; // Reset model
                            });
                            fetchModels(brand['_id'], setStateDialog);
                          },
                          leading: Icon(
                            LucideIcons.smartphone,
                            size: 18,
                            color: isSelected
                                ? AppColors.primaryButton
                                : Colors.grey,
                          ),
                          title: Text(
                            brand['title'] ?? '',
                            style: GoogleFonts.inter(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? AppColors.primaryButton
                                  : AppColors.textHeading,
                            ),
                          ),
                          selected: isSelected,
                          selectedTileColor: AppColors.primaryButton.withValues(
                            alpha: 0.1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Right Side: Models
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Select Model for $tempBrand',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textHeading,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(LucideIcons.x),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: isLoadingModels
                        ? const Center(child: CircularProgressIndicator())
                        : (models.isEmpty
                              ? Center(
                                  child: Text(
                                    'Select a brand to see models',
                                    style: GoogleFonts.inter(
                                      color: Colors.grey,
                                    ),
                                  ),
                                )
                              : GridView.builder(
                                  padding: const EdgeInsets.all(24),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        crossAxisSpacing: 16,
                                        mainAxisSpacing: 16,
                                        childAspectRatio: 2.5,
                                      ),
                                  itemCount: models.length,
                                  itemBuilder: (context, index) {
                                    final model = models[index];
                                    final isSelected =
                                        tempModel == model['name'];
                                    return InkWell(
                                      onTap: () => setStateDialog(
                                        () => tempModel = model['name'],
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColors.primaryButton
                                              : Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: isSelected
                                                ? AppColors.primaryButton
                                                : Colors.grey.shade200,
                                          ),
                                          boxShadow: isSelected
                                              ? [
                                                  BoxShadow(
                                                    color: AppColors
                                                        .primaryButton
                                                        .withValues(alpha: 0.3),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ]
                                              : null,
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          model['name'] ?? '',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.inter(
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            color: isSelected
                                                ? Colors.white
                                                : AppColors.textHeading,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                )),
                  ),
                  // Bottom Action
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: tempModel.isEmpty
                              ? null
                              : () {
                                  setState(() {
                                    _currentBrand = tempBrand;
                                    _currentModel = tempModel;
                                    _selectedIssues.clear();
                                    _modelData = null;
                                  });
                                  _fetchModelData();
                                  Navigator.pop(context);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryButton,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Confirm',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    Widget buildMobileContent(StateSetter setStateDialog) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Device',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(LucideIcons.x),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Brand Dropdown
            Text(
              'Brand',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: tempBrand,
              items: _apiBrands
                  .map(
                    (b) => DropdownMenuItem(
                      value: b['title'] as String,
                      child: Text(b['title']),
                    ),
                  )
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  setStateDialog(() => tempBrand = val);
                  final brand = _apiBrands.firstWhere((b) => b['title'] == val);
                  fetchModels(brand['_id'], setStateDialog);
                }
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
            const SizedBox(height: 24),
            // Model Dropdown
            Text(
              'Model',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: models.any((m) => m['name'] == tempModel)
                  ? tempModel
                  : null,
              items: models
                  .map(
                    (m) => DropdownMenuItem(
                      value: m['name'] as String,
                      child: Text(m['name']),
                    ),
                  )
                  .toList(),
              onChanged: (val) => setStateDialog(() => tempModel = val ?? ''),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                hintText: isLoadingModels ? 'Loading...' : 'Select Model',
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: tempModel.isEmpty
                    ? null
                    : () {
                        setState(() {
                          _currentBrand = tempBrand;
                          _currentModel = tempModel;
                          _selectedIssues.clear();
                        });
                        _fetchModelData();
                        Navigator.pop(context);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryButton,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Update Device',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (isDesktop) {
      showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setStateDialog) {
            // Initial fetch if needed
            if (!isLoadingModels && models.isEmpty && _apiBrands.isNotEmpty) {
              final brand = _apiBrands.firstWhere(
                (b) => b['title'] == tempBrand,
                orElse: () => _apiBrands.first,
              );
              fetchModels(brand['_id'], setStateDialog);
            }
            return Dialog(
              backgroundColor: Colors.transparent,
              child: buildDesktopDialog(setStateDialog),
            );
          },
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) => StatefulBuilder(
          builder: (context, setStateDialog) =>
              buildMobileContent(setStateDialog),
        ),
      );
    }
  }

  // Fetch models for a specific brand
  Future<void> _fetchModelsForBrand(String brandId) async {
    setState(() => _isLoadingModels = true);
    try {
      final models = await _apiService.getModels(brandId);
      setState(() {
        _brandModels = models;
        _isLoadingModels = false;
      });
    } catch (e) {
      debugPrint('Error fetching models: $e');
      setState(() => _isLoadingModels = false);
    }
  }

  Future<void> _fetchIssues() async {
    setState(() => _isLoading = true);
    try {
      final issues = await _apiService.getIssues();
      if (mounted) {
        setState(() {
          _apiIssues = issues;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching issues: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Compact brand selection for left column
  Widget _buildBrandStep() {
    final displayBrands = _apiBrands.take(15).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Select Your Device Brand'),
        const SizedBox(height: 24),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: displayBrands.length + 1,
          itemBuilder: (context, index) {
            if (index == displayBrands.length) {
              return InkWell(
                onTap: _showChangeModelDialog,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primaryButton,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.moreHorizontal,
                        size: 32,
                        color: AppColors.primaryButton,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'More',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryButton,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final brand = displayBrands[index];
            return InkWell(
              onTap: () {
                setState(() {
                  _currentBrand = brand['title'] ?? '';
                  _currentStep = 1;
                });
                _fetchModelsForBrand(brand['_id']);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.smartphone,
                      size: 32,
                      color: AppColors.primaryButton,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      brand['title'] ?? '',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // Compact model selection for left column with pricing
  Widget _buildModelStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => setState(() => _currentStep = 0),
              icon: const Icon(LucideIcons.arrowLeft, size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 12),
            Expanded(child: _buildSectionTitle('Select $_currentBrand Model')),
          ],
        ),
        const SizedBox(height: 24),
        if (_isLoadingModels)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_brandModels.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Text(
                'No models available',
                style: GoogleFonts.inter(color: Colors.grey),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _brandModels.length,
            itemBuilder: (context, index) {
              final model = _brandModels[index];
              final modelName = model['name'] ?? '';
              final basePrice = _parseToInt(model['price'] ?? 0);

              return InkWell(
                onTap: () {
                  setState(() {
                    _currentModel = modelName;
                    _modelData = model;
                    _currentStep = 2;
                    _selectedIssues.clear();
                  });
                  _fetchIssues();
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.smartphone,
                        size: 24,
                        color: AppColors.primaryButton,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              modelName,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Starting from ₹$basePrice',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        LucideIcons.chevronRight,
                        size: 20,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  // Mock Data with Images

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveLayout.isDesktop(context);
    final double padding = isDesktop ? 80.0 : 20.0;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF9FAFB),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, const Color(0xFFF3F4F6)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: padding,
                  vertical: 20,
                ),
                child: Navbar(scaffoldKey: _scaffoldKey),
              ),
            ),

            // Multi-Phase Content Rendering
            // Device Header Section (show only after brand/model selected)
            if (_currentStep >= 2) _buildDeviceHeader(isDesktop, padding),

            // Main Content - Repair Flow
            Padding(
              padding: EdgeInsets.symmetric(horizontal: padding, vertical: 40),
              child: isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Column: Steps (Brand -> Model -> Issues -> Tech -> Schedule)
                        Expanded(flex: 3, child: _buildLeftColumn()),
                        const SizedBox(width: 40),
                        // Right Column: Summary & Checkout
                        Expanded(flex: 2, child: _buildRightColumn()),
                      ],
                    )
                  : Column(
                      children: [
                        _buildLeftColumn(),
                        const SizedBox(height: 40),
                        _buildRightColumn(),
                      ],
                    ),
            ),

            // Trust Badges Section
            if (_currentStep >= 2) _buildTrustSection(isDesktop, padding),

            const Footer(),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceHeader(bool isDesktop, double padding) {
    if (!isDesktop) {
      return Container(
        width: double.infinity,
        color: Colors.white,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    LucideIcons.smartphone,
                    size: 24,
                    color: AppColors.textHeading,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$_currentBrand $_currentModel',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textHeading,
                        ),
                      ),
                      Text(
                        '128GB • Graphite',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textBody,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _showChangeModelDialog,
                icon: const Icon(LucideIcons.refreshCw, size: 16),
                label: const Text('Change Model'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryButton,
                  side: const BorderSide(color: AppColors.primaryButton),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  LucideIcons.smartphone,
                  size: 32,
                  color: AppColors.textHeading,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$_currentBrand $_currentModel',
                    style: GoogleFonts.inter(
                      fontSize: 24, // Desktop font size
                      fontWeight: FontWeight.bold,
                      color: AppColors.textHeading,
                    ),
                  ),
                  Text(
                    '128GB • Graphite',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textBody,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Highlighted Change Model Button for Desktop
          GestureDetector(
            onTap: _showChangeModelDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryButton,
                    AppColors.primaryButton.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryButton.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.refreshCw,
                    size: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Change Model',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftColumn() {
    final bool isDesktop = ResponsiveLayout.isDesktop(context);

    if (isDesktop) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepIndicator(),
          const SizedBox(height: 32),
          if (_currentStep == 0) _buildBrandStep(),
          if (_currentStep == 1) _buildModelStep(),
          if (_currentStep == 2) _buildIssuesStep(),
          if (_currentStep == 3) _buildTechnicianStep(),
          if (_currentStep == 4) _buildScheduleStep(),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('What\'s wrong with your device?'),
        const SizedBox(height: 24),
        _buildIssuesGrid(),
        const SizedBox(height: 40),
        _buildOfferSection(),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: [
        _stepItem(0, 'Brand', LucideIcons.smartphone),
        _stepDivider(),
        _stepItem(1, 'Model', LucideIcons.tablet),
        _stepDivider(),
        _stepItem(2, 'Issues', LucideIcons.wrench),
        _stepDivider(),
        _stepItem(3, 'Technician', LucideIcons.user),
        _stepDivider(),
        _stepItem(4, 'Schedule', LucideIcons.calendar),
      ],
    );
  }

  Widget _stepItem(int step, String label, IconData icon) {
    bool isCompleted = _currentStep > step;
    bool isActive = _currentStep == step;

    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primaryButton
                  : (isCompleted ? Colors.green : Colors.grey[200]),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCompleted ? LucideIcons.check : icon,
              color: (isActive || isCompleted) ? Colors.white : Colors.grey,
              size: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: (isActive || isCompleted)
                  ? FontWeight.bold
                  : FontWeight.w500,
              color: (isActive || isCompleted)
                  ? AppColors.textHeading
                  : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepDivider() {
    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.only(bottom: 24),
      color: Colors.grey[200],
    );
  }

  Widget _buildIssuesStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('What\'s wrong with your device?'),
        const SizedBox(height: 24),
        _buildIssuesGrid(),
        const SizedBox(height: 40),
        _buildOfferSection(),
      ],
    );
  }

  Widget _buildTechnicianStep() {
    if (_isLoadingTechs)
      return const Center(child: CircularProgressIndicator());
    if (_apiTechnicians.isEmpty)
      return const Center(child: Text('No technicians found'));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Select a Certified Technician'),
        const SizedBox(height: 24),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _apiTechnicians.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final tech = _apiTechnicians[index];
            final isSelected = _selectedTechIndex == index;
            return InkWell(
              onTap: () => setState(() => _selectedTechIndex = index),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryButton
                        : Colors.grey.shade200,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage:
                          tech['photoUrl'] != null &&
                              tech['photoUrl'].isNotEmpty
                          ? NetworkImage(tech['photoUrl'])
                          : null,
                      child: tech['photoUrl'] == null
                          ? const Icon(LucideIcons.user)
                          : null,
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tech['name'] ?? 'Expert Tech',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            tech['specialty'] ?? 'Mobile Specialist',
                            style: GoogleFonts.inter(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        LucideIcons.checkCircle,
                        color: AppColors.primaryButton,
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildScheduleStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Schedule & Address'),
        const SizedBox(height: 8),
        Text(
          'Pick a convenient time and provide your service location.',
          style: GoogleFonts.inter(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 24),

        // Date & Time Card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(5),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryButton.withAlpha(10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      LucideIcons.calendar,
                      color: AppColors.primaryButton,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Pick a Date',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              CalendarDatePicker(
                initialDate: _selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 30)),
                onDateChanged: (d) => setState(() => _selectedDate = d),
              ),
              const Divider(height: 40),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryButton.withAlpha(10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      LucideIcons.clock,
                      color: AppColors.primaryButton,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Available Slots',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _timeSlots.map((slot) {
                  final isSel = _selectedTimeSlot == slot;
                  return InkWell(
                    onTap: () => setState(() => _selectedTimeSlot = slot),
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSel
                            ? AppColors.primaryButton
                            : Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSel
                              ? AppColors.primaryButton
                              : Colors.grey.shade200,
                        ),
                      ),
                      child: Text(
                        slot,
                        style: GoogleFonts.inter(
                          color: isSel ? Colors.white : Colors.black87,
                          fontSize: 13,
                          fontWeight: isSel
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Highlighted Address Section
        _buildAddressSection(),

        const SizedBox(height: 32),

        // Payment Method Card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(5),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryButton.withAlpha(10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      LucideIcons.creditCard,
                      color: AppColors.primaryButton,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Payment Mode',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: ['Cash on Service', 'Online Payment'].map((method) {
                  final isSel = _currentPaymentMethod == method;
                  return Expanded(
                    child: InkWell(
                      onTap: () =>
                          setState(() => _currentPaymentMethod = method),
                      child: Container(
                        margin: EdgeInsets.only(
                          right: method == 'Cash on Service' ? 8 : 0,
                          left: method == 'Online Payment' ? 8 : 0,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: isSel
                              ? AppColors.primaryButton
                              : Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSel
                                ? AppColors.primaryButton
                                : Colors.grey.shade200,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            method,
                            style: GoogleFonts.inter(
                              color: isSel ? Colors.white : Colors.black87,
                              fontWeight: isSel
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Service Address'),
                Text(
                  'Your device will be picked from here',
                  style: GoogleFonts.inter(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
            if (_savedAddresses.isNotEmpty)
              TextButton.icon(
                onPressed: _showAddAddressDialog,
                icon: const Icon(LucideIcons.plus, size: 16),
                label: const Text('Add New'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryButton,
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),

        if (_isLoadingAddresses)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_savedAddresses.isEmpty)
          // Highlighted Empty State
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.primaryButton.withAlpha(5),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.primaryButton.withAlpha(20),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  LucideIcons.mapPin,
                  size: 48,
                  color: AppColors.primaryButton.withAlpha(50),
                ),
                const SizedBox(height: 16),
                Text(
                  'Where should we come?',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'No address found. Add your service address to continue.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _showAddAddressDialog,
                  icon: const Icon(LucideIcons.plus),
                  label: const Text('Add My First Address'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryButton,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          // Scrollable Address List or Grid
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _savedAddresses.length,
            itemBuilder: (context, index) {
              final addr = _savedAddresses[index];
              final isSel = _selectedAddress?['_id'] == addr['_id'];
              return GestureDetector(
                onTap: () => setState(() => _selectedAddress = addr),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSel
                          ? AppColors.primaryButton
                          : Colors.grey.shade200,
                      width: isSel ? 2 : 1,
                    ),
                    boxShadow: isSel
                        ? [
                            BoxShadow(
                              color: AppColors.primaryButton.withAlpha(10),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSel
                              ? AppColors.primaryButton
                              : Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getIcon(addr['label']?.toLowerCase()) ??
                              LucideIcons.mapPin,
                          color: isSel ? Colors.white : Colors.grey[600],
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              addr['label'] ?? 'Service Address',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              addr['fullAddress'] ?? '',
                              style: GoogleFonts.inter(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      if (isSel)
                        const Icon(
                          LucideIcons.checkCircle2,
                          color: AppColors.primaryButton,
                          size: 24,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Future<void> _showAddAddressDialog() async {
    if (!_isLoggedIn) {
      _showLoginPrompt();
      return;
    }
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddressPickerScreen(userId: _userId),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _savedAddresses.add(result);
        _selectedAddress = result;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Address added and selected!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Widget _buildIssuesGrid() {
    final bool isDesktop = ResponsiveLayout.isDesktop(context);
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_apiIssues.isEmpty) {
      return const Center(child: Text('No repair issues found in database'));
    }

    // Source of truth: Use repairPrices from _modelData
    final List<Map<String, dynamic>> filteredIssues = [];

    if (_modelData != null && _modelData!['repairPrices'] != null) {
      final repairPricesList = _modelData!['repairPrices'];
      if (repairPricesList is List) {
        for (final priceItem in repairPricesList) {
          final issueName = (priceItem['issueName'] ?? '').toString();
          if (issueName.isEmpty) continue;

          final price = _parseToInt(priceItem['price']);
          if (price <= 0) continue;

          // Cross-reference with global issues for icons/images
          final itemDetail = _apiIssues.firstWhere(
            (i) => i['name'] == issueName,
            orElse: () => null,
          );

          filteredIssues.add({
            'item': itemDetail ?? {'name': issueName},
            'key': issueName,
            'price': price,
            'originalPrice': _parseToInt(priceItem['originalPrice'] ?? price),
            'discount': _parseToInt(priceItem['discount']),
          });
        }
      }
    }

    if (filteredIssues.isEmpty) {
      return const Center(
        child: Text('No repair services available for this model'),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 4 : 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.78, // Adjusted for more content and price row
      ),
      itemCount: filteredIssues.length,
      itemBuilder: (context, index) {
        final issueData = filteredIssues[index];
        final item = issueData['item'];
        final key = issueData['key'] as String;
        final price = issueData['price'] as int;
        final originalPrice = issueData['originalPrice'] as int;
        final discount = issueData['discount'] as int;
        final isSelected = _selectedIssues.contains(key);

        // Map API data to what _IssueCard expects
        final data = {
          'icon': _getIcon(item['icon']),
          'imageUrl': item['imageUrl'],
          'price': price,
          'originalPrice': originalPrice,
          'discount': discount,
          'warranty': '6 Months',
          'time': '45 mins',
          'symptoms': item['symptoms'] is List
              ? item['symptoms']
              : ['Diagnosis', 'Repair', 'Quality Check'],
        };

        return _IssueCard(
          title: key,
          data: data,
          isSelected: isSelected,
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedIssues.remove(key);
              } else {
                _selectedIssues.add(key);
              }
            });
            if (!isSelected) _showIssueDetails(key, data);
          },
        );
      },
    );
  }

  Widget _buildRightColumn() {
    final bool isDesktop = ResponsiveLayout.isDesktop(context);
    return Column(
      children: [
        // Checkout Card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(5),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Booking Summary',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textHeading,
                ),
              ),
              const SizedBox(height: 24),

              // Selected Issues List
              if (_selectedIssues.isEmpty)
                Text(
                  'No issues selected',
                  style: GoogleFonts.inter(color: Colors.grey),
                )
              else
                ..._selectedIssues.map((issue) {
                  final item = _apiIssues.firstWhere(
                    (i) => i['name'] == issue,
                    orElse: () => <String, dynamic>{},
                  );

                  // Get model-specific price
                  int price = 0;
                  if (_modelData != null &&
                      _modelData!['repairPrices'] != null) {
                    final repairPricesList = _modelData!['repairPrices'];
                    if (repairPricesList is List) {
                      final priceItem = repairPricesList.firstWhere(
                        (p) => p['issueName'] == issue,
                        orElse: () => null,
                      );
                      if (priceItem != null) {
                        price = _parseToInt(priceItem['price']);
                      }
                    }
                  }

                  final data = {
                    'imageUrl': item['imageUrl'],
                    'price': price,
                    'warranty': '6 Months',
                    'time': '45 mins',
                  };

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade100),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image
                        Container(
                          width: 50,
                          height: 50,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child:
                              (item['imageUrl'] != null &&
                                  item['imageUrl'].isNotEmpty)
                              ? Image.network(
                                  item['imageUrl'],
                                  fit: BoxFit.contain,
                                )
                              : Icon(_getIcon(item['icon']), size: 24),
                        ),
                        const SizedBox(width: 12),
                        // Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                issue,
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textHeading,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${data['warranty']} Warranty • ${data['time']}',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Price
                        Text(
                          '₹${data['price']}',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryButton,
                          ),
                        ),
                      ],
                    ),
                  );
                }),

              const Divider(height: 32),

              // Step details in summary (Desktop)
              if (isDesktop) ...[
                // Show brand/model after selection
                if (_currentBrand.isNotEmpty && _currentStep >= 1)
                  _buildSummaryItem(
                    LucideIcons.smartphone,
                    'Brand',
                    _currentBrand,
                  ),
                if (_currentModel.isNotEmpty && _currentStep >= 2)
                  _buildSummaryItem(LucideIcons.tablet, 'Model', _currentModel),
                if (_selectedTechIndex != null && _currentStep >= 3)
                  _buildSummaryItem(
                    LucideIcons.user,
                    'Technician',
                    _apiTechnicians[_selectedTechIndex!]['name'] ?? 'Expert',
                  ),
                if (_currentStep == 4 && _selectedTimeSlot != null)
                  _buildSummaryItem(
                    LucideIcons.calendar,
                    'Schedule',
                    '${_selectedDate.day}/${_selectedDate.month} @ $_selectedTimeSlot',
                  ),
                if (_currentStep == 4 && _selectedAddress != null)
                  _buildSummaryItem(
                    LucideIcons.mapPin,
                    'Address',
                    _selectedAddress!['label'] ?? 'Service Location',
                  ),
                if (_currentStep == 4)
                  _buildSummaryItem(
                    LucideIcons.creditCard,
                    'Payment',
                    _currentPaymentMethod,
                  ),
                const Divider(height: 32),
              ],

              // Total (only show when issues are selected)
              if (_currentStep >= 2) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Amount',
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '₹${_calculateTotal()}',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryButton,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _getNextStepAction(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryButton,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isBookingLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          ResponsiveLayout.isDesktop(context)
                              ? _getNextStepLabel()
                              : 'Proceed to Schedule',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              if (ResponsiveLayout.isDesktop(context) && _currentStep > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: TextButton(
                    onPressed: () => setState(() => _currentStep--),
                    child: Center(
                      child: Text(
                        'Go Back',
                        style: GoogleFonts.inter(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 24),
        _buildFAQSection(),
        const SizedBox(height: 24),
        // Support Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFDBEAFE)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.headphones,
                  color: AppColors.primaryButton,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Need Help?',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E40AF),
                    ),
                  ),
                  Text(
                    'Talk to our expert now',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF3B82F6),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              TextButton(onPressed: () {}, child: const Text('Call Now')),
            ],
          ),
        ),
      ],
    );
  }

  void _showIssueDetails(String title, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 140,
                  width: 140,
                  margin: const EdgeInsets.only(bottom: 24),
                  child:
                      (data['imageUrl'] != null && data['imageUrl'].isNotEmpty)
                      ? Image.network(data['imageUrl'], fit: BoxFit.contain)
                      : Icon(data['icon'], size: 80, color: Colors.grey),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textHeading,
                        ),
                      ),
                      Text(
                        '₹${data['price']}',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryButton,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryButton.withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      data['icon'] as IconData,
                      color: AppColors.primaryButton,
                      size: 28,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Common Symptoms:',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (data['symptoms'] as List)
                    .map(
                      (s) => Chip(
                        label: Text(s as String),
                        backgroundColor: Colors.grey[100],
                        labelStyle: GoogleFonts.inter(fontSize: 12),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _detailItem(LucideIcons.clock, 'Time', data['time']),
                  _detailItem(
                    LucideIcons.shieldCheck,
                    'Warranty',
                    data['warranty'],
                  ),
                  _detailItem(LucideIcons.badgeCheck, 'Parts', 'Original'),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryButton,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Add Issue'),
                ),
              ),
              const SizedBox(height: 20), // Extra padding for safe area
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
        Text(
          value,
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildOfferSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFFFFF7ED), const Color(0xFFFFEDD5)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.percent, color: Color(0xFFEA580C)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Special Offer Unlocked!',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF9A3412),
                  ),
                ),
                Text(
                  'Get ₹200 OFF on Screen Replacement today.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFFC2410C),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withAlpha(40),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Part (Purple)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(20),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        LucideIcons.helpCircle,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'SUPPORT',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Frequently Asked Questions',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Everything you need to know about our services.',
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          // Content Part (White Card inside)
          Container(
            margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                _buildFAQItem(
                  'What if my phone is water damaged?',
                  'We perform a diagnostic first. If it\'s repairable, we proceed. No fix, no fee.',
                ),
                _buildFAQItem(
                  'Will my data be safe?',
                  'Yes, we follow strict data privacy protocols. However, we recommend a backup.',
                ),
                _buildFAQItem(
                  'Are the parts original?',
                  'We use high-quality OEM equivalent or original parts with warranty.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String q, String a) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            q,
            style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            a,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.grey.shade100),
        ],
      ),
    );
  }

  Widget _buildTrustSection(bool isDesktop, double padding) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 40),
      child: Wrap(
        spacing: 40,
        runSpacing: 40,
        alignment: WrapAlignment.center,
        children: [
          _buildTrustBadge(
            LucideIcons.award,
            'Certified Techs',
            'Expertly trained',
          ),
          _buildTrustBadge(
            LucideIcons.shieldCheck,
            'Warranty',
            'Up to 6 months',
          ),
          _buildTrustBadge(
            LucideIcons.badgeCheck,
            'Original Parts',
            'Quality guaranteed',
          ),
          _buildTrustBadge(LucideIcons.lock, 'Data Privacy', '100% Secure'),
        ],
      ),
    );
  }

  Widget _buildTrustBadge(IconData icon, String title, String sub) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryButton.withAlpha(10),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primaryButton, size: 24),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            Text(
              sub,
              style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primaryButton),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: GoogleFonts.inter(color: Colors.grey, fontSize: 13),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: _buildSectionTitleStyle());
  }

  TextStyle _buildSectionTitleStyle() {
    return GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: AppColors.textHeading,
    );
  }

  int _calculateTotal() {
    int total = 0;
    for (var issueName in _selectedIssues) {
      int price = 0;
      if (_modelData != null && _modelData!['repairPrices'] != null) {
        final repairPricesList = _modelData!['repairPrices'];
        if (repairPricesList is List) {
          final priceItem = repairPricesList.firstWhere(
            (p) => p['issueName'] == issueName,
            orElse: () => null,
          );
          if (priceItem != null) {
            price = _parseToInt(priceItem['price']);
          }
        }
      }
      total += price;
    }
    return total;
  }
}

class _IssueCard extends StatefulWidget {
  final String title;
  final Map<String, dynamic> data;
  final bool isSelected;
  final VoidCallback onTap;

  const _IssueCard({
    required this.title,
    required this.data,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_IssueCard> createState() => _IssueCardState();
}

class _IssueCardState extends State<_IssueCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.diagonal3Values(
            _isHovering || widget.isSelected ? 1.05 : 1.0,
            _isHovering || widget.isSelected ? 1.05 : 1.0,
            1.0,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isSelected
                  ? AppColors.primaryButton
                  : (_isHovering
                        ? AppColors.primaryButton.withValues(alpha: 0.5)
                        : Colors.transparent),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.isSelected
                    ? AppColors.primaryButton.withAlpha(30)
                    : (_isHovering
                          ? Colors.black.withAlpha(20)
                          : Colors.black.withAlpha(10)),
                blurRadius: _isHovering ? 20 : 12,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background Image
              if (widget.data['imageUrl'] != null &&
                  (widget.data['imageUrl'] as String).isNotEmpty)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.network(
                      widget.data['imageUrl'],
                      fit: BoxFit.contain,
                      alignment: const Alignment(0, -0.3),
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Icon(
                          widget.data['icon'] ?? LucideIcons.wrench,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                  ),
                )
              else
                Center(
                  child: Icon(
                    widget.data['icon'] ?? LucideIcons.wrench,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                ),
              // Gradient overly at bottom to ensure text readability
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 110,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(18),
                      bottomRight: Radius.circular(18),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.0),
                        Colors.white.withValues(alpha: 0.9),
                        Colors.white,
                      ],
                    ),
                  ),
                ),
              ),
              // Text Content
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.title,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.textHeading,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      // Price and Discount row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if ((widget.data['discount'] ?? 0) > 0 &&
                              (widget.data['originalPrice'] ?? 0) >
                                  (widget.data['price'] ?? 0))
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Text(
                                '₹${widget.data['originalPrice']}',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: Colors.grey,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ),
                          Text(
                            '₹${widget.data['price']}',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: AppColors.primaryButton,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      if ((widget.data['discount'] ?? 0) > 0)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${widget.data['discount']}% OFF',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // Check Icon
              if (widget.isSelected)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryButton,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 4),
                      ],
                    ),
                    child: const Icon(
                      LucideIcons.check,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
