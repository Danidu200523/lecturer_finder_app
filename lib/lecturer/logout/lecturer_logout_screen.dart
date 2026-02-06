import 'package:flutter/material.dart';
import 'package:lecturer_finder_app/auth/lecturer/lecturer_login_screen.dart';
import 'package:lecturer_finder_app/lecturer/availability/availability_marking_screen.dart';
import 'package:lecturer_finder_app/services/auth_service.dart';
import '../../core/theme/app_colors.dart';


class LecturerLogoutScreen extends StatelessWidget {
  LecturerLogoutScreen({super.key});

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon circle
              Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.darkBlue,
                ),
                child: Center(
                  child: Container(
                    height: 70,
                    width: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.blue,
                    ),
                    child: const Icon(
                      Icons.lock,
                      color: AppColors.black,
                      size: 32,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Logged Out text
              const Text(
                "Logged Out",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              const Text(
                "You have been\nsuccessfully logged out",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: AppColors.gray),
              ),

              const SizedBox(height: 32),

              // Log in Again button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () async {
                    await _authService.lecturerLogout();

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => LecturerLoginScreen()),
                      (route) => false,
                    );
                  },
                  child: const Text(
                    "Log In Again",
                    style: TextStyle(fontSize: 16, color: AppColors.white),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Return to Home button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    side: const BorderSide(color: AppColors.blue),
                  ),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => LecturerStatusScreen()),
                      (route) => false,
                    );
                  },
                  child: const Text(
                    "Return to Home",
                    style: TextStyle(fontSize: 16, color: AppColors.blue),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
