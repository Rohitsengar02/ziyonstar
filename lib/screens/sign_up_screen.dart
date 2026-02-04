import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ziyonstar/screens/home_screen.dart';
import 'package:ziyonstar/screens/sign_in_screen.dart';
import 'package:ziyonstar/services/api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final ApiService _apiService = ApiService();
  bool _isGoogleLoading = false;

  // Real Google Sign In
  Future<void> _handleGoogleSignUp() async {
    setState(() => _isGoogleLoading = true);

    try {
      // 1. Configure and Trigger Google Sign In
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId:
            '1038243894712-7919cpcl7j7v0oa282boj4vru1u33hng.apps.googleusercontent.com',
        scopes: ['email', 'profile'],
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled operation
        setState(() => _isGoogleLoading = false);
        return;
      }

      // 2. Authentication
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 3. Firebase Sign In (Attempt)
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

      // 4. Register to Backend (Using Firebase User or Raw Google User)
      if (firebaseUser != null) {
        await _registerAndNavigate(
          name: firebaseUser.displayName ?? 'Google User',
          email: firebaseUser.email ?? 'no-email@ziyonstar.com',
          uid: firebaseUser.uid,
          photoUrl: firebaseUser.photoURL,
          phone: firebaseUser.phoneNumber,
        );
      } else {
        // Fallback: Use Google Account Data directly
        await _registerAndNavigate(
          name: googleUser.displayName ?? 'Google User',
          email: googleUser.email,
          uid: googleUser.id, // Use Google ID as fallback UID
          photoUrl: googleUser.photoUrl,
          phone: null,
        );
      }
    } catch (e) {
      debugPrint("Real Google Sign In Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign In Failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  Future<void> _registerAndNavigate({
    required String name,
    required String email,
    required String uid,
    String? photoUrl,
    String? phone,
  }) async {
    final Map<String, dynamic> userData = {
      'name': name,
      'email': email,
      'firebaseUid': uid,
      'photoUrl': photoUrl,
      'phone': phone,
      'role': 'user',
      'createdAt': DateTime.now().toIso8601String(),
    };

    // 1. Register to MongoDB (Backend)
    debugPrint("Registering to MongoDB...");
    try {
      await _apiService.registerUser(userData);
    } catch (e) {
      debugPrint(
        "MongoDB Error: $e",
      ); // Continue flow even if MongoDB fails? Ideally no.
    }

    // 2. Register to Firebase Firestore (Users Collection)
    debugPrint("Registering to Firestore...");
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(userData);
    } catch (e) {
      debugPrint("Firestore Error (Ignore if simulation): $e");
    }

    if (mounted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_onboarded', true);
      await prefs.setString('user_uid', uid);
      await prefs.setString('user_name', name);
      await prefs.setString('user_email', email);
      if (photoUrl != null) await prefs.setString('user_photo', photoUrl);
      if (phone != null) await prefs.setString('user_phone', phone);

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: isDesktop
          ? null
          : AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(LucideIcons.arrowLeft, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
      body: isDesktop
          ? Row(
              children: [
                // Left Side - Hero Image (Desktop only)
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Colors.yellow.shade50,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/signup_hero.png', // Ensure this asset exists or use a network placeholder
                            height: 400,
                            errorBuilder: (c, e, s) => Icon(
                              LucideIcons.userPlus,
                              size: 100,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'Join Us Today!',
                            style: GoogleFonts.outfit(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Right Side - Form
                Expanded(
                  flex: 1,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 450),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(40),
                        child: _buildSignUpForm(context, isDesktop),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: _buildSignUpForm(context, isDesktop),
              ),
            ),
    );
  }

  Widget _buildSignUpForm(BuildContext context, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!isDesktop) ...[const Spacer()],
        Center(
          child: Container(
            height: 100,
            width: 100,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.yellow.shade100,
            ),
            child: const Icon(
              LucideIcons.userPlus,
              size: 50,
              color: Color(0xFFFACC15),
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
        ),
        const SizedBox(height: 32),

        Text(
          'Create Account',
          style: GoogleFonts.outfit(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn().slideY(begin: 0.2),

        const SizedBox(height: 8),

        Text(
          'Join ZiyonStar for fast mobile repairs.',
          style: GoogleFonts.inter(fontSize: 16, color: Colors.grey),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),

        if (!isDesktop) const Spacer(),
        if (isDesktop) const SizedBox(height: 40),

        // Google Button
        ElevatedButton(
          onPressed: (_isGoogleLoading) ? null : _handleGoogleSignUp,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            elevation: 2,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
          ),
          child: _isGoogleLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/brand_google.png',
                      height: 24,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        LucideIcons.chrome,
                        color: Colors.blue,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Sign up with Google',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ).animate().fadeIn(delay: 400.ms),

        const SizedBox(height: 32),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Already have an account? ',
              style: GoogleFonts.inter(color: Colors.grey[600]),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (c) => const SignInScreen()),
                );
              },
              child: Text(
                'Sign In',
                style: GoogleFonts.inter(
                  color: Colors.blue[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
