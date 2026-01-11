import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 48),

              // Title
              const Text(
                'Get Started',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w500, // Poppins Medium
                  color: AppColors.titleText,
                ),
              ),

              const SizedBox(height: 40),

              // Card container
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 32,
                  horizontal: 24,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: AppColors.black.withOpacity(0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Lecturer button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Navigate to Lecturer Login
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: const Text(
                          'Lecturer',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Student button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Navigate to Student Login
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: const Text(
                          'Student',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Illustration
              Image.asset(
                'assets/images/graduate.png',
                height: 220,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
