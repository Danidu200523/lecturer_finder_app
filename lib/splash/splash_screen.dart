import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lecturer_finder_app/core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/onboarding');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.splashbg, // light background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/graduation_cap.png', width: 120),
            const SizedBox(height: 24),
            const Text(
              'FindMy\nLecturer',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 49, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Find Your Lecturer Fast',
              style: TextStyle(fontSize: 25, color: AppColors.subtitleText),
            ),
          ],
        ),
      ),
    );
  }
}
