import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myedu/controllers/auth_controller.dart';
import 'package:myedu/views/dashboard_view.dart';
import 'package:myedu/views/sign_in_view.dart';

class Authgate extends StatelessWidget {
  const Authgate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          if (user == null) {
            return const SignInView();
          } else {
            AuthController.instance.loadUserData();
            return const DashboardView();
          }
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
