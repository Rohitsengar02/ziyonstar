import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ziyonstar/screens/home_screen.dart';
import 'package:ziyonstar/services/api_service.dart';
import 'package:ziyonstar/screens/sign_up_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final ApiService _apiService = ApiService();
  bool _isSigningIn = false;
  bool _isGoogleLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
        // User canceled
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
        // Fallback
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

  Future<void> _handleEmailSignIn() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    setState(() => _isSigningIn = true);
    try {
      // Using Mock Email Login as per earlier steps, but saving data consistently
      await Future.delayed(const Duration(seconds: 1));
      final String uid = "email_user_${_emailController.text.hashCode}";

      await _loginAndNavigate(
        name: 'App User', // Default name
        email: _emailController.text,
        uid: uid,
      );
    } catch (e) {
      debugPrint("Email Login Error: $e");
    } finally {
      if (mounted) setState(() => _isSigningIn = false);
    }
  }

  Future<void> _loginAndNavigate({
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

    // 1. Backend Upsert
    await _apiService.registerUser(userData);

    // 2. Firestore Sync
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(userData);
    } catch (e) {
      debugPrint("Firestore Error ignored: $e");
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              // Logo
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

              const SizedBox(height: 40),

              Text(
                'Welcome Back',
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn().slideY(begin: 0.3),

              const SizedBox(height: 12),

              Text(
                'Sign in to continue using ZiyonStar',
                style: GoogleFonts.inter(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),

              const SizedBox(height: 40),

              // Fields
              _buildTextField(
                label: 'Email',
                controller: _emailController,
                icon: LucideIcons.mail,
                type: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Password',
                controller: _passwordController,
                icon: LucideIcons.lock,
                isPassword: true,
              ),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    'Forgot Password?',
                    style: GoogleFonts.inter(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Sign In Button
              ElevatedButton(
                onPressed: (_isSigningIn || _isGoogleLoading)
                    ? null
                    : _handleEmailSignIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFACC15), // Yellow
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isSigningIn
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        'Sign In',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ).animate().fadeIn(delay: 400.ms),

              const SizedBox(height: 24),

              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR',
                      style: GoogleFonts.inter(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),

              const SizedBox(height: 24),

              // Google Button
              ElevatedButton(
                onPressed: (_isSigningIn || _isGoogleLoading)
                    ? null
                    : _handleGoogleSignIn,
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
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  LucideIcons.chrome,
                                  color: Colors.blue,
                                  size: 24,
                                ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Sign in with Google',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ).animate().fadeIn(delay: 500.ms),

              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Don\'t have an account? ',
                    style: GoogleFonts.inter(color: Colors.grey[600]),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (c) => const SignUpScreen()),
                      );
                    },
                    child: Text(
                      'Sign Up',
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
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool isPassword = false,
    TextInputType type = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.grey[400], size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          labelStyle: GoogleFonts.inter(color: Colors.grey[500]),
        ),
        style: GoogleFonts.inter(color: Colors.black87),
      ),
    );
  }
}
