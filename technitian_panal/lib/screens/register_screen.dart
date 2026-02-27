import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:technician_panel/screens/dashboard_screen.dart';
import '../theme.dart';
import 'login_screen.dart';
import 'onboarding_wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/api_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/auth_sidebar.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _registerWithEmail() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      final user = userCredential.user;
      if (user != null) {
        // Update display name
        await user.updateDisplayName(_nameController.text.trim());

        // 1. Save to Firebase Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': _nameController.text.trim(),
          'email': user.email,
          'photoUrl': '', // No photo for email sign up initially
          'phone': '',
          'role': 'technician',
          'status': 'pending', // Explicitly pending
          'createdAt': FieldValue.serverTimestamp(),
          'isOnline': false,
        });

        // 2. Sync with MongoDB (User collection)
        try {
          final apiService = ApiService();
          // We call `registerUser` now to ensure they are added to the 'users' collection in MongoDB
          await apiService.registerUser(
            name: _nameController.text.trim(),
            email: user.email!,
            firebaseUid: user.uid,
            role: 'technician',
          );

          // Optionally still call registerTechnician if we need them in that collection too
          await apiService.registerTechnician(
            name: _nameController.text.trim(),
            email: user.email!,
            firebaseUid: user.uid,
          );
        } catch (e) {
          debugPrint("Failed to sync with backend: $e");
          // Proceed anyway, or handle error
        }
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingWrapper()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Registration Failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleNavigation(User user) async {
    try {
      final apiService = ApiService();
      // Sync/Register
      await apiService.registerTechnician(
        name: user.displayName ?? 'Known Tech',
        email: user.email!,
        firebaseUid: user.uid,
        photoUrl: user.photoURL,
        phone: user.phoneNumber,
      );

      // Fetch latest status
      final techData = await apiService.getTechnician(user.uid);

      if (mounted) {
        if (techData != null && techData['status'] == 'approved') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
          );
        } else if (techData != null &&
            techData['status'] == 'pending' &&
            techData['agreedToTerms'] == true) {
          // Show pending popup
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  const Icon(LucideIcons.clock, color: Colors.orange),
                  const SizedBox(width: 10),
                  Text(
                    'Application Pending',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: Text(
                'Your application is currently under review by our team. We will notify you once it is approved.',
                style: GoogleFonts.inter(),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.pop(context);
                  },
                  child: Text(
                    'OK',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryButton,
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          // New user or incomplete onboarding
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const OnboardingWrapper()),
          );
        }
      }
    } catch (e) {
      debugPrint("Failed to sync/fetch from backend: $e");
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingWrapper()),
        );
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final UserCredential userCredential = await FirebaseAuth.instance
            .signInWithCredential(credential);

        final user = userCredential.user;
        if (user != null) {
          // 1. Save/Update to Firebase Firestore (Optional if using MongoDB as primary)
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
                'uid': user.uid,
                'name': user.displayName ?? 'Unknown',
                'email': user.email,
                'photoUrl': user.photoURL ?? '',
                'phone': user.phoneNumber ?? '',
                'role': 'technician',
                'lastLogin': FieldValue.serverTimestamp(),
              }, SetOptions(merge: true));

          // 2. Handle Navigation & Sync with MongoDB
          await _handleNavigation(user);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Google Sign-In Failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth >= 900) {
                    // Desktop/Tablet side-by-side layout
                    return Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: Row(
                          children: [
                            // Left Side Animated Sidebar
                            const Expanded(
                              flex: 1,
                              child: AuthSidebar(currentStep: 0, totalSteps: 8),
                            ),
                            // Right Side Form
                            Expanded(
                              flex: 1,
                              child: Column(
                                children: [
                                  // Desktop Header
                                  _buildDesktopHeader(),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 60,
                                        vertical: 20,
                                      ),
                                      child: _buildFormContent(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    // Mobile Layout
                    return Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Column(
                        children: [
                          // Top Image
                          Expanded(
                            flex: 2,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(30),
                                bottomRight: Radius.circular(30),
                              ),
                              child: Image.asset(
                                'assets/register.png',
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => Container(
                                  color: Colors.grey[100],
                                  child: const Center(
                                    child: Icon(
                                      LucideIcons.image,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Content
                          Expanded(
                            flex: 5,
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: SingleChildScrollView(
                                child: _buildFormContent(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
      ),
    );
  }

  Widget _buildDesktopHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  LucideIcons.zap,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'ZIYONSTAR',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(LucideIcons.globe, size: 16),
            label: const Text('Back to Website'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[600],
              textStyle: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create Account',
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textHeading,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Join our network and start earning today.',
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.textBody),
        ),

        const SizedBox(height: 24),

        // Name
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Full Name',
            prefixIcon: Icon(LucideIcons.user),
          ),
        ),
        const SizedBox(height: 16),

        // Email
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email Address',
            prefixIcon: Icon(LucideIcons.mail),
          ),
        ),
        const SizedBox(height: 16),

        // Password
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Password',
            prefixIcon: Icon(LucideIcons.lock),
          ),
        ),

        const SizedBox(height: 24),

        // Register Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _registerWithEmail,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Register'),
          ),
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey[300])),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('OR', style: TextStyle(color: Colors.grey[600])),
            ),
            Expanded(child: Divider(color: Colors.grey[300])),
          ],
        ),

        const SizedBox(height: 16),

        // Google Sign Up Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _signInWithGoogle,
            icon: const Icon(LucideIcons.chrome, color: Colors.black),
            label: const Text('Sign up with Google'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Colors.black),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "By continuing, you agree to our ",
              style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600]),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/privacy-policy');
              },
              child: Text(
                "Privacy Policy",
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Footer Link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Already have an account? "),
            GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text(
                "Login",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
