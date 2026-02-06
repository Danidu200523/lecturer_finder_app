import 'package:flutter/material.dart';
import 'package:lecturer_finder_app/auth/lecturer/lecturer_login_screen.dart';
import 'package:lecturer_finder_app/lecturer/logout/lecturer_logout_screen.dart';
import 'package:lecturer_finder_app/lecturer/profile/edit_lecturer_profile_screen.dart'
    show EditProfileScreen;
import 'package:lecturer_finder_app/lecturer/slots/add_slot_screen.dart';
import 'package:lecturer_finder_app/lecturer/slots/slot_management_screen.dart';
import '../auth/lecturer/lecturer_signup_screen.dart';
import '../splash/splash_screen.dart';
import '../onboarding/onboarding_screen.dart';
import '../auth/role_selection_screen.dart';
import '../lecturer/availability/availability_marking_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/': (context) => const SplashScreen(),
    '/onboarding': (context) => const OnboardingScreen(),
    '/role-selection': (context) => const RoleSelectionScreen(),
    '/lecturer-signup': (context) => const LecturerSignUpScreen(),
    '/lecturer-login': (context) => const LecturerLoginScreen(),
    '/lecturer-status': (context) => const LecturerStatusScreen(),
    '/manage-slots': (context) => const SlotManagementScreen(),
    '/add-slot': (context) => const AddTimeSlotScreen(),
    '/edit-profile': (context) => const EditProfileScreen(),
    '/lecturer-logout': (context) => LecturerLogoutScreen(),
  };
}
