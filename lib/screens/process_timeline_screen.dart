import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme.dart';
import '../responsive.dart';
import '../widgets/navbar.dart';
import '../widgets/footer.dart';
import '../widgets/app_drawer.dart';

class ProcessTimelineScreen extends StatefulWidget {
  const ProcessTimelineScreen({super.key});

  @override
  State<ProcessTimelineScreen> createState() => _ProcessTimelineScreenState();
}

class _ProcessTimelineScreenState extends State<ProcessTimelineScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _currentStep = 0;

  // Form Data
  String? _selectedBrand;
  String? _selectedModel;
  final List<String> _selectedIssues = [];
  String _repairMethod = 'Pickup';
  DateTime? _selectedDate;
  String? _selectedTimeSlot;

  // Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // Mock Data
  final List<Map<String, dynamic>> _brands = [
    {'name': 'Apple', 'icon': LucideIcons.smartphone},
    {'name': 'Samsung', 'icon': LucideIcons.smartphone},
    {'name': 'Google', 'icon': LucideIcons.smartphone},
    {'name': 'OnePlus', 'icon': LucideIcons.smartphone},
    {'name': 'Xiaomi', 'icon': LucideIcons.smartphone},
    {'name': 'Oppo', 'icon': LucideIcons.smartphone},
  ];

  final List<String> _models = [
    'iPhone 15 Pro Max',
    'iPhone 15 Pro',
    'iPhone 15',
    'iPhone 14 Pro Max',
    'iPhone 14',
    'Samsung S24 Ultra',
    'Samsung S24',
    'Pixel 8 Pro',
    'Pixel 8',
  ];

  final List<Map<String, dynamic>> _issues = [
    {'name': 'Screen Damage', 'price': 120, 'icon': LucideIcons.smartphone},
    {'name': 'Battery Issue', 'price': 60, 'icon': LucideIcons.battery},
    {'name': 'Charging Port', 'price': 45, 'icon': LucideIcons.plugZap},
    {'name': 'Camera', 'price': 80, 'icon': LucideIcons.camera},
    {'name': 'Speaker/Mic', 'price': 40, 'icon': LucideIcons.speaker},
    {'name': 'Water Damage', 'price': 100, 'icon': LucideIcons.droplets},
  ];

  void _nextStep() {
    setState(() {
      if (_currentStep < 7) _currentStep++;
    });
  }

  void _prevStep() {
    setState(() {
      if (_currentStep > 0) _currentStep--;
    });
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _selectedBrand != null;
      case 1:
        return _selectedModel != null;
      case 2:
        return _selectedIssues.isNotEmpty;
      case 5:
        return _selectedDate != null && _selectedTimeSlot != null;
      case 6:
        return _nameController.text.isNotEmpty &&
            _phoneController.text.isNotEmpty &&
            _emailController.text.isNotEmpty &&
            (_repairMethod == 'Walk-in' || _addressController.text.isNotEmpty);
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF9FAFB),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section with Navbar
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    const Color(0xFFF9FAFB),
                    const Color(0xFFF3F4F6),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? screenWidth * 0.08 : 20,
                      vertical: isDesktop ? 20 : 16,
                    ),
                    child: Navbar(scaffoldKey: _scaffoldKey),
                  ),
                  if (!isDesktop) // Simple back button for mobile if needed, or rely on Navbar (Home)
                    Padding(
                      padding: const EdgeInsets.only(left: 20, bottom: 16),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios, size: 20),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Main Content Area
            Container(
              constraints: const BoxConstraints(minHeight: 600),
              padding: EdgeInsets.symmetric(
                vertical: isDesktop ? 60 : 20,
                horizontal: isDesktop ? screenWidth * 0.1 : 20,
              ),
              child: Column(
                children: [
                  // Title
                  Text(
                    'Book Your Repair',
                    style: GoogleFonts.inter(
                      fontSize: isDesktop ? 48 : 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textHeading,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Professional service for your premium devices. Fast, reliable, and secure.',
                    style: GoogleFonts.inter(
                      fontSize: isDesktop ? 18 : 16,
                      color: AppColors.textBody,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Wizard Card
                  Container(
                    constraints: const BoxConstraints(maxWidth: 1000),
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
                    ),
                    child: Column(
                      children: [
                        // Progress Bar
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey.shade100),
                            ),
                          ),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: (_currentStep + 1) / 8,
                                  backgroundColor: Colors.grey[100],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primaryButton,
                                  ),
                                  minHeight: 8,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Step ${_currentStep + 1} of 8',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryButton,
                                    ),
                                  ),
                                  Text(
                                    _getStepTitle(_currentStep),
                                    style: GoogleFonts.inter(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Step Content
                        Padding(
                          padding: EdgeInsets.all(isDesktop ? 40 : 20),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: KeyedSubtree(
                              key: ValueKey(_currentStep),
                              child: _buildCurrentStep(isDesktop),
                            ),
                          ),
                        ),

                        // Actions
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Colors.grey.shade100),
                            ),
                            color: Colors.grey.shade50,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(24),
                              bottomRight: Radius.circular(24),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (_currentStep > 0)
                                TextButton.icon(
                                  onPressed: _prevStep,
                                  icon: Icon(
                                    Icons.arrow_back,
                                    color: Colors.grey[600],
                                  ),
                                  label: Text(
                                    'Back',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                )
                              else
                                const SizedBox.shrink(),

                              ElevatedButton(
                                onPressed: _canProceed() ? _nextStep : null,
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
                                child: Text(
                                  _currentStep == 7 ? 'Book Now' : 'Continue',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
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
            ),

            // Footer
            const Footer(),
          ],
        ),
      ),
    );
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 0:
        return 'Select Brand';
      case 1:
        return 'Select Model';
      case 2:
        return 'Identify Issues';
      case 3:
        return 'Estimated Price';
      case 4:
        return 'Repair Method';
      case 5:
        return 'Schedule';
      case 6:
        return 'Your Details';
      case 7:
        return 'Confirm';
      default:
        return '';
    }
  }

  Widget _buildCurrentStep(bool isDesktop) {
    switch (_currentStep) {
      case 0:
        return _buildBrandSelection(isDesktop);
      case 1:
        return _buildModelSelection(isDesktop);
      case 2:
        return _buildIssueSelection(isDesktop);
      case 3:
        return _buildPriceEstimate(isDesktop);
      case 4:
        return _buildMethodSelection(isDesktop);
      case 5:
        return _buildScheduleSelection(isDesktop);
      case 6:
        return _buildContactForm(isDesktop);
      case 7:
        return _buildSummary(isDesktop);
      default:
        return const SizedBox.shrink();
    }
  }

  // Steps Implementation (Same as before but wrapped in Columns for consistency)

  // Step 1: Brand Selection
  Widget _buildBrandSelection(bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Brand', style: _headingStyle),
        const SizedBox(height: 24),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isDesktop ? 4 : 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: _brands.length,
          itemBuilder: (context, index) {
            final brand = _brands[index];
            final isSelected = _selectedBrand == brand['name'];
            return _SelectionCard(
              isSelected: isSelected,
              onTap: () => setState(() => _selectedBrand = brand['name']),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    brand['icon'] as IconData,
                    size: 40,
                    color: isSelected ? AppColors.primaryButton : Colors.grey,
                  ),
                  const SizedBox(height: 12),
                  Text(brand['name'] as String, style: _labelStyle),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // Step 2: Model Selection
  Widget _buildModelSelection(bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Model', style: _headingStyle),
        const SizedBox(height: 24),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _models.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final model = _models[index];
            final isSelected = _selectedModel == model;
            return _SelectionCard(
              isSelected: isSelected,
              onTap: () => setState(() => _selectedModel = model),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.smartphone,
                      color: isSelected ? AppColors.primaryButton : Colors.grey,
                    ),
                    const SizedBox(width: 16),
                    Text(model, style: _labelStyle),
                    const Spacer(),
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

  // Step 3: Issue Selection
  Widget _buildIssueSelection(bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('What\'s wrong?', style: _headingStyle),
        const SizedBox(height: 8),
        Text(
          'Select all that apply',
          style: GoogleFonts.inter(color: Colors.grey),
        ),
        const SizedBox(height: 24),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isDesktop ? 3 : 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.9,
          ),
          itemCount: _issues.length,
          itemBuilder: (context, index) {
            final issue = _issues[index];
            final isSelected = _selectedIssues.contains(issue['name']);
            return _SelectionCard(
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedIssues.remove(issue['name']);
                  } else {
                    _selectedIssues.add(issue['name'] as String);
                  }
                });
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryButton.withAlpha(20)
                          : Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      issue['icon'] as IconData,
                      size: 28,
                      color: isSelected ? AppColors.primaryButton : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    issue['name'] as String,
                    style: _labelStyle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${issue['price']}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryButton,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // Step 4: Price Estimate
  Widget _buildPriceEstimate(bool isDesktop) {
    final total = _issues
        .where((i) => _selectedIssues.contains(i['name']))
        .fold(0, (sum, i) => sum + (i['price'] as int));

    return Column(
      children: [
        Text('Estimated Repair Cost', style: _headingStyle),
        const SizedBox(height: 40),
        Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryButton.withAlpha(40),
                blurRadius: 40,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(color: AppColors.primaryButton.withAlpha(50)),
          ),
          child: Column(
            children: [
              Text(
                '\$$total',
                style: GoogleFonts.inter(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryButton,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Includes logic board diagnosis & service fee',
                style: GoogleFonts.inter(color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Step 5: Method Selection
  Widget _buildMethodSelection(bool isDesktop) {
    final methods = [
      {
        'name': 'Pickup',
        'desc': 'We pick up your device, repair it, and deliver it back.',
        'icon': LucideIcons.truck,
      },
      {
        'name': 'Walk-in',
        'desc': 'Visit our nearest service center.',
        'icon': LucideIcons.store,
      },
      {
        'name': 'Doorstep',
        'desc': 'Our technician visits your location.',
        'icon': LucideIcons.home,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Repair Method', style: _headingStyle),
        const SizedBox(height: 24),
        ...methods.map(
          (m) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _SelectionCard(
              isSelected: _repairMethod == m['name'],
              onTap: () => setState(() => _repairMethod = m['name'] as String),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryButton.withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        m['icon'] as IconData,
                        color: AppColors.primaryButton,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m['name'] as String, style: _labelStyle),
                          const SizedBox(height: 4),
                          Text(
                            m['desc'] as String,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_repairMethod == m['name'])
                      const Icon(
                        LucideIcons.checkCircle,
                        color: AppColors.primaryButton,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Step 6: Schedule
  Widget _buildScheduleSelection(bool isDesktop) {
    final times = ['10:00 AM', '11:00 AM', '01:00 PM', '03:00 PM', '05:00 PM'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Schedule Service', style: _headingStyle),
        const SizedBox(height: 24),
        Text('Select Date', style: _labelStyle),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.separated(
            itemCount: 7,
            scrollDirection: Axis.horizontal,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final date = DateTime.now().add(Duration(days: index + 1));
              final isSelected = _selectedDate?.day == date.day;
              return _SelectionCard(
                isSelected: isSelected,
                onTap: () => setState(() => _selectedDate = date),
                child: Container(
                  width: 70,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${date.day}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: isSelected
                              ? AppColors.primaryButton
                              : Colors.black,
                        ),
                      ),
                      Text(
                        [
                          'Mon',
                          'Tue',
                          'Wed',
                          'Thu',
                          'Fri',
                          'Sat',
                          'Sun',
                        ][date.weekday - 1],
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 32),
        Text('Select Time', style: _labelStyle),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: times
              .map(
                (time) => InkWell(
                  onTap: () => setState(() => _selectedTimeSlot = time),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: _selectedTimeSlot == time
                          ? AppColors.primaryButton
                          : Colors.white,
                      border: Border.all(
                        color: _selectedTimeSlot == time
                            ? AppColors.primaryButton
                            : Colors.grey.shade300,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      time,
                      style: TextStyle(
                        color: _selectedTimeSlot == time
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  // Step 7: Contact Form
  Widget _buildContactForm(bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your Details', style: _headingStyle),
        const SizedBox(height: 24),
        TextField(
          controller: _nameController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: 'Full Name',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _phoneController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: 'Phone Number',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _emailController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: 'Email Address',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        if (_repairMethod != 'Walk-in') ...[
          const SizedBox(height: 16),
          TextField(
            controller: _addressController,
            onChanged: (_) => setState(() {}),
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Pickup/Doorstep Address',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // Step 8: Summary
  Widget _buildSummary(bool isDesktop) {
    final total = _issues
        .where((i) => _selectedIssues.contains(i['name']))
        .fold(0, (sum, i) => sum + (i['price'] as int));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Booking Summary', style: _headingStyle),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              _summaryRow('Device', '$_selectedBrand $_selectedModel'),
              _divider(),
              _summaryRow('Issues', _selectedIssues.join(', ')),
              _divider(),
              _summaryRow('Date', _selectedDate.toString().split(' ')[0]),
              _summaryRow('Time', _selectedTimeSlot ?? ''),
              _divider(),
              _summaryRow('Method', _repairMethod),
              _divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '\$$total',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryButton,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withAlpha(20),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(LucideIcons.shieldCheck, color: Colors.green),
              const SizedBox(width: 12),
              const Text(
                'Warranty included. Pay after service is done.',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _divider() => Container(
    height: 1,
    color: Colors.grey[200],
    margin: const EdgeInsets.symmetric(vertical: 12),
  );

  final TextStyle _headingStyle = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textHeading,
  );
  final TextStyle _labelStyle = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textHeading,
  );
}

class _SelectionCard extends StatelessWidget {
  final Widget child;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectionCard({
    required this.child,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryButton : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primaryButton.withAlpha(20)
                  : Colors.black.withAlpha(5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
