import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme.dart';
import 'mobile_profile_page.dart';
import 'my_bookings_screen.dart';
import 'location_picker_page.dart';
import '../services/location_service.dart';

import 'technician_profile_page.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:async';

class MobileRepairPage extends StatefulWidget {
  final String? initialIssue;
  final String? initialBrand;
  final String? initialModel;
  const MobileRepairPage({
    super.key,
    this.initialIssue,
    this.initialBrand,
    this.initialModel,
  });

  @override
  State<MobileRepairPage> createState() => _MobileRepairPageState();
}

class _MobileRepairPageState extends State<MobileRepairPage> {
  // Selection State
  final Set<String> _selectedIssues = {};
  String? _selectedBrand;
  String? _selectedModel;
  Map<String, dynamic>? _selectedModelData;

  final ApiService _apiService = ApiService();
  List<dynamic> _apiIssues = [];
  List<dynamic> _apiBrands = [];
  List<dynamic> _apiModels = [];
  bool _isLoadingIssues = true;
  bool _isLoadingBrands = true;
  bool _isLoadingModels = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialIssue != null) {
      _selectedIssues.add(widget.initialIssue!);
    }
    if (widget.initialBrand != null) {
      _selectedBrand = widget.initialBrand;
    }
    if (widget.initialModel != null) {
      _selectedModel = widget.initialModel;
      _currentStep = 2; // Jump directly to Issues step
    }
    _fetchIssues();
    _fetchBrands();
    _fetchTechnicians();
    _fetchUserAddresses();
    _initSocket();
  }

  @override
  void dispose() {
    // We don't necessarily want to dispose global socket service here
    // but maybe stop listeners if we had specific ones.
    super.dispose();
  }

  void _initSocket() {
    SocketService().connect();
    SocketService().onTechnicianStatusUpdate((data) {
      if (!mounted) return;
      final techId = data['technicianId'];
      final isOnline = data['isOnline'];

      setState(() {
        // Update the status in our list
        for (var i = 0; i < _apiTechnicians.length; i++) {
          final t = _apiTechnicians[i];
          if (t['_id'] == techId || t['id'] == techId) {
            _apiTechnicians[i]['isOnline'] = isOnline;
            break;
          }
        }
        // Re-sort the list
        _sortTechnicians();
      });
    });
  }

  void _sortTechnicians() {
    _apiTechnicians.sort((a, b) {
      // 1. ONLINE PRIORITY
      bool onlineA = a['isOnline'] == true;
      bool onlineB = b['isOnline'] == true;
      if (onlineA != onlineB) {
        return onlineB ? 1 : -1;
      }

      // 2. HIGHEST RATING FIRST
      double ratingA = (a['averageRating'] ?? 0.0).toDouble();
      double ratingB = (b['averageRating'] ?? 0.0).toDouble();
      if (ratingA != ratingB) {
        return ratingB.compareTo(ratingA);
      }

      // 3. MOST REPAIRS/JOBS FIRST
      int jobsA = a['totalReviews'] ?? 0;
      int jobsB = b['totalReviews'] ?? 0;
      return jobsB.compareTo(jobsA);
    });
  }

  Future<void> _fetchBrands() async {
    try {
      final brands = await _apiService.getBrands();
      if (mounted) {
        setState(() {
          _apiBrands = brands;
          _isLoadingBrands = false;

          // If we had an initial brand, fetch its models
          if (_selectedBrand != null) {
            final brand = _apiBrands.firstWhere(
              (b) => b['title'] == _selectedBrand,
              orElse: () => null,
            );
            if (brand != null) {
              _fetchModels(brand['_id']);
            }
          }
        });
      }
    } catch (e) {
      debugPrint('Error fetching brands: $e');
      if (mounted) setState(() => _isLoadingBrands = false);
    }
  }

  Future<void> _fetchModels(String brandId) async {
    setState(() => _isLoadingModels = true);
    try {
      final models = await _apiService.getModels(brandId);
      if (mounted) {
        setState(() {
          _apiModels = models;
          _isLoadingModels = false;

          // If we had an initial model, find its full data
          if (_selectedModel != null) {
            final model = _apiModels.firstWhere(
              (m) => m['name'] == _selectedModel,
              orElse: () => null,
            );
            if (model != null) {
              _selectedModelData = model;
            }
          }
        });
      }
    } catch (e) {
      debugPrint('Error fetching models: $e');
      if (mounted) setState(() => _isLoadingModels = false);
    }
  }

  Future<void> _fetchIssues() async {
    try {
      final issues = await _apiService.getIssues();
      if (mounted) {
        setState(() {
          _apiIssues = issues;
          _isLoadingIssues = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching issues: $e');
      if (mounted) setState(() => _isLoadingIssues = false);
    }
  }

  Future<void> _fetchTechnicians() async {
    try {
      final techs = await _apiService.getTechnicians();
      if (mounted) {
        final filtered = techs
            .where((t) => t['status'] == 'approved' || t['status'] == 'active')
            .cast<Map<String, dynamic>>()
            .toList();

        _apiTechnicians = filtered;
        _sortTechnicians();
        _isLoadingTechs = false;
      }
    } catch (e) {
      debugPrint('Error fetching technicians: $e');
      if (mounted) setState(() => _isLoadingTechs = false);
    }
  }

  Future<void> _fetchUserAddresses() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) setState(() => _isLoadingAddresses = false);
        return;
      }

      final mongoUser = await _apiService.getUser(user.uid);
      if (mongoUser != null) {
        final addresses = await _apiService.getAddresses(mongoUser['_id']);
        if (mounted) {
          setState(() {
            _userAddresses = List<Map<String, dynamic>>.from(addresses);
            _isLoadingAddresses = false;

            // Auto-select the first/most recent address
            if (_userAddresses.isNotEmpty) {
              final firstAddress = _userAddresses.first;
              _selectedAddressId = firstAddress['_id'];
              _address = firstAddress['fullAddress'] ?? '';
              _addressLat = firstAddress['latitude']?.toDouble();
              _addressLng = firstAddress['longitude']?.toDouble();

              debugPrint('✅ Auto-selected address: $_address');
            }
          });
        }
      } else {
        if (mounted) setState(() => _isLoadingAddresses = false);
      }
    } catch (e) {
      debugPrint('Error fetching user addresses: $e');
      if (mounted) setState(() => _isLoadingAddresses = false);
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

  int _calculateTotal() {
    int total = 0;
    if (_selectedModelData != null &&
        _selectedModelData!['repairPrices'] != null) {
      final prices = _selectedModelData!['repairPrices'] as List<dynamic>;

      // Map App Generic Issue Names to DB/Excel Part Names
      final Map<String, String> issueMapping = {
        'Charging': 'Charging Jack',
        // 'Camera': 'Front Camera', // This was the issue
        'Face/Touch ID': 'Fingerprint', // If available
      };

      for (var issueName in _selectedIssues) {
        // 1. Try Direct Match (e.g. Screen, Battery, Mic, Speaker)
        var searchKey = issueName;

        // 2. If not found, try Mapping
        if (issueMapping.containsKey(issueName)) {
          searchKey = issueMapping[issueName]!;
        }

        final priceItem = prices.firstWhere(
          (p) => p['issueName'] == searchKey,
          orElse: () => null,
        );

        if (priceItem != null) {
          total += (priceItem['price'] as num).toInt();
        } else {
          // Fallback logic...

          // Fallback to generic base price if not found in model specific (optional)
          final item = _apiIssues.firstWhere(
            (i) => i['name'] == issueName,
            orElse: () => null,
          );
          if (item != null) {
            total += int.tryParse(item['base_price'].toString()) ?? 0;
          }
        }
      }
    }
    return total;
  }

  int _currentStep = 0;
  // Steps: 0:Issues, 1:Brand, 2:Model, 3:Summary, 4:Tech, 5:Schedule, 6:Checkout
  final int _totalSteps = 7;

  int _selectedTechIndex = -1;
  DateTime _selectedDate = DateTime.now();
  String? _selectedTimeSlot;
  int _paymentMethod = 0; // 0: UPI, 1: Card, 2: Cash
  String _address = '';
  double? _addressLat;
  double? _addressLng;
  String? _selectedAddressId;

  // User Addresses from API
  List<Map<String, dynamic>> _userAddresses = [];
  bool _isLoadingAddresses = true;

  List<Map<String, dynamic>> _apiTechnicians = [];
  bool _isLoadingTechs = true;

  final List<String> _timeSlots = [
    '10:00 AM - 11:00 AM',
    '11:00 AM - 12:00 PM',
    '01:00 PM - 02:00 PM',
    '02:00 PM - 03:00 PM',
    '04:00 PM - 05:00 PM',
    '06:00 PM - 07:00 PM',
  ];

  bool _isBookingLoading = false;

  void _nextStep() {
    // Updated Validation for Reordered Steps
    // 0: Brand, 1: Model, 2: Issue

    if (_currentStep == 0 && _selectedBrand == null) {
      _showSnack('Please select a brand');
      return;
    }
    if (_currentStep == 1 && _selectedModel == null) {
      _showSnack('Please select a model');
      return;
    }
    if (_currentStep == 2 && _selectedIssues.isEmpty) {
      _showSnack('Please select at least one issue');
      return;
    }
    if (_currentStep == 4 && _selectedTechIndex == -1) {
      _showSnack('Please select a technician');
      return;
    }
    if (_currentStep == 4 && _selectedTechIndex != -1) {
      final selectedTech = _apiTechnicians[_selectedTechIndex];
      if (selectedTech['isOnline'] != true) {
        _showSnack(
          '⚠️ Selected technician is offline. Please choose an online specialist.',
        );
        return;
      }
    }
    if (_currentStep == 5 && _selectedTimeSlot == null) {
      _showSnack('Please select a time slot');
      return;
    }
    if (_currentStep == 6 && _address.isEmpty) {
      _showSnack('⚠️ Please select or add a delivery address');
      return;
    }

    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
    } else {
      // Confirm Booking
      _createBooking();
    }
  }

  Future<void> _createBooking() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnack('Please login to book a repair');
      return;
    }

    setState(() => _isBookingLoading = true);

    try {
      final api = ApiService();
      // Log URL logic
      debugPrint(
        "User details - UID: ${user.uid}, Email: ${user.email}, Name: ${user.displayName}",
      );
      var mongoUser = await api.getUser(user.uid);
      if (mongoUser == null) {
        // Auto-registration fallback if user record is missing in MongoDB
        debugPrint(
          "User not found in MongoDB. Attempting auto-registration...",
        );
        final registrationData = await api.registerUser({
          'name': user.displayName ?? 'ZiyonStar User',
          'email': user.email ?? '',
          'firebaseUid': user.uid,
          'photoUrl': user.photoURL ?? '',
          'phone': user.phoneNumber ?? '',
          'role': 'user',
        });

        if (registrationData != null && registrationData.containsKey('user')) {
          mongoUser = registrationData['user'];
        } else {
          // If registerUser returns the user object directly or fallback
          mongoUser = registrationData;
        }

        if (mongoUser == null) {
          throw "Registration failed. RegistrationData was null. Check browser console logs for ApiService prints.";
        }
      }

      final bookingData = {
        'userId': mongoUser['_id'],
        'deviceBrand': _selectedBrand ?? 'Unknown',
        'deviceModel': _selectedModel ?? 'Unknown',
        'issues': _selectedIssues
            .map((i) => {'issueName': i, 'price': 0})
            .toList(),
        'totalPrice': _calculateTotal(),
        'scheduledDate': _selectedDate.toIso8601String(),
        'timeSlot': _selectedTimeSlot ?? 'Morning',
        'addressId': _selectedAddressId, // Use saved address ID if available
        'addressDetails': _address,
        'addressLat': _addressLat,
        'addressLng': _addressLng,
        'technicianId': _apiTechnicians[_selectedTechIndex]['_id'],
        'paymentMethod': _paymentMethod == 0
            ? 'UPI'
            : (_paymentMethod == 1 ? 'Card' : 'Cash'),
      };

      final bookingResponse = await api.createBooking(bookingData);

      if (mounted) {
        if (_paymentMethod == 0 && bookingResponse != null) {
          // Trigger Online Payment (UPI)
          await _showPaymentDialog(bookingResponse);
        } else {
          setState(() => _isBookingLoading = false);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (c) => const MyBookingsScreen()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isBookingLoading = false);
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Booking Failed"),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 1)),
    );
  }

  Future<void> _showPaymentDialog(Map<String, dynamic> booking) async {
    final api = ApiService();
    final user = FirebaseAuth.instance.currentUser;
    final amount = double.parse(booking['totalPrice'].toString());
    final bookingId = booking['_id'];

    // 1. Create Payment Order
    final paymentOrderResponse = await api.createPaymentOrder(
      bookingId: bookingId,
      amount: amount,
      customerName: user?.displayName ?? 'Customer',
      customerMobile: user?.phoneNumber ?? '9999999999',
    );

    if (paymentOrderResponse == null || !paymentOrderResponse['success']) {
      _showSnack(
        'Failed to generate payment QR. Please try again or choose cash.',
      );
      setState(() => _isBookingLoading = false);
      return;
    }

    final orderData = paymentOrderResponse['orderData'];
    final upiUrl =
        orderData['upi_url'] ??
        ''; // Assuming API returns upi_url (e.g. upi://pay?...)
    final txnId = orderData['client_txn_id'];

    if (!mounted) return;

    Timer? statusTimer;
    bool isPaymentSuccessful = false;

    await showGeneralDialog(
      context: context,
      barrierDismissible: false,
      pageBuilder: (ctx, anim1, anim2) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Start polling for status
            statusTimer ??= Timer.periodic(const Duration(seconds: 5), (
              timer,
            ) async {
              final statusResponse = await api.checkPaymentStatus(txnId);
              if (statusResponse != null && statusResponse['success']) {
                if (statusResponse['status'] == 'success') {
                  setDialogState(() => isPaymentSuccessful = true);
                  timer.cancel();
                  Future.delayed(const Duration(seconds: 2), () {
                    Navigator.pop(ctx);
                  });
                }
              }
            });

            return WillPopScope(
              onWillPop: () async => false, // Prevent accidental close
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Scan & Pay',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Amount: ₹$amount',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: AppColors.primaryButton,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (isPaymentSuccessful)
                      Column(
                        children: [
                          const Icon(
                            LucideIcons.checkCircle,
                            color: Colors.green,
                            size: 80,
                          ).animate().scale(duration: 400.ms),
                          const SizedBox(height: 16),
                          Text(
                            'Payment Successful!',
                            style: GoogleFonts.inter(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    else if (upiUrl.isNotEmpty)
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: QrImageView(
                              data: upiUrl,
                              version: QrVersions.auto,
                              size: 200.0,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const CircularProgressIndicator(strokeWidth: 2),
                          const SizedBox(height: 12),
                          Text(
                            'Waiting for payment...',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      )
                    else
                      const Text('Generating QR code...'),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(
                          'https://img.icons8.com/color/48/000000/google-pay.png',
                          width: 24,
                        ),
                        const SizedBox(width: 12),
                        Image.network(
                          'https://img.icons8.com/color/48/000000/phone-pe.png',
                          width: 24,
                        ),
                        const SizedBox(width: 12),
                        Image.network(
                          'https://img.icons8.com/color/48/000000/paytm.png',
                          width: 24,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (!isPaymentSuccessful)
                      TextButton(
                        onPressed: () {
                          statusTimer?.cancel();
                          Navigator.pop(ctx);
                          _showSnack(
                            'Payment cancelled. Please go to "My Bookings" to try again.',
                          );
                        },
                        child: Text(
                          'Cancel Payment',
                          style: GoogleFonts.inter(color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    statusTimer?.cancel();
    if (isPaymentSuccessful) {
      if (mounted) {
        setState(() => _isBookingLoading = false);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (c) => const MyBookingsScreen()),
        );
      }
    } else {
      if (mounted) {
        setState(() => _isBookingLoading = false);
        // We still created the booking, but payment failed/cancelled
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (c) => const MyBookingsScreen()),
        );
      }
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 70,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'ZiyonStar',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w900,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (c) => const MobileProfilePage()),
            ),
            child: const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey,
                backgroundImage: AssetImage('assets/images/tech_avatar_1.png'),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentStep + 1) / _totalSteps,
            backgroundColor: Colors.grey.shade100,
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppColors.primaryButton,
            ),
            minHeight: 4,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: _buildCurrentStep(),
            ),
          ),
        ],
      ),
      bottomSheet: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Total Price Bar (Only on Summary Step)
          if (_currentStep == 3)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Amount',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        '₹${_calculateTotal()}',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryButton,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {}, // Optional details expand
                    child: Text(
                      'View Details',
                      style: GoogleFonts.inter(color: AppColors.primaryButton),
                    ),
                  ),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _prevStep,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Previous',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isBookingLoading
                        ? null
                        : (_currentStep == 4 &&
                              _selectedTechIndex != -1 &&
                              _apiTechnicians[_selectedTechIndex]['isOnline'] !=
                                  true)
                        ? null
                        : (_currentStep == 6 && _address.isEmpty)
                        ? null
                        : _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryButton,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: Colors.grey.shade300,
                    ),
                    child: _isBookingLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            _currentStep == _totalSteps - 1
                                ? _address.isEmpty
                                      ? 'Select Address First'
                                      : 'Confirm Booking'
                                : (_currentStep == 4 &&
                                      _selectedTechIndex != -1 &&
                                      _apiTechnicians[_selectedTechIndex]['isOnline'] !=
                                          true)
                                ? 'Technician Offline'
                                : 'Next',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              color:
                                  (_currentStep == 4 &&
                                      _selectedTechIndex != -1 &&
                                      _apiTechnicians[_selectedTechIndex]['isOnline'] !=
                                          true)
                                  ? Colors.grey.shade600
                                  : Colors.white,
                            ),
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

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildBrandSelectionStep();
      case 1:
        return _buildModelSelectionStep();
      case 2:
        return _buildIssueSelectionStep();
      case 3:
        return _buildSummaryStep();
      case 4:
        return _buildTechnicianStep();
      case 5:
        return _buildScheduleStep();
      case 6:
        return _buildCheckoutStep();
      default:
        return Container();
    }
  }

  // STEP 0: ISSUE SELECTION
  Widget _buildIssueSelectionStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What\'s the issue?',
            style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Select one or more issues',
            style: GoogleFonts.inter(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          _selectedModelData == null ||
                  _selectedModelData!['repairPrices'] == null ||
                  (_selectedModelData!['repairPrices'] as List).isEmpty
              ? const Center(
                  child: Text('Please select a model to see repair options.'),
                )
              : GridView.builder(
                  shrinkWrap: true,
                  primary: false,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: _selectedModelData!['repairPrices'].length,
                  itemBuilder: (context, index) {
                    final priceItem =
                        _selectedModelData!['repairPrices'][index];
                    // The priceItem from the model only contains pricing info.
                    // We must look up the corresponding 'Issue' object from _apiIssues
                    // to get the correct image URL/asset path.
                    final key = (priceItem['issueName'] ?? '') as String;
                    if (key.isEmpty) return const SizedBox.shrink();

                    final matchingIssue = _apiIssues.firstWhere(
                      (issue) => issue['name'] == key,
                      orElse: () => null,
                    );
                    String? imageUrl = matchingIssue != null
                        ? matchingIssue['imageUrl']
                        : null;

                    if (imageUrl == null || imageUrl.isEmpty) {
                      final localPath = _getIssueImagePath(key);
                      if (localPath.isNotEmpty) {
                        imageUrl = localPath;
                      }
                    }

                    final isSelected = _selectedIssues.contains(key);

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (_selectedIssues.contains(key)) {
                            _selectedIssues.remove(key);
                          } else {
                            _selectedIssues.add(key);
                          }
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryButton.withOpacity(0.1)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryButton
                                : Colors.grey.shade200,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child:
                                          (imageUrl != null &&
                                              imageUrl.isNotEmpty)
                                          ? (imageUrl.startsWith('http')
                                                ? Image.network(
                                                    imageUrl,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (c, e, s) =>
                                                        const Center(
                                                          child: Icon(
                                                            LucideIcons.image,
                                                          ),
                                                        ),
                                                  )
                                                : Image.asset(
                                                    imageUrl,
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) {
                                                          debugPrint(
                                                            'Error loading asset: $imageUrl -> $error',
                                                          );
                                                          return const Center(
                                                            child: Icon(
                                                              LucideIcons.image,
                                                            ),
                                                          );
                                                        },
                                                  ))
                                          : Icon(
                                              _getIcon(
                                                key,
                                              ), // Fallback to icon if no imageUrl
                                              size: 60,
                                            ),
                                    ),
                                    if (isSelected)
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Icon(
                                          LucideIcons.checkCircle,
                                          color: AppColors.primaryButton,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              key,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                            ),
                            // Pricing Column
                            Column(
                              children: [
                                if (priceItem['originalPrice'] != null)
                                  Text(
                                    '₹${priceItem['originalPrice']}',
                                    style: GoogleFonts.inter(
                                      decoration: TextDecoration.lineThrough,
                                      color: Colors.grey,
                                      fontSize: 10,
                                    ),
                                  ),
                                if (priceItem['discount'] != null)
                                  Text(
                                    '${priceItem['discount']} OFF',
                                    style: GoogleFonts.inter(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                Text(
                                  '₹${priceItem['price']}',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: AppColors.primaryButton,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  // STEP 1: BRAND SELECTION
  Widget _buildBrandSelectionStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Brand',
            style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _isLoadingBrands
              ? const Center(child: CircularProgressIndicator())
              : _apiBrands.isEmpty
              ? const Center(child: Text('No brands found'))
              : GridView.builder(
                  shrinkWrap: true,
                  primary: false,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: _apiBrands.length,
                  itemBuilder: (context, index) {
                    final brand = _apiBrands[index];
                    final brandName = (brand['title'] ?? '') as String;
                    if (brandName.isEmpty) return const SizedBox.shrink();

                    final isSelected = _selectedBrand == brandName;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedBrand = brandName;
                          _selectedModel = null;
                          _selectedModelData = null; // Reset model data
                          _apiModels = [];
                        });
                        _fetchModels(brand['_id']);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryButton
                                : Colors.grey.shade200,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected
                                  ? AppColors.primaryButton.withValues(
                                      alpha: 0.1,
                                    )
                                  : Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryButton.withValues(
                                        alpha: 0.1,
                                      )
                                    : Colors.grey.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                LucideIcons.smartphone,
                                size: 32,
                                color: isSelected
                                    ? AppColors.primaryButton
                                    : Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              brandName,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  // STEP 2: MODEL SELECTION
  Widget _buildModelSelectionStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Model',
            style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Showing models for $_selectedBrand',
            style: GoogleFonts.inter(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          _isLoadingModels
              ? const Center(child: CircularProgressIndicator())
              : _apiModels.isEmpty
              ? const Center(child: Text('Please select a brand first'))
              : ListView.separated(
                  shrinkWrap: true,
                  primary: false,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _apiModels.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final modelName =
                        (_apiModels[index]['name'] ?? '') as String;
                    if (modelName.isEmpty) return const SizedBox.shrink();

                    final isSelected = _selectedModel == modelName;
                    return GestureDetector(
                      onTap: () => setState(() {
                        _selectedModel = modelName;
                        _selectedModelData =
                            _apiModels[index]; // Store full object

                        // Clear selected issues that are not available for this model
                        if (_selectedModelData != null &&
                            _selectedModelData!['repairPrices'] != null) {
                          final availableIssues =
                              (_selectedModelData!['repairPrices'] as List)
                                  .map((p) => p['issueName'] as String)
                                  .toSet();
                          _selectedIssues.retainWhere(
                            (issue) => availableIssues.contains(issue),
                          );
                        } else {
                          _selectedIssues.clear();
                        }
                      }),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryButton.withValues(alpha: 0.1)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryButton
                                : Colors.grey.shade200,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              modelName,
                              style: GoogleFonts.inter(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                LucideIcons.checkCircle,
                                color: AppColors.primaryButton,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  // STEP 3: SUMMARY
  Widget _buildSummaryStep() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDeviceHeader(),
          const SizedBox(height: 24),
          Text(
            'Booking Summary',
            style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          ..._selectedIssues.map((issue) {
            final item = _apiIssues.firstWhere((i) => i['name'] == issue);

            // Fetch model-specific price
            var displayPrice = '0';
            if (_selectedModelData != null &&
                _selectedModelData!['repairPrices'] != null) {
              final priceData = (_selectedModelData!['repairPrices'] as List)
                  .firstWhere(
                    (p) => p['issueName'] == issue,
                    orElse: () => null,
                  );
              if (priceData != null) {
                displayPrice = priceData['price'].toString();
              }
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child:
                        (item['imageUrl'] != null &&
                            item['imageUrl'].isNotEmpty)
                        ? (item['imageUrl'].toString().startsWith('assets')
                              ? Image.asset(
                                  item['imageUrl'],
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) =>
                                      const Icon(LucideIcons.image),
                                )
                              : Image.network(
                                  item['imageUrl'],
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) =>
                                      const Icon(LucideIcons.image),
                                ))
                        : Icon(_getIcon(item['icon']), size: 50),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          issue,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Warranty: 6 Months',
                          style: GoogleFonts.inter(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '₹$displayPrice',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.primaryButton,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 20), // Bottom padding for total bar space
        ],
      ),
    );
  }

  // STEP 4: TECHNICIAN
  Widget _buildTechnicianStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Text(
            'Choose Specialist',
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.textHeading,
              letterSpacing: -0.5,
            ),
          ).animate().fadeIn().slideX(begin: -0.1),
          Text(
            'Select an expert technician for your device',
            style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 24),
          _isLoadingTechs
              ? const Center(child: CircularProgressIndicator())
              : _apiTechnicians.isEmpty
              ? _buildNoTechs()
              : ListView.builder(
                  shrinkWrap: true,
                  primary: false,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _apiTechnicians.length,
                  itemBuilder: (context, index) {
                    final tech = _apiTechnicians[index];
                    final isSelected = _selectedTechIndex == index;
                    final isOnline = tech['isOnline'] == true;

                    return GestureDetector(
                      onTap: () => setState(() => _selectedTechIndex = index),
                      child: Opacity(
                        opacity: isOnline ? 1.0 : 0.5,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryButton
                                  : isOnline
                                  ? Colors.grey.shade100
                                  : Colors.grey.shade300,
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected
                                    ? AppColors.primaryButton.withOpacity(0.1)
                                    : Colors.black.withOpacity(0.04),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Row(
                                    children: [
                                      Stack(
                                        children: [
                                          Hero(
                                            tag: 'tech_p_${tech['_id']}',
                                            child: Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: isSelected
                                                      ? AppColors.primaryButton
                                                            .withOpacity(0.2)
                                                      : Colors.grey.shade100,
                                                  width: 3,
                                                ),
                                              ),
                                              child: CircleAvatar(
                                                radius: 35,
                                                backgroundColor:
                                                    Colors.grey.shade50,
                                                backgroundImage:
                                                    tech['photoUrl'] != null &&
                                                        tech['photoUrl']
                                                            .toString()
                                                            .isNotEmpty
                                                    ? NetworkImage(
                                                        tech['photoUrl'],
                                                      )
                                                    : const AssetImage(
                                                            'assets/images/tech_avatar_1.png',
                                                          )
                                                          as ImageProvider,
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            right: 2,
                                            bottom: 2,
                                            child: Container(
                                              width: 14,
                                              height: 14,
                                              decoration: BoxDecoration(
                                                color: isOnline
                                                    ? Colors.green
                                                    : Colors.grey,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: Colors.white,
                                                  width: 2,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    tech['name'] ??
                                                        'Technician',
                                                    style: GoogleFonts.poppins(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18,
                                                      color:
                                                          AppColors.textHeading,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                if (isSelected)
                                                  const Icon(
                                                    LucideIcons.checkCircle2,
                                                    color:
                                                        AppColors.primaryButton,
                                                    size: 20,
                                                  ).animate().scale(),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(
                                                  LucideIcons.star,
                                                  size: 14,
                                                  color: Colors.amber,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${tech['averageRating']?.toString() ?? '0.0'}',
                                                  style: GoogleFonts.inter(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  '•',
                                                  style: TextStyle(
                                                    color: Colors.grey[400],
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  '${tech['totalReviews'] ?? 0} reviews',
                                                  style: GoogleFonts.inter(
                                                    color: Colors.grey[500],
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            if ((tech['repairExpertise']
                                                        as List?)
                                                    ?.isNotEmpty ??
                                                false)
                                              Wrap(
                                                spacing: 6,
                                                runSpacing: 4,
                                                children: (tech['repairExpertise'] as List)
                                                    .take(2)
                                                    .map<Widget>(
                                                      (r) => Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 10,
                                                              vertical: 4,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: AppColors
                                                              .primaryButton
                                                              .withOpacity(
                                                                0.05,
                                                              ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                10,
                                                              ),
                                                        ),
                                                        child: Text(
                                                          r['name'] ?? '',
                                                          style: GoogleFonts.inter(
                                                            fontSize: 10,
                                                            color: AppColors
                                                                .primaryButton,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                    .toList(),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                    horizontal: 20,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primaryButton.withOpacity(
                                            0.03,
                                          )
                                        : Colors.grey.shade50,
                                    border: Border(
                                      top: BorderSide(
                                        color: Colors.grey.shade100,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                                width: 8,
                                                height: 8,
                                                decoration: BoxDecoration(
                                                  color: isOnline
                                                      ? Colors.green
                                                      : Colors.grey,
                                                  shape: BoxShape.circle,
                                                ),
                                              )
                                              .animate(
                                                onPlay: (c) => isOnline
                                                    ? c.repeat()
                                                    : c.stop(),
                                              )
                                              .scale(
                                                end: const Offset(1.5, 1.5),
                                              )
                                              .fade(),
                                          const SizedBox(width: 8),
                                          Text(
                                            isOnline
                                                ? 'ONLINE NOW'
                                                : 'OFFLINE NOW',
                                            style: GoogleFonts.inter(
                                              color: isOnline
                                                  ? Colors.green
                                                  : Colors.grey[600],
                                              fontWeight: FontWeight.w800,
                                              fontSize: 11,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (c) =>
                                                  TechnicianProfilePage(
                                                    technician: tech,
                                                  ),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: Colors.grey.shade200,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.05,
                                                ),
                                                blurRadius: 5,
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            children: [
                                              Text(
                                                'View Profile',
                                                style: GoogleFonts.inter(
                                                  color: AppColors.textHeading,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              const Icon(
                                                LucideIcons.chevronRight,
                                                size: 14,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: (index * 150).ms).slideY(begin: 0.1),
                    );
                  },
                ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildNoTechs() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          Icon(LucideIcons.userX, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No Technicians Found',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We couldn\'t find any specialists for this service in your area right now.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  // STEP 5: SCHEDULE
  Widget _buildScheduleStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Date & Time',
            style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          // Luxurious Calendar (Month View Grid)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'October 2024', // Mock Month
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Icon(LucideIcons.chevronRight),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                      .map(
                        (d) => SizedBox(
                          width: 30,
                          child: Center(
                            child: Text(
                              d,
                              style: GoogleFonts.inter(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  primary: false,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: 31,
                  itemBuilder: (context, index) {
                    final day = index + 1;
                    final isSelected = day == _selectedDate.day;
                    // Mock disabled past days: assume today is 15th
                    final isPast = day < 15;
                    return GestureDetector(
                      onTap: isPast
                          ? null
                          : () => setState(
                              () => _selectedDate = DateTime(2024, 10, day),
                            ),
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryButton
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$day',
                            style: GoogleFonts.inter(
                              color: isSelected
                                  ? Colors.white
                                  : (isPast ? Colors.grey[300] : Colors.black),
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Available Slots',
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // Grid Layout for Time Slots
          GridView.builder(
            shrinkWrap: true,
            primary: false,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.2,
            ),
            itemCount: _timeSlots.length,
            itemBuilder: (context, index) {
              final slot = _timeSlots[index];
              final isSelected = _selectedTimeSlot == slot;
              return GestureDetector(
                onTap: () => setState(() => _selectedTimeSlot = slot),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryButton : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryButton
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    slot.split(' - ')[0], // Simpler time
                    style: GoogleFonts.inter(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w500,
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

  // STEP 6: CHECKOUT
  Widget _buildCheckoutStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Checkout',
            style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          // Address Selector
          Row(
            children: [
              Text(
                'Delivery Address',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '*',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _showAddressBottomSheet,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _address.isEmpty ? Colors.red.shade50 : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _address.isEmpty
                      ? Colors.red.shade300
                      : Colors.grey.shade200,
                  width: _address.isEmpty ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _address.isEmpty
                          ? Colors.red.shade100
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      LucideIcons.mapPin,
                      color: _address.isEmpty
                          ? Colors.red
                          : AppColors.primaryButton,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _address.isEmpty
                              ? 'Select Address'
                              : _address.split(',')[0],
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            color: _address.isEmpty
                                ? Colors.red.shade700
                                : Colors.black,
                          ),
                        ),
                        if (_address.isNotEmpty)
                          Text(
                            _address,
                            style: GoogleFonts.inter(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  const Icon(LucideIcons.chevronRight, color: Colors.grey),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),
          Text(
            'Payment Method',
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildPaymentOption(
            'UPI (GPay / PhonePe)',
            LucideIcons.smartphone,
            0,
          ),
          const SizedBox(height: 12),
          _buildPaymentOption('Credit / Debit Card', LucideIcons.creditCard, 1),
          const SizedBox(height: 12),
          _buildPaymentOption('Cash After Repair', LucideIcons.banknote, 2),
        ],
      ),
    );
  }

  void _showAddressBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Address',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Saved addresses title
              Text(
                'Select Saved Address',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              // Saved addresses
              if (_isLoadingAddresses)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_userAddresses.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'No saved addresses yet',
                      style: GoogleFonts.inter(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ),
                )
              else
                ..._userAddresses.map(
                  (addr) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _selectedAddressId == addr['_id']
                              ? AppColors.primaryButton.withOpacity(0.1)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          LucideIcons.mapPin,
                          size: 20,
                          color: _selectedAddressId == addr['_id']
                              ? AppColors.primaryButton
                              : Colors.grey.shade600,
                        ),
                      ),
                      title: Text(
                        addr['label'] ?? 'Address',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        addr['fullAddress'] ?? '',
                        style: GoogleFonts.inter(fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: _selectedAddressId == addr['_id']
                          ? const Icon(
                              LucideIcons.checkCircle2,
                              color: AppColors.primaryButton,
                              size: 20,
                            )
                          : const Icon(LucideIcons.chevronRight, size: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: _selectedAddressId == addr['_id']
                              ? AppColors.primaryButton
                              : Colors.grey.shade200,
                          width: _selectedAddressId == addr['_id'] ? 2 : 1,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _selectedAddressId = addr['_id'];
                          _address = addr['fullAddress'] ?? '';
                          _addressLat = addr['latitude']?.toDouble();
                          _addressLng = addr['longitude']?.toDouble();
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '✅ Address selected: ${addr['label']}',
                            ),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Add New Address
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _openLocationPicker();
                  },
                  icon: const Icon(LucideIcons.plus),
                  label: const Text('Add New Address'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppColors.primaryButton),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Open Location Picker to get current GPS location
  Future<void> _openLocationPicker() async {
    final result = await Navigator.push<LocationData>(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerPage(
          initialLat: _addressLat,
          initialLng: _addressLng,
        ),
      ),
    );

    if (result != null && result.address != null) {
      setState(() {
        _address = result.address!;
        _addressLat = result.latitude;
        _addressLng = result.longitude;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ Address selected: ${result.address!.split(',').first}',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildPaymentOption(String label, IconData icon, int value) {
    final isSelected = _paymentMethod == value;
    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryButton : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primaryButton : Colors.grey,
            ),
            const SizedBox(width: 16),
            Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
            const Spacer(),
            if (isSelected)
              const Icon(
                LucideIcons.checkCircle,
                color: AppColors.primaryButton,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(LucideIcons.smartphone, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$_selectedBrand $_selectedModel',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold),
              ),
              Text(
                'Selected Issues: ${_selectedIssues.length}',
                style: GoogleFonts.inter(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getIssueImagePath(String issueName) {
    final name = issueName.toLowerCase();
    if (name.contains('front camera')) {
      return 'assets/images/issues/issue_frontcamera.png';
    }
    if (name.contains('receiver') || name.contains('ear speaker')) {
      return 'assets/images/issues/issue_speaker.png';
    }
    if (name.contains('speaker')) {
      return 'assets/images/issues/issue_speakerback.png';
    }
    if (name.contains('camera')) return 'assets/images/issues/issue_camera.png';
    if (name.contains('battery'))
      return 'assets/images/issues/issue_battery.png';
    if (name.contains('screen') || name.contains('display')) {
      return 'assets/images/issues/issue_screen.png';
    }
    if (name.contains('charging') ||
        name.contains('jack') ||
        name.contains('port')) {
      return 'assets/images/issues/issue_charging.png';
    }
    if (name.contains('mic')) return 'assets/images/issues/issue_mic.png';
    if (name.contains('speaker') || name.contains('receiver')) {
      return 'assets/images/issues/issue_speakerback.png';
    }
    if (name.contains('face id'))
      return 'assets/images/issues/issue_faceid.png';
    if (name.contains('water') || name.contains('liquid')) {
      return 'assets/images/issues/issue_water.png';
    }
    if (name.contains('software'))
      return 'assets/images/issues/issue_software.png';
    if (name.contains('motherboard') || name.contains('ic')) {
      return 'assets/images/issues/issue_motherboard.png';
    }
    if (name.contains('sensor'))
      return 'assets/images/issues/issue_sensors.png';
    if (name.contains('glass'))
      return 'assets/images/issues/issue_backglass.png';

    return '';
  }
}
