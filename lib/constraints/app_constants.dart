import 'package:flutter/material.dart';

class AppConstants {
  // App Information
  static const String appName = 'MyEdu';
  static const String appVersion = '1.0.0';

  // Faculties
  static const List<String> faculties = [
    'CSE',
    'FBA',
    'AGRI',
    'NFS',
    'ESDM',
    'LLA',
    'Fisheries',
  ];

  // Faculty Full Names
  static const Map<String, String> facultyFullNames = {
    'CSE': 'Computer Science & Engineering',
    'FBA': 'Faculty of Business Administration',
    'AGRI': 'Faculty of Agriculture',
    'NFS': 'Nutrition & Food Science',
    'ESDM': 'Environmental Science & Disaster Management',
    'LLA': 'Languages, Literature & Arts',
    'Fisheries': 'Faculty of Fisheries',
  };

  // Animation Durations
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);

  // Spacing
  static const double smallSpacing = 8.0;
  static const double mediumSpacing = 16.0;
  static const double largeSpacing = 24.0;
  static const double extraLargeSpacing = 32.0;

  // Border Radius
  static const double smallRadius = 8.0;
  static const double mediumRadius = 12.0;
  static const double largeRadius = 16.0;
  static const double extraLargeRadius = 24.0;

  // Elevation
  static const double smallElevation = 2.0;
  static const double mediumElevation = 4.0;
  static const double largeElevation = 8.0;

  // Icon Sizes
  static const double smallIcon = 16.0;
  static const double mediumIcon = 24.0;
  static const double largeIcon = 32.0;
  static const double extraLargeIcon = 48.0;

  // Button Heights
  static const double buttonHeight = 50.0;
  static const double smallButtonHeight = 40.0;
  static const double largeButtonHeight = 56.0;

  // Text Sizes
  static const double smallText = 12.0;
  static const double mediumText = 14.0;
  static const double largeText = 16.0;
  static const double extraLargeText = 18.0;
  static const double headingText = 20.0;
  static const double titleText = 24.0;

  // Firebase Collections
  static const String usersCollection = 'users';

  // Validation Messages
  static const String emailRequired = 'Email is required';
  static const String emailInvalid = 'Please enter a valid email';
  static const String passwordRequired = 'Password is required';
  static const String passwordMinLength =
      'Password must be at least 6 characters';
  static const String nameRequired = 'Name is required';
  static const String facultyRequired = 'Please select a faculty';
  static const String idRequired = 'ID is required';
  static const String regiRequired = 'Registration number is required';
  static const String phoneRequired = 'Phone number is required';
  static const String phoneInvalid = 'Please enter a valid phone number';
  static const String passwordMismatch = 'Passwords do not match';

  // Success Messages
  static const String signUpSuccess = 'Account created successfully!';
  static const String signInSuccess = 'Welcome back!';
  static const String signOutSuccess = 'Signed out successfully';

  // Error Messages
  static const String signUpError = 'Failed to create account';
  static const String signInError = 'Failed to sign in';
  static const String generalError = 'Something went wrong';
  static const String networkError = 'Please check your internet connection';

  // Loading Messages
  static const String signingUp = 'Creating your account...';
  static const String signingIn = 'Signing you in...';
  static const String signingOut = 'Signing out...';
}

class AppImages {
  static const String logo = 'assets/images/logo.png';
  static const String university = 'assets/images/university.png';
  static const String loginBackground = 'assets/images/login_bg.png';
}

class AppRoutes {
  static const String splash = '/';
  static const String signIn = '/signin';
  static const String signUp = '/signup';
  static const String dashboard = '/dashboard';
  static const String profile = '/profile';
}
