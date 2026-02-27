import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:ziyonstar/theme.dart';
import 'package:ziyonstar/screens/home_screen.dart';
import 'package:ziyonstar/screens/onboarding_screen.dart';
import 'package:ziyonstar/screens/sign_in_screen.dart';
import 'package:ziyonstar/screens/sign_up_screen.dart';
import 'package:ziyonstar/screens/technician_profile_page.dart';
import 'package:ziyonstar/screens/booking_success_screen.dart';
import 'package:ziyonstar/screens/about_page.dart';
import 'package:ziyonstar/screens/repair_page.dart';
import 'package:ziyonstar/screens/privacy_policy_page.dart';
import 'package:ziyonstar/screens/terms_conditions_page.dart';
import 'package:ziyonstar/screens/contact_page.dart';
import 'package:ziyonstar/screens/my_bookings_screen.dart';
import 'package:ziyonstar/screens/profile_page.dart';
import 'package:ziyonstar/screens/profile_setup_screen.dart';
import 'package:ziyonstar/screens/address_page.dart';
import 'package:ziyonstar/screens/chat_page.dart';
import 'package:ziyonstar/screens/notifications_page.dart';
import 'package:ziyonstar/screens/return_refund_page.dart';
import 'package:ziyonstar/screens/child_protection_page.dart';
import 'package:ziyonstar/responsive.dart';
import 'package:ziyonstar/screens/mobile_repair_page.dart';
import 'package:ziyonstar/screens/address_picker_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'firebase_options.dart';
import 'package:ziyonstar/services/notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint("User App: Received background message: ${message.messageId}");

    // Show the "real" notification banner
    await NotificationService.showNotification(message);
    debugPrint("User App: Background notification processed.");
  } catch (e) {
    debugPrint("User App: Error in background handler: $e");
  }
}

// Move router to top level for better persistence and clean URLs
final GoRouter _router = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true,
  routes: [
    GoRoute(path: '/', builder: (context, state) => const AuthWrapper()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/login', builder: (context, state) => const SignInScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(path: '/about', builder: (context, state) => const AboutPage()),
    GoRoute(
      path: '/repair',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final queryBrand = state.uri.queryParameters['brand'];
        final queryModel = state.uri.queryParameters['model'];
        final queryIssue = state.uri.queryParameters['issue'];

        if (kIsWeb && !ResponsiveLayout.isMobile(context)) {
          return RepairPage(
            deviceBrand: queryBrand ?? extra?['deviceBrand'] ?? 'Apple',
            deviceModel: queryModel ?? extra?['deviceModel'] ?? 'iPhone 13 Pro',
            modelData: extra?['modelData'],
            initialIssue: queryIssue ?? extra?['initialIssue'],
          );
        } else {
          return MobileRepairPage(
            initialBrand: queryBrand ?? extra?['initialBrand'],
            initialModel: queryModel ?? extra?['initialModel'],
            initialIssue: queryIssue ?? extra?['initialIssue'],
          );
        }
      },
    ),
    GoRoute(
      path: '/mobile-repair',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return MobileRepairPage(
          initialBrand: extra?['initialBrand'],
          initialModel: extra?['initialModel'],
          initialIssue: extra?['initialIssue'],
        );
      },
    ),
    GoRoute(
      path: '/privacy-policy',
      builder: (context, state) => const PrivacyPolicyPage(),
    ),
    GoRoute(
      path: '/terms-conditions',
      builder: (context, state) => const TermsConditionsPage(),
    ),
    GoRoute(
      path: '/return-refund',
      builder: (context, state) => const ReturnRefundPage(),
    ),
    GoRoute(
      path: '/child-protection',
      builder: (context, state) => const ChildProtectionPage(),
    ),
    GoRoute(path: '/contact', builder: (context, state) => const ContactPage()),
    GoRoute(
      path: '/bookings',
      builder: (context, state) => const MyBookingsScreen(),
    ),
    GoRoute(path: '/profile', builder: (context, state) => const ProfilePage()),
    GoRoute(
      path: '/profile-setup',
      builder: (context, state) {
        final name = state.uri.queryParameters['name'] ?? '';
        final email = state.uri.queryParameters['email'] ?? '';
        final uid = state.uri.queryParameters['uid'] ?? '';
        final photoUrl = state.uri.queryParameters['photoUrl'];
        return ProfileSetupScreen(
          name: name,
          email: email,
          uid: uid,
          photoUrl: photoUrl,
        );
      },
    ),
    GoRoute(
      path: '/addresses',
      builder: (context, state) => const AddressPage(),
    ),
    GoRoute(
      path: '/address-picker',
      builder: (context, state) {
        final userId = state.uri.queryParameters['userId'] ?? '';
        return AddressPickerScreen(userId: userId);
      },
    ),
    GoRoute(path: '/chat', builder: (context, state) => const ChatPage()),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsPage(),
    ),
    GoRoute(
      path: '/booking-success',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return BookingSuccessScreen(
          deviceName: extra['deviceName'],
          technicianName: extra['technicianName'],
          technicianImage: extra['technicianImage'],
          selectedIssues: extra['selectedIssues'],
          timeSlot: extra['timeSlot'],
          date: extra['date'],
          amount: extra['amount'],
          otp: extra['otp'],
        );
      },
    ),
    GoRoute(
      path: '/technician-profile',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return TechnicianProfilePage(technician: extra);
      },
    ),
  ],
);

Future<void> main() async {
  debugPrint("🚀 STARTING APP...");
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    usePathUrlStrategy();
  }

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("❌ Env file not found or failed to load: $e");
  }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize Push Notifications
    if (!kIsWeb) {
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );
      await NotificationService.initialize();
    }
  } catch (e) {
    debugPrint("⚠️ Firebase init failed: $e");
  }

  runApp(const ZiyonStarApp());
}

class ZiyonStarApp extends StatelessWidget {
  const ZiyonStarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ZiyonStar',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: AppTheme.lightTheme,
      routerConfig: _router,
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

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

        if (kIsWeb || snapshot.hasData) {
          return const HomeScreen();
        }

        return FutureBuilder<bool>(
          future: SharedPreferences.getInstance().then(
            (p) => p.getBool('has_onboarded') ?? false,
          ),
          builder: (context, onboardingSnapshot) {
            if (onboardingSnapshot.data == true) {
              return const SignInScreen();
            }
            return const OnboardingScreen();
          },
        );
      },
    );
  }
}
