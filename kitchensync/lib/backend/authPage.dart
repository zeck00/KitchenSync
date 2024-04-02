// ignore_for_file: file_names, prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kitchensync/screens/bottomNavBar.dart';
import 'package:kitchensync/screens/onBoardingPages.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return MainLayout();
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer larger circle
                CircularProgressIndicator(
                  strokeCap: StrokeCap.round,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
                  strokeWidth: 8,
                  backgroundColor: Colors.grey[300],
                ),
                // Inner smaller circle
                CircularProgressIndicator(
                  strokeCap: StrokeCap.round,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                  strokeWidth: 4,
                ),
              ],
            ),
          );
        } else {
          return OnboardingScreen();
        }
      },
    ));
  }
}
