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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const TechnicianApp());
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
    _techFuture = ApiService().getTechnician(widget.user.uid);
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
