import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../widgets/onboarding_option_card.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

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
              const Spacer(),

              // Title
              Text(
                'Easily Find\nLecturer’s',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w500, // Poppins Medium
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 32),

              // Location Card
              const OnboardingOptionCard(
               imagePath: 'assets/images/location.png',
               text: 'Location',
              ),

              const SizedBox(height: 16),

              // Availability Card
              const OnboardingOptionCard(
               imagePath: 'assets/images/availability.png',
               text: 'Availability',
              ),

              const SizedBox(height: 32),

              // Illustration
              Image.asset(
                'assets/images/onboarding_illustration.png',
                height: 220,
              ),

              const Spacer(),

              // Next Button
              Align(
                alignment: Alignment.bottomRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/role-selection');
                  },
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.darkBlue,
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
