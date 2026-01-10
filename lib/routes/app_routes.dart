import 'package:flutter/material.dart';
import '../splash/splash_screen.dart';
import '../onboarding/onboarding_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/': (context) => const SplashScreen(),
    '/onboarding': (context) => const OnboardingScreen(),
  };
}
