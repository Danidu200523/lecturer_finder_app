import 'package:flutter/material.dart';
import '../auth/lecturer/lecturer_signup_screen.dart';
import '../splash/splash_screen.dart';
import '../onboarding/onboarding_screen.dart';
import '../auth/role_selection_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/': (context) => const SplashScreen(),
    '/onboarding': (context) => const OnboardingScreen(),
    '/role-selection': (context) => const RoleSelectionScreen(),
    '/lecturer-signup': (context) => const LecturerSignUpScreen(),
  };
}
