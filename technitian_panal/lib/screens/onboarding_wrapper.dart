import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../widgets/auth_sidebar.dart';
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
    if (_currentPage < 7) {
      // 8 steps total (0-7)
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth >= 900;
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: isDesktop
              ? null
              : AppBar(
                  title: Text('Step ${_currentPage + 1} of 8'),
                  centerTitle: true,
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: _prevPage,
                  ),
                ),
          body: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
        );
      },
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Left Side Animated Sidebar
        Expanded(
          flex: 1,
          child: AuthSidebar(currentStep: _currentPage + 1, totalSteps: 8),
        ),
        // Right Side Form
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Desktop Header
              _buildDesktopHeader(),
              LinearProgressIndicator(
                value: (_currentPage + 1) / 8,
                backgroundColor: AppColors.background,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primaryButton,
                ),
                minHeight: 4,
              ),
              const SizedBox(height: 20),
              Expanded(child: _buildPageView()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        LinearProgressIndicator(
          value: (_currentPage + 1) / 8,
          backgroundColor: AppColors.background,
          valueColor: const AlwaysStoppedAnimation<Color>(
            AppColors.primaryButton,
          ),
          minHeight: 4,
        ),
        Expanded(child: _buildPageView()),
      ],
    );
  }

  Widget _buildDesktopHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 18),
                onPressed: _prevPage,
              ),
              const SizedBox(width: 8),
              Text(
                'Step ${_currentPage + 1} of 8',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                'Need Help?',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.headset_mic_outlined, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPageView() {
    return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(), // Disable swipe
      onPageChanged: (index) => setState(() => _currentPage = index),
      children: [
        ProfileStep(onNext: _nextPage),
        KycStep(onNext: _nextPage),
        BrandExpertiseStep(onNext: _nextPage),
        RepairExpertiseStep(onNext: _nextPage),
        ServiceTypeStep(onNext: _nextPage),
        BankStep(onNext: _nextPage),
        AgreementStep(onNext: _nextPage),
        StatusStep(onNext: _nextPage),
      ],
    );
  }
}
