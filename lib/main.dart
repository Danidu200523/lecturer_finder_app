import 'package:flutter/material.dart';
import 'package:lecturer_finder_app/splash/splash_screen.dart';

void main() {
  runApp(const LecturerFinderApp());
}

class LecturerFinderApp extends StatelessWidget {
  const LecturerFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FindMy Lecturer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(), // 👈 APP STARTS HERE
    );
  }
}
