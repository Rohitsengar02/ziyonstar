import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/onboarding/info_screen_one.dart';
import 'screens/dashboard/admin_dashboard.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  print('DOTENV: Loaded variables: ${dotenv.env}');
  print('DOTENV: BACKEND_URL is ${dotenv.env['BACKEND_URL']}');

  final prefs = await SharedPreferences.getInstance();
  final userString = prefs.getString('user_session');
  Map<String, dynamic>? user;
  if (userString != null) {
    user = jsonDecode(userString);
  }

  runApp(AdminApp(initialUser: user));
}

class AdminApp extends StatelessWidget {
  final Map<String, dynamic>? initialUser;
  const AdminApp({super.key, this.initialUser});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZiyonStar Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
      ),
      home: initialUser != null
          ? AdminDashboard(user: initialUser)
          : const InfoScreenOne(),
    );
  }
}
