import 'package:flutter/material.dart';
import 'theme.dart';
import 'screens/welcome_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/onboarding_wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/api_service.dart';
import 'screens/pending_approval_screen.dart';
import 'services/notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'screens/profile/privacy_policy_screen.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint("Technician: Received background message: ${message.messageId}");

    // Explicitly show the notification card
    await NotificationService.showNotification(message);
    debugPrint("Technician: Background notification processed.");
  } catch (e) {
    debugPrint("Technician: Error in background handler: $e");
  }
}

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    debugPrint("TechnicianApp: Starting initialization...");

    try {
      await dotenv.load(fileName: "assets/.env");
      debugPrint("TechnicianApp: DotEnv loaded.");
    } catch (e) {
      debugPrint("TechnicianApp: DotEnv load failed (using defaults): $e");
      // Initialize with empty map to avoid NotInitializedError
      dotenv.testLoad(fileInput: "");
    }

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint("TechnicianApp: Firebase initialized.");

      // Initialize Push Notifications
      if (!kIsWeb) {
        FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler,
        );
        await NotificationService.initialize();
      }
    } catch (e) {
      debugPrint("TechnicianApp: Firebase init failed: $e");
    }

    runApp(const TechnicianApp());
  } catch (e, stack) {
    debugPrint("TechnicianApp: CRITICAL ERROR in main: $e\n$stack");
    // Attempt to run app anyway to show something
    runApp(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: Text("App Failed to Start. Check logs.")),
        ),
      ),
    );
  }
}

class TechnicianApp extends StatelessWidget {
  const TechnicianApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ZiyonStar Technician',
      theme: AppTheme.lightTheme,
      home: const TechAuthWrapper(),
      routes: {'/privacy-policy': (context) => const PrivacyPolicyScreen()},
    );
  }
}

class TechAuthWrapper extends StatelessWidget {
  const TechAuthWrapper({super.key});

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

        if (snapshot.hasData && snapshot.data != null) {
          // User is signed in, fetch technician data to route correctly
          return TechnicianRouter(user: snapshot.data!);
        }

        return const WelcomeScreen();
      },
    );
  }
}

class TechnicianRouter extends StatefulWidget {
  final User user;
  const TechnicianRouter({super.key, required this.user});

  @override
  State<TechnicianRouter> createState() => _TechnicianRouterState();
}

class _TechnicianRouterState extends State<TechnicianRouter> {
  Future<Map<String, dynamic>?>? _techFuture;

  @override
  void initState() {
    super.initState();
    _techFuture = _initializeAndGetTech();
  }

  Future<Map<String, dynamic>?> _initializeAndGetTech() async {
    final apiService = ApiService();
    // Fetch current data
    final techData = await apiService.getTechnician(widget.user.uid);

    // Sync FCM token to backend
    try {
      final token = await NotificationService.getToken();
      if (token != null) {
        debugPrint("Technician: FCM Token retrieved: $token");
        debugPrint("Technician: Syncing token to backend...");
        await apiService.updateTechnicianProfile(
          firebaseUid: widget.user.uid,
          data: {}, // Just syncing token
          fcmToken: token,
        );
        debugPrint("Technician: FCM token sync successful");
      } else {
        debugPrint("Technician: FCM token is null");
      }
    } catch (e) {
      debugPrint("Technician: Failed to sync FCM token: $e");
    }

    return techData;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _techFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final techData = snapshot.data;

        // Logic mirroring LoginScreen
        if (techData != null && techData['status'] == 'approved') {
          return DashboardScreen(technicianData: techData);
        } else if (techData != null &&
            techData['status'] == 'pending' &&
            techData['agreedToTerms'] == true) {
          return const PendingApprovalScreen();
        } else {
          // New or Incomplete
          return const OnboardingWrapper();
        }
      },
    );
  }
}

// Removed local PendingApprovalScreen
