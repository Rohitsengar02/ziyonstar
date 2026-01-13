import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color textHeading = Color(0xFF1E1E1E);
  static const Color textBody = Color(0xFF555555);
  static const Color accentRed = Color(0xFFFF6B6B);
  static const Color accentYellow = Color(0xFFFFD93D);
  static const Color primaryButton = Color(0xFF0F172A); // Dark almost black
  static const Color background = Colors.white;
  static const Color heroBg = Color(0xFFF3F4F6); // Soft grey for hero shape
  static const Color darkSection = Color(0xFF0F172A); // Bottom stats bar
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primaryButton,
      scaffoldBackgroundColor: Colors.white,
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.inter(
          fontWeight: FontWeight.bold,
          color: AppColors.textHeading,
          fontSize: 60,
          height: 1.2,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          color: AppColors.textBody,
          height: 1.6,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryButton,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}
