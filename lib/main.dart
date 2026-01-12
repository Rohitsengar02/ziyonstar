import 'package:flutter/material.dart';
import 'package:ziyonstar/theme.dart';
import 'package:ziyonstar/screens/home_screen.dart';

void main() {
  runApp(const ZiyonStarApp());
}

class ZiyonStarApp extends StatelessWidget {
  const ZiyonStarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Atomos Banking',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light, // Specifically set to light mode
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}
