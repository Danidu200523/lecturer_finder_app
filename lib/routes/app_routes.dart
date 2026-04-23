import 'package:flutter/material.dart';
import 'package:lecturer_finder_app/auth/lecturer/lecturer_login_screen.dart';
import 'package:lecturer_finder_app/lecturer/logout/lecturer_logout_screen.dart';
import 'package:lecturer_finder_app/lecturer/profile/edit_lecturer_profile_screen.dart'
    show LecturerEditProfileScreen;
import 'package:lecturer_finder_app/lecturer/slots/add_slot_screen.dart';
import 'package:lecturer_finder_app/lecturer/slots/slot_management_screen.dart';
import '../auth/lecturer/lecturer_signup_screen.dart';
import '../splash/splash_screen.dart';
import '../onboarding/onboarding_screen.dart';
import '../auth/role_selection_screen.dart';
import '../lecturer/availability/availability_marking_screen.dart';
import '../auth/student/student_login_screen.dart'; //  student routes
import '../auth/student/student_signup_screen.dart';
import '../student/search/lecturer_search_screen.dart';
import '../student/favorites/favorite_lecturers_screen.dart';
import '../student/booking/lecturer_availability_screen.dart';
import '../student/booking/slot_booking_screen.dart';
import '../student/profile/student_profile_screen.dart';
import '../student/profile/edit_student_profile_screen.dart';
import '../lecturer/slots/view_booking_screen.dart';


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
    '/edit-profile': (context) => const LecturerEditProfileScreen(),
    '/lecturer-logout': (context) => LecturerLogoutScreen(),
    '/view-booking': (context) => const ViewBookingScreen(bookingId: ""),

    //student routes
    '/student-login': (context) => const StudentLoginScreen(),
    '/student-signup': (context) => const StudentSignUpScreen(),
    '/student-search': (context) => const StudentSearchScreen(),
    '/student-favorites': (context) => const StudentFavoritesScreen(),
    '/lecturer-availability': (context) => const LecturerAvailabilityScreen(),
    '/slot-booking': (context) => const SlotBookingScreen(lecturerId: ""),
    '/student-profile': (context) => const StudentProfileScreen(),
    '/student-edit-profile': (context) => const EditStudentProfileScreen(),
  };
}
