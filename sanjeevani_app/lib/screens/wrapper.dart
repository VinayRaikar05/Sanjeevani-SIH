import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart'; // Patient's Home
import 'doctor_home_screen.dart'; // Doctor's Home
import 'login_screen.dart';
import 'role_selection_screen.dart'; // Role Selection
import '../providers/auth_provider.dart' as app;

class Wrapper extends StatelessWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<app.AuthProvider>(context);
    final currentUser = authProvider.user;

    if (currentUser == null) {
      // If no one is logged in at all, show the login screen.
      print('Wrapper - No user logged in, showing login screen');
      return const LoginScreen();
    } else {
      // If someone is logged in, check their role.
      print('Wrapper - User logged in: ${currentUser.toString()}');
      print('Wrapper - User role: ${currentUser.role}');
      print('Wrapper - Role type: ${currentUser.role.runtimeType}');
      
      switch (currentUser.role) {
        case 'PATIENT':
          print('Wrapper - Navigating to PATIENT home screen');
          return const HomeScreen(); // Your existing patient home screen
        case 'DOCTOR':
          print('Wrapper - Navigating to DOCTOR home screen');
          return const DoctorHomeScreen(); // The new doctor dashboard
        case 'UNKNOWN':
          print('Wrapper - User role is UNKNOWN, showing role selection');
          // If their role is UNKNOWN, it means they are a new user who needs to pick a role.
          return RoleSelectionScreen(user: currentUser);
        default:
          print('Wrapper - Unexpected role: ${currentUser.role}, showing role selection');
          // As a fallback in case of an unexpected role, show role selection instead of login
          return RoleSelectionScreen(user: currentUser);
      }
    }
  }
}
