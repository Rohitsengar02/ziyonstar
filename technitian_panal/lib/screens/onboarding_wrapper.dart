import 'package:flutter/material.dart';
import '../theme.dart';
import 'steps/profile_step.dart';
import 'steps/kyc_step.dart';
import 'steps/brand_expertise_step.dart';
import 'steps/repair_expertise_step.dart';
import 'steps/remaining_steps.dart';
import 'dashboard_screen.dart';

class OnboardingWrapper extends StatefulWidget {
  const OnboardingWrapper({super.key});

  @override
  State<OnboardingWrapper> createState() => _OnboardingWrapperState();
}

class _OnboardingWrapperState extends State<OnboardingWrapper> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _nextPage() {
    if (_currentPage < 8) {
      // 9 steps total (0-8)
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Complete Onboarding
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Step ${_currentPage + 1} of 9'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _prevPage,
        ),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentPage + 1) / 9,
            backgroundColor: AppColors.background,
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppColors.primaryButton,
            ),
            minHeight: 4,
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(), // Disable swipe
              onPageChanged: (index) => setState(() => _currentPage = index),
              children: [
                ProfileStep(onNext: _nextPage),
                KycStep(onNext: _nextPage),
                BrandExpertiseStep(onNext: _nextPage),
                RepairExpertiseStep(onNext: _nextPage),
                ServiceTypeStep(onNext: _nextPage),
                CoverageStep(onNext: _nextPage),
                BankStep(onNext: _nextPage),
                AgreementStep(onNext: _nextPage),
                StatusStep(
                  onNext: _nextPage,
                ), // Final step might navigate to dashboard itself or call onNext which does it
              ],
            ),
          ),
        ],
      ),
    );
  }
}
