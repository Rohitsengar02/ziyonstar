import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const primaryStart = Color(0xFF2C2C2C);
  static const primaryEnd = Color(0xFF000000);
  static const primaryButton = Color(0xFF111111);
  static const textHeading = Color(0xFF1F1F1F);
  static const textBody = Color(0xFF6B7280);
  static const inputBorder = Color(0xFFE5E7EB);
  static const inputFocus = Color(0xFF000000);
  static const background = Color(0xFFFFFFFF); // Clean White
  static const surface = Color(0xFFF9FAFB);
  static const success = Color(0xFF000000); // minimalist success
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppColors.primaryButton,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.black,
        primary: Colors.black,
      ),
      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: AppColors.textHeading,
        displayColor: AppColors.textHeading,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white, // Minimalist white header
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: GoogleFonts.poppins(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryButton,
          foregroundColor: Colors.white,
          elevation: 0, // Flat design
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF3F4F6), // Light gray fill
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none, // Cleaner look
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        labelStyle: const TextStyle(color: Colors.grey),
      ),
    );
  }
}
