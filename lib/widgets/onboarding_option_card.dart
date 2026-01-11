import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class OnboardingOptionCard extends StatelessWidget {
  final String imagePath;
  final String text;

  const OnboardingOptionCard({
    super.key,
    required this.imagePath,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 313,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.blue,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            width: 28,
            height: 28,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 12),
          Text(
           text,
           style: const TextStyle(
           fontSize: 39,                 // 👈 Figma size
           fontWeight: FontWeight.w500,  // Medium
           color: Colors.black,          // Black text
            ),
          ),
        ],
      ),
    );
  }
}
