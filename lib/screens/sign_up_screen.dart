import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:math';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _isGoogleLoading = false;
  bool _isAppleLoading = false;

  /// Generates a cryptographically secure random nonce
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz.-_';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  /// Returns the sha256 hash of [input] in hex format.
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> _handleAppleSignUp() async {
    setState(() => _isAppleLoading = true);

    try {
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final OAuthCredential credential = OAuthProvider(
        'apple.com',
      ).credential(idToken: appleCredential.identityToken, rawNonce: rawNonce);

      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        String displayName = firebaseUser.displayName ?? '';
        if (displayName.isEmpty) {
          final givenName = appleCredential.givenName ?? '';
          final familyName = appleCredential.familyName ?? '';
          displayName = '$givenName $familyName'.trim();
        }
        if (displayName.isEmpty) displayName = 'Apple User';

        await _registerAndNavigate(
          name: displayName,
          email: firebaseUser.email ?? 'no-email@ziyonstar.com',
          uid: firebaseUser.uid,
          photoUrl: firebaseUser.photoURL,
          phone: firebaseUser.phoneNumber,
        );
      }
    } catch (e) {
      debugPrint("Apple Sign Up Failed: $e");
      if (mounted) {
        if (e.toString().contains(
          'SignInWithAppleAuthorizationError.canceled',
        )) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Apple Sign Up Failed: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isAppleLoading = false);
    }
  }

  Future<void> _handleGoogleSignUp() async {
    setState(() => _isGoogleLoading = true);

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: kIsWeb
            ? '1038243894712-7919cpcl7j7v0oa282boj4vru1u33hng.apps.googleusercontent.com'
            : null,
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
        debugPrint("Firebase Auth execution failed: $e");
      }

      if (firebaseUser != null) {
        await _registerAndNavigate(
          name: firebaseUser.displayName ?? 'Google User',
          email: firebaseUser.email ?? 'no-email@ziyonstar.com',
          uid: firebaseUser.uid,
          photoUrl: firebaseUser.photoURL,
          phone: firebaseUser.phoneNumber,
        );
      } else {
        await _registerAndNavigate(
          name: googleUser.displayName ?? 'Google User',
          email: googleUser.email,
          uid: googleUser.id,
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
    if (mounted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_onboarded', true);
      context.go(
        '/profile-setup?name=$name&email=$email&uid=$uid&photoUrl=${photoUrl ?? ''}',
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
                onPressed: () => context.pop(),
              ),
            ),
      body: isDesktop
          ? Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Colors.yellow.shade50,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            LucideIcons.userPlus,
                            size: 100,
                            color: Colors.orange,
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
        const SizedBox(height: 40),
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
                    const Icon(
                      LucideIcons.chrome,
                      color: Colors.blue,
                      size: 24,
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
        ).animate().fadeIn(delay: 350.ms),
        if (!kIsWeb && Theme.of(context).platform == TargetPlatform.iOS) ...[
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _isAppleLoading ? null : _handleAppleSignUp,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              elevation: 2,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isAppleLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(LucideIcons.apple, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        'Sign up with Apple',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ).animate().fadeIn(delay: 450.ms),
        ],
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Already have an account? ',
              style: GoogleFonts.inter(color: Colors.grey[600]),
            ),
            GestureDetector(
              onTap: () => context.go('/login'),
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
