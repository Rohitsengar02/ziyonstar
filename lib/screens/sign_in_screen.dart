import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ziyonstar/screens/home_screen.dart';
import 'package:ziyonstar/services/api_service.dart';
import 'package:ziyonstar/screens/profile_setup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final ApiService _apiService = ApiService();
  bool _isGoogleLoading = false;

  // Real Google Sign In Logic
  Future<void> _handleGoogleSignIn() async {
    setState(() => _isGoogleLoading = true);

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId:
            '1038243894712-7919cpcl7j7v0oa282boj4vru1u33hng.apps.googleusercontent.com',
        scopes: ['email', 'profile'],
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        setState(() => _isGoogleLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      User? firebaseUser;
      try {
        final UserCredential userCredential = await FirebaseAuth.instance
            .signInWithCredential(credential);
        firebaseUser = userCredential.user;
      } catch (e) {
        debugPrint(
          "Firebase Auth execution failed (Proceeding with Google User): $e",
        );
      }

      if (firebaseUser != null) {
        await _loginAndNavigate(
          name: firebaseUser.displayName ?? 'Google User',
          email: firebaseUser.email ?? '',
          uid: firebaseUser.uid,
          photoUrl: firebaseUser.photoURL,
          phone: firebaseUser.phoneNumber,
        );
      } else {
        await _loginAndNavigate(
          name: googleUser.displayName ?? 'Google User',
          email: googleUser.email,
          uid: googleUser.id,
          photoUrl: googleUser.photoUrl,
          phone: null,
        );
      }
    } catch (e) {
      debugPrint("Real Google Sign In Failed: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign In Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  Future<void> _loginAndNavigate({
    required String name,
    required String email,
    required String uid,
    String? photoUrl,
    String? phone,
  }) async {
    setState(() => _isGoogleLoading = true);

    try {
      final existingUser = await _apiService.getUser(uid);

      bool isProfileIncomplete =
          existingUser == null ||
          existingUser['phone'] == null ||
          existingUser['phone'].toString().isEmpty;

      if (isProfileIncomplete) {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => ProfileSetupScreen(
                name: existingUser?['name'] ?? name,
                email: email,
                uid: uid,
                photoUrl: existingUser?['photoUrl'] ?? photoUrl,
              ),
            ),
            (route) => false,
          );
        }
        return;
      }

      final Map<String, dynamic> userData = {
        'name': existingUser['name'] ?? name,
        'email': email,
        'firebaseUid': uid,
        'photoUrl': existingUser['photoUrl'] ?? photoUrl,
        'phone': existingUser['phone'] ?? phone,
        'role': existingUser['role'] ?? 'user',
        'createdAt':
            existingUser['createdAt'] ?? DateTime.now().toIso8601String(),
      };

      if (mounted) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('has_onboarded', true);
        await prefs.setString('user_uid', uid);
        await prefs.setString('user_name', userData['name']);
        await prefs.setString('user_email', email);
        if (userData['photoUrl'] != null) {
          await prefs.setString('user_photo', userData['photoUrl']);
        }
        if (userData['phone'] != null) {
          await prefs.setString('user_phone', userData['phone']);
        }

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint("Login/Navigate Error: $e");
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => ProfileSetupScreen(
              name: name,
              email: email,
              uid: uid,
              photoUrl: photoUrl,
            ),
          ),
          (route) => false,
        );
      }
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    return Scaffold(
      backgroundColor: Colors.white,
      body: isDesktop
          ? Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Colors.blue.shade50,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/hero_user.png',
                            height: 400,
                            errorBuilder: (c, e, s) => const Icon(
                              LucideIcons.smartphone,
                              size: 100,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'Welcome Back!',
                            style: GoogleFonts.outfit(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 450),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(40),
                        child: _buildSignInForm(context),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: _buildSignInForm(context),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildSignInForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Container(
            height: 100,
            width: 100,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue.shade50,
            ),
            child: const Icon(
              LucideIcons.smartphone,
              size: 50,
              color: Colors.blue,
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
        ),
        const SizedBox(height: 32),
        Text(
          'Welcome to ZiyonStar',
          style: GoogleFonts.outfit(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn().slideY(begin: 0.3),
        const SizedBox(height: 12),
        Text(
          'Your one-stop destination for quick and reliable mobile repairs.',
          style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),
        const SizedBox(height: 60),
        ElevatedButton(
          onPressed: _isGoogleLoading ? null : _handleGoogleSignIn,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            elevation: 2,
            shadowColor: Colors.black12,
            padding: const EdgeInsets.symmetric(vertical: 22),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade200),
            ),
          ),
          child: _isGoogleLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/brand_google.png',
                      height: 28,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        LucideIcons.chrome,
                        color: Colors.blue,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Continue with Google',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ).animate().fadeIn(delay: 400.ms).scale(begin: const Offset(0.9, 0.9)),
        const SizedBox(height: 40),
        Text(
          'By continuing, you agree to our Terms of Service and Privacy Policy',
          style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[500]),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 600.ms),
      ],
    );
  }
}
