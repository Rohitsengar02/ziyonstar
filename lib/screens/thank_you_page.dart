import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';

class ThankYouPage extends StatelessWidget {
  const ThankYouPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    LucideIcons.checkCircle,
                    size: 64,
                    color: Colors.green,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Booking Confirmed!',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textHeading,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Your repair request has been successfully placed. We have sent a confirmation email to you.',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: AppColors.textBody,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.go('/bookings');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryButton,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Go to My Bookings',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    context.go('/home');
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppColors.primaryButton),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Continue Booking',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryButton,
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
}
