import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme.dart';
import '../data/device_data.dart';
import 'thank_you_page.dart';
import 'profile_page.dart';

import 'technician_profile_page.dart';

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
  int _currentStep = 0;
  // Steps: 0:Issues, 1:Brand, 2:Model, 3:Summary, 4:Tech, 5:Schedule, 6:Checkout
  final int _totalSteps = 7;

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
    }
  }

  // Selection State
  final Set<String> _selectedIssues = {};
  String? _selectedBrand;
  String? _selectedModel;

  int _selectedTechIndex = -1;
  DateTime _selectedDate = DateTime.now();
  String? _selectedTimeSlot;
  int _paymentMethod = 0; // 0: UPI, 1: Card, 2: Cash
  String _address = '';

  // Mock User Addresses
  final List<String> _userAddresses = [
    'Home: 12-A, Green Park, New Delhi',
    'Office: 404, Cyber Hub, Gurugram',
  ];

  final List<Map<String, dynamic>> _technicians = [
    {
      'name': 'Alex Johnson',
      'rating': 4.8,
      'jobs': 120,
      'image': 'assets/images/tech_avatar_1.png',
    },
    {
      'name': 'Sarah Smith',
      'rating': 4.9,
      'jobs': 210,
      'image': 'assets/images/tech_avatar_2.png',
    },
    {
      'name': 'Mike Davis',
      'rating': 4.7,
      'jobs': 95,
      'image': 'assets/images/tech_avatar_3.png',
    },
  ];

  final List<String> _timeSlots = [
    '10:00 AM - 11:00 AM',
    '11:00 AM - 12:00 PM',
    '01:00 PM - 02:00 PM',
    '02:00 PM - 03:00 PM',
    '04:00 PM - 05:00 PM',
    '06:00 PM - 07:00 PM',
  ];

  void _nextStep() {
    // Validation
    if (_currentStep == 0 && _selectedIssues.isEmpty) {
      _showSnack('Please select at least one issue');
      return;
    }
    if (_currentStep == 1 && _selectedBrand == null) {
      _showSnack('Please select a brand');
      return;
    }
    if (_currentStep == 2 && _selectedModel == null) {
      _showSnack('Please select a model');
      return;
    }
    if (_currentStep == 4 && _selectedTechIndex == -1) {
      _showSnack('Please select a technician');
      return;
    }
    if (_currentStep == 5 && _selectedTimeSlot == null) {
      _showSnack('Please select a time slot');
      return;
    }

    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
    } else {
      // Confirm Booking
      print('Booking Confirmed:');
      print('Issues: $_selectedIssues');
      print('Device: $_selectedBrand $_selectedModel');
      print('Address: $_address');
      print('Payment Method: $_paymentMethod');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (c) => const ThankYouPage()),
      );
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 1)),
    );
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      Navigator.pop(context);
    }
  }

  int _calculateTotal() {
    int total = 0;
    for (var issueName in _selectedIssues) {
      total += DeviceData.issueData[issueName]!['price'] as int;
    }
    return total;
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
              MaterialPageRoute(builder: (c) => const ProfilePage()),
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
            backgroundColor: Colors.grey[100],
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
                border: Border(top: BorderSide(color: Colors.grey[200]!)),
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
                          color: Colors.grey[600],
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
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
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
                        side: BorderSide(color: Colors.grey[300]!),
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
                    onPressed: _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryButton,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _currentStep == _totalSteps - 1
                          ? 'Confirm Booking'
                          : 'Next',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
        return _buildIssueSelectionStep();
      case 1:
        return _buildBrandSelectionStep();
      case 2:
        return _buildModelSelectionStep();
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
          GridView.builder(
            shrinkWrap: true,
            primary: false,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: DeviceData.issueData.length,
            itemBuilder: (context, index) {
              final key = DeviceData.issueData.keys.elementAt(index);
              final data = DeviceData.issueData[key]!;
              final isSelected = _selectedIssues.contains(key);

              return GestureDetector(
                onTap: () => setState(() {
                  if (isSelected)
                    _selectedIssues.remove(key);
                  else
                    _selectedIssues.add(key);
                }),
                child: Container(
                  key: ValueKey(key),
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryButton
                                  : Colors.grey[200]!,
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.asset(
                                  data['image'],
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => const Center(
                                    child: Icon(LucideIcons.image),
                                  ),
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
                      Text(
                        '₹${data['price']}',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: AppColors.primaryButton,
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
          GridView.builder(
            shrinkWrap: true,
            primary: false,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.2,
            ),
            itemCount: DeviceData.brands.length,
            itemBuilder: (context, index) {
              final brand = DeviceData.brands[index];
              final isSelected = _selectedBrand == brand['name'];
              return GestureDetector(
                onTap: () => setState(() {
                  _selectedBrand = brand['name'] as String;
                  _selectedModel = null; // Reset model on brand change
                }),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryButton
                          : Colors.grey[200]!,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? AppColors.primaryButton.withOpacity(0.1)
                            : Colors.black.withOpacity(0.05),
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
                              ? AppColors.primaryButton.withOpacity(0.1)
                              : Colors.grey[50],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          brand['icon'] as IconData,
                          size: 32,
                          color: isSelected
                              ? AppColors.primaryButton
                              : Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        brand['name'] as String,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isSelected
                              ? AppColors.primaryButton
                              : Colors.black,
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
    final models = DeviceData.modelsByBrand[_selectedBrand] ?? [];
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
          ListView.builder(
            shrinkWrap: true,
            primary: false,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: models.length,
            itemBuilder: (context, index) {
              final model = models[index];
              final isSelected = _selectedModel == model;
              return GestureDetector(
                onTap: () => setState(() => _selectedModel = model),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryButton
                          : Colors.grey[200]!,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        model,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
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
            final data = DeviceData.issueData[issue]!;
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      data['image'],
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => const Icon(LucideIcons.image),
                    ),
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
                          'Warranty: ${data['warranty']}',
                          style: GoogleFonts.inter(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '₹${data['price']}',
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Technician',
            style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          ListView.builder(
            shrinkWrap: true,
            primary: false,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _technicians.length,
            itemBuilder: (context, index) {
              final tech = _technicians[index];
              final isSelected = _selectedTechIndex == index;
              return GestureDetector(
                onTap: () => setState(() => _selectedTechIndex = index),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryButton
                          : Colors.grey[200]!,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 35,
                              backgroundImage: AssetImage(tech['image']),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tech['name'],
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        LucideIcons.star,
                                        size: 16,
                                        color: Colors.amber,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${tech['rating']}',
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        ' (${tech['jobs']} repairs)',
                                        style: GoogleFonts.inter(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                LucideIcons.checkCircle,
                                color: AppColors.primaryButton,
                                size: 28,
                              ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(20),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Available Today',
                              style: GoogleFonts.inter(
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (c) =>
                                        TechnicianProfilePage(technician: tech),
                                  ),
                                );
                              },
                              child: Text(
                                'See Profile',
                                style: GoogleFonts.inter(
                                  color: AppColors.primaryButton,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
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
                  color: Colors.black.withOpacity(0.05),
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
                          : Colors.grey[300]!,
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
          Text(
            'Delivery Address',
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _showAddressBottomSheet,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      LucideIcons.mapPin,
                      color: AppColors.primaryButton,
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
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
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
              ..._userAddresses.map(
                (addr) => ListTile(
                  leading: const Icon(LucideIcons.mapPin),
                  title: Text(
                    addr.split(':')[0],
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(addr.split(':')[1].trim()),
                  onTap: () {
                    setState(() => _address = addr);
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Logic to add new address
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Feature coming soon!')),
                    );
                  },
                  icon: const Icon(LucideIcons.plus),
                  label: const Text('Add New Address'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppColors.primaryButton),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
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
            color: isSelected ? AppColors.primaryButton : Colors.grey[200]!,
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
        color: Colors.grey[50],
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
}
