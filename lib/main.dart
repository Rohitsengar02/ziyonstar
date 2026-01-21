import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:ziyonstar/theme.dart';
import 'package:ziyonstar/screens/home_screen.dart';
import 'package:ziyonstar/screens/onboarding_screen.dart'; // Import Onboarding
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Try to load env
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Env file not found or failed to load: $e");
  }

  // Try to initialize Firebase
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase init failed (expected if no config): $e");
  }

  // Check Onboarding Status
  bool hasOnboarded = false;
  try {
    final prefs = await SharedPreferences.getInstance();
    hasOnboarded = prefs.getBool('has_onboarded') ?? false;
  } catch (e) {
    debugPrint("Error checking prefs: $e");
  }

  runApp(ZiyonStarApp(hasOnboarded: hasOnboarded));
}

class ZiyonStarApp extends StatelessWidget {
  final bool hasOnboarded;

  const ZiyonStarApp({super.key, this.hasOnboarded = false});

  @override
  Widget build(BuildContext context) {
    // Decision logic
    // For now, enabling onboarding for all platforms so you can see it.
    // To revert to "Mobile Only", you can wrap this back in !kIsWeb.
    // Forced Onboarding for Demo/Testing requested by user
    Widget initialScreen = const OnboardingScreen();

    return MaterialApp(
      title: 'ZiyonStar',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: AppTheme.lightTheme,
      home: initialScreen,
    );
  }
}
