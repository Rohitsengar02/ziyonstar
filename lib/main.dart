import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:ziyonstar/theme.dart';
import 'package:ziyonstar/screens/home_screen.dart';
import 'package:ziyonstar/screens/onboarding_screen.dart'; // Import Onboarding
import 'package:ziyonstar/screens/sign_in_screen.dart'; // Import SignIn
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

Future<void> main() async {
  debugPrint("🚀 STARTING APP...");
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint("✅ WidgetsBinding initialized");

  // Try to load env
  try {
    debugPrint("⏳ Loading .env...");
    await dotenv.load(fileName: ".env");
    debugPrint("✅ .env loaded. BACKEND_URL: ${dotenv.env['BACKEND_URL']}");
  } catch (e) {
    debugPrint("❌ Env file not found or failed to load: $e");
  }

  // Try to initialize Firebase
  try {
    debugPrint("⏳ Initializing Firebase...");
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint("✅ Firebase initialized");
  } catch (e) {
    debugPrint("⚠️ Firebase init failed (expected if no config): $e");
  }

  // Check Onboarding Status
  bool hasOnboarded = false;
  try {
    debugPrint("⏳ Checking SharedPreferences...");
    final prefs = await SharedPreferences.getInstance();
    hasOnboarded = prefs.getBool('has_onboarded') ?? false;
    debugPrint("✅ SharedPreferences checked. hasOnboarded: $hasOnboarded");
  } catch (e) {
    debugPrint("❌ Error checking prefs: $e");
  }

  debugPrint("🚀 Calling runApp...");
  runApp(ZiyonStarApp(hasOnboarded: hasOnboarded));
}

class ZiyonStarApp extends StatelessWidget {
  final bool hasOnboarded;

  const ZiyonStarApp({super.key, this.hasOnboarded = false});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZiyonStar',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: AppTheme.lightTheme,
      home: AuthWrapper(hasOnboarded: hasOnboarded),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  final bool hasOnboarded;
  const AuthWrapper({super.key, required this.hasOnboarded});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return const HomeScreen();
        }
        if (kIsWeb) {
          // On Web, show HomeScreen initially regardless of auth status
          // The HomeScreen will handle guest vs user state if needed, or user will login from there
          return const HomeScreen();
        }
        if (hasOnboarded) {
          return const SignInScreen();
        }
        return const OnboardingScreen();
      },
    );
  }
}
