// ignore_for_file: camel_case_types, file_names, prefer_const_constructors, prefer_const_literals_to_create_immutables, unused_element, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kitchensync/screens/loginPage.dart';
import 'package:kitchensync/styles/AppColors.dart';
import 'package:kitchensync/styles/AppFonts.dart';
import 'package:kitchensync/styles/size_config.dart';

class forgotPasswordPage extends StatefulWidget {
  const forgotPasswordPage({super.key});

  @override
  State<forgotPasswordPage> createState() => _forgotPasswordPageState();
}

class _forgotPasswordPageState extends State<forgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _showEmailError = false;
  @override
  void initState() {
    super.initState();
    // Add listeners to controllers to enable the button when conditions are met
    _emailController.addListener(_validateForm);
  }

  void _validateForm() {
    final email = _emailController.text.trim();
    final isValidEmail =
        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);

    setState(() {
      // Email format error
      _showEmailError = email.isNotEmpty && !isValidEmail;
    });
  }

  Future resetPassword() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text.trim());
      // Show success dialog
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            elevation: 20,
            shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.circular(propWidth(17))),
            title: Text(
              'Success',
              textAlign: TextAlign.center,
              style: AppFonts.appname,
            ),
            content: Text(
              'Password Reset Link Sent! Check Your Email.',
              textAlign: TextAlign.center,
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  'OK',
                  style: AppFonts.appname,
                ),
                onPressed: () {
                  Navigator.of(context)
                      .pop(); // Close the dialog and return to login screen
                },
              ),
            ],
          );
        },
      );
      // After the dialog is dismissed, navigate to login page
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } on FirebaseAuthException catch (e) {
      // Handle errors and stay on the reset password page
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: AppColors.red,
        content: Text(
          'Failed to send email! ${e.message}',
          style: AppFonts.cntrstText,
        ),
      ));
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(propHeight(16)),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: propHeight(50)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Image.asset(
                        'assets/images/Prvs.png',
                        width: propWidth(40),
                        height: propHeight(40),
                      ),
                    ),
                    Expanded(child: Container()),
                    Image.asset(
                      'assets/images/logo.png',
                      width: propWidth(40),
                      height: propHeight(40),
                    )
                  ],
                ),
                SizedBox(height: propHeight(100)),
                Text(
                  'Enter Your Email, And We Will Send You A Link To Reset Your Password!',
                  style: AppFonts.servicename,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: propHeight(20)),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(propWidth(17))),
                  ),
                  autofillHints: [AutofillHints.email],
                  keyboardType: TextInputType.emailAddress,
                ),
                if (_showEmailError)
                  Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      'The entered email is not valid.',
                      style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          color: AppColors.red),
                    ),
                  ),
                SizedBox(height: propHeight(20)),
                ElevatedButton(
                  autofocus: true,
                  style: ButtonStyle(
                      elevation: MaterialStatePropertyAll(0),
                      backgroundColor:
                          MaterialStatePropertyAll(Colors.white.withAlpha(0))),
                  onPressed: resetPassword,
                  child: Container(
                      width: propWidth(600),
                      height: propHeight(55),
                      decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(propWidth(17))),
                      child: Center(
                        child: Text(
                          'Reset Password',
                          style: AppFonts.login,
                        ),
                      )),
                ),
                SizedBox(height: propHeight(100)),
                SizedBox(height: propHeight(100)),
                Text(
                    '© ${DateTime.now().year} KitchenSync. All Rights Reserved.',
                    style: AppFonts.minittles)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
