// Device Search Widget for Hero Section
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:ziyonstar/responsive.dart';
import 'package:ziyonstar/theme.dart';

class _DeviceSearchWidget extends StatefulWidget {
  const _DeviceSearchWidget();

  @override
  State<_DeviceSearchWidget> createState() => _DeviceSearchWidgetState();
}

class _DeviceSearchWidgetState extends State<_DeviceSearchWidget> {
  String? selectedBrand;
  String? selectedModel;

  final Map<String, List<String>> brandModels = {
    'Apple': [
      'iPhone 15 Pro Max',
      'iPhone 15 Pro',
      'iPhone 15',
      'iPhone 14 Pro Max',
      'iPhone 14 Pro',
      'iPhone 14',
      'iPhone 13 Pro Max',
      'iPhone 13',
      'iPhone 12',
    ],
    'Samsung': [
      'Galaxy S24 Ultra',
      'Galaxy S24+',
      'Galaxy S24',
      'Galaxy S23 Ultra',
      'Galaxy S23',
      'Galaxy Z Fold 5',
      'Galaxy Z Flip 5',
      'Galaxy A54',
    ],
    'Google': [
      'Pixel 8 Pro',
      'Pixel 8',
      'Pixel 7 Pro',
      'Pixel 7',
      'Pixel 6 Pro',
      'Pixel 6',
    ],
    'OnePlus': [
      'OnePlus 12',
      'OnePlus 11',
      'OnePlus 10 Pro',
      'OnePlus 9 Pro',
      'OnePlus Nord 3',
    ],
    'Xiaomi': [
      'Xiaomi 14 Pro',
      'Xiaomi 13 Pro',
      'Xiaomi 12 Pro',
      'Redmi Note 13 Pro',
      'Redmi Note 12 Pro',
    ],
    'Oppo': ['Find X6 Pro', 'Find X5 Pro', 'Reno 11 Pro', 'Reno 10 Pro', 'A78'],
    'Vivo': ['X100 Pro', 'X90 Pro', 'V29 Pro', 'V27 Pro', 'Y100'],
  };

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveLayout.isDesktop(context);

    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, const Color(0xFFF9FAFB)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryButton.withAlpha(15),
            blurRadius: 30,
            offset: const Offset(0, 10),
            spreadRadius: 2,
          ),
        ],
        border: Border.all(color: Colors.grey.withAlpha(20), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryButton.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  LucideIcons.search,
                  color: AppColors.primaryButton,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Find Your Device',
                style: GoogleFonts.poppins(
                  fontSize: isDesktop ? 18 : 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textHeading,
                ),
              ),
            ],
          ),
          SizedBox(height: isDesktop ? 20 : 16),

          // Brand Dropdown
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: selectedBrand,
                hint: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.smartphone,
                        size: 18,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Select Brand',
                        style: GoogleFonts.manrope(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                icon: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.grey.shade400,
                  ),
                ),
                items: brandModels.keys.map((String brand) {
                  return DropdownMenuItem<String>(
                    value: brand,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.smartphone,
                            size: 18,
                            color: AppColors.primaryButton,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            brand,
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedBrand = newValue;
                    selectedModel = null; // Reset model when brand changes
                  });
                },
                borderRadius: BorderRadius.circular(16),
                dropdownColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Model Dropdown
          Container(
            decoration: BoxDecoration(
              color: selectedBrand == null ? Colors.grey.shade50 : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selectedBrand == null
                    ? Colors.grey.shade100
                    : Colors.grey.shade200,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: selectedModel,
                hint: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.tablet,
                        size: 18,
                        color: selectedBrand == null
                            ? Colors.grey.shade300
                            : Colors.grey.shade400,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        selectedBrand == null
                            ? 'Select Brand First'
                            : 'Select Model',
                        style: GoogleFonts.manrope(
                          color: selectedBrand == null
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                icon: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: selectedBrand == null
                        ? Colors.grey.shade300
                        : Colors.grey.shade400,
                  ),
                ),
                items: selectedBrand == null
                    ? []
                    : brandModels[selectedBrand]!.map((String model) {
                        return DropdownMenuItem<String>(
                          value: model,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              model,
                              style: GoogleFonts.manrope(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                onChanged: selectedBrand == null
                    ? null
                    : (String? newValue) {
                        setState(() {
                          selectedModel = newValue;
                        });
                      },
                borderRadius: BorderRadius.circular(16),
                dropdownColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),

          SizedBox(height: isDesktop ? 20 : 16),

          // Search Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: selectedBrand != null && selectedModel != null
                  ? () {
                      // Handle search action
                      print('Searching for: $selectedBrand - $selectedModel');
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryButton,
                disabledBackgroundColor: Colors.grey.shade300,
                padding: EdgeInsets.symmetric(vertical: isDesktop ? 18 : 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: selectedBrand != null && selectedModel != null
                    ? 2
                    : 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.search,
                    size: 20,
                    color: selectedBrand != null && selectedModel != null
                        ? Colors.white
                        : Colors.grey.shade500,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Get Repair Quote',
                    style: GoogleFonts.poppins(
                      fontSize: isDesktop ? 16 : 14,
                      fontWeight: FontWeight.bold,
                      color: selectedBrand != null && selectedModel != null
                          ? Colors.white
                          : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.15, end: 0);
  }
}
