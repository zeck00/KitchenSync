// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unused_import, file_names, unused_field, use_build_context_synchronously, avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kitchensync/backend/notification_manager.dart';
import 'package:kitchensync/screens/bottomNavBar.dart';
import 'package:kitchensync/screens/forgotPasswordPage.dart';
import 'package:kitchensync/screens/homePage.dart';
import 'package:kitchensync/screens/mapPage.dart';
import 'package:kitchensync/screens/registerPage.dart';
import 'package:kitchensync/styles/AppColors.dart';
import 'package:kitchensync/styles/AppFonts.dart';
import 'package:kitchensync/styles/rippleButton.dart';
import 'package:kitchensync/styles/size_config.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:quickalert/quickalert.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final NotificationManager notificationManager = NotificationManager();
  // Add your state variables here if you have any
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isButtonDisabled = true; // Initial state of the login button
  bool _showEmailError = false;
  bool _showPasswordError = false;
  void rqnotif(BuildContext context) {
    notificationManager.requestPermissionsAndSendWelcome(context);
  }

  @override
  void initState() {
    super.initState();
    // Add listeners to controllers to enable the button when conditions are met
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
  }

  void _validateForm() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final isValidEmail =
        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);

    setState(() {
      // Email format error
      _showEmailError = email.isNotEmpty && !isValidEmail;
      // Password error (simply checks if the password field is empty)
      _showPasswordError = _passwordController.text.isEmpty;
      // Determines if the login button should be disabled
      _isButtonDisabled = email.isEmpty || password.isEmpty || !isValidEmail;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    // showDialog(
    //   barrierDismissible: false,
    //   context: context,
    //   builder: (context) {
    //     return loadingIndicator();
    //   },
    // );
    QuickAlert.show(
      context: context,
      type: QuickAlertType.loading,
      title: 'Loading',
      backgroundColor: AppColors.light,
      text: 'We\'re fetching your data',
      barrierDismissible: false,
      animType: QuickAlertAnimType.slideInUp,
    );

    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      if (mounted) {
        Navigator.of(context).pop(); // Close the loading dialog
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => MainLayout()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        Navigator.of(context)
            .pop(); // Ensure to close the loading dialog even on error
        showErrorMessage(e.code); // Show the error dialog
      }
    }
    rqnotif(context);
  }

  void showErrorMessage(String errorCode) {
    String errorMessage;

    if (errorCode == 'user-not-found') {
      errorMessage = 'No user found for that email.';
    } else if (errorCode == 'wrong-password') {
      errorMessage = 'Wrong password provided for user.';
    } else {
      errorMessage = 'An unexpected error occurred.';
    }

    if (mounted) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Oops...',
        backgroundColor: AppColors.light,
        confirmBtnTextStyle: AppFonts.appname,
        confirmBtnColor: AppColors.grey2,
        onConfirmBtnTap: () {
          Navigator.of(context).pop();
        },
        text: errorMessage,
        barrierDismissible: true,
        confirmBtnText: 'Ok',
        animType: QuickAlertAnimType.slideInUp,
      );
      // showDialog(
      //   context: context,
      //   builder: (BuildContext context) {
      //     return AlertDialog(
      //       elevation: 20,
      //       shape: ContinuousRectangleBorder(
      //           borderRadius: BorderRadius.circular(propWidth(17))),
      //       title: Row(
      //         mainAxisAlignment: MainAxisAlignment.center,
      //         crossAxisAlignment: CrossAxisAlignment.center,
      //         children: [
      //           Text(
      //             'Login Error',
      //             style: AppFonts.warning,
      //           ),
      //         ],
      //       ),
      //       content: Row(
      //           mainAxisAlignment: MainAxisAlignment.center,
      //           crossAxisAlignment: CrossAxisAlignment.center,
      //           children: [Text(errorMessage)]),
      //       actions: <Widget>[
      //         Row(
      //           mainAxisAlignment: MainAxisAlignment.center,
      //           crossAxisAlignment: CrossAxisAlignment.center,
      //           children: [
      //             TextButton(
      //               child: Text(
      //                 'OK',
      //                 style: AppFonts.appname,
      //               ),
      //               onPressed: () {
      //                 Navigator.of(context).pop(); // Close the dialog
      //               },
      //             ),
      //           ],
      //         ),
      //       ],
      //     );
      //   },
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    initSizeConfig(context);
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(propHeight(16)),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: propHeight(100),
                ),
                Image.asset(
                  'assets/images/logo.png',
                  width: propWidth(100),
                  height: propHeight(100),
                ),
                SizedBox(height: propHeight(10)),
                Text(
                  'Welcome To KitchenSync™',
                  style: AppFonts.welcomemsg1,
                ),
                Text(
                  'Please Login',
                  style: AppFonts.subtitle1,
                ),
                SizedBox(height: propHeight(20)),
                TextField(
                  controller: _emailController, // Add this line
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(propWidth(17))),
                  ),
                  autofillHints: [AutofillHints.email],
                  keyboardType: TextInputType.emailAddress,
                ),

                SizedBox(height: propHeight(5)),
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
                SizedBox(height: propHeight(17)),
                TextField(
                  controller: _passwordController, // And this one
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(propWidth(17))),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: propHeight(5)),
                if (_showPasswordError)
                  Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      'Password is not entered.',
                      style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          color: AppColors.red),
                    ),
                  ),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return forgotPasswordPage();
                        },
                      ),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(propWidth(8), 0, 0, 0),
                    child: Row(
                      children: [
                        Text(
                          'Forgot Password?',
                          style: AppFonts.subtitle1,
                        ),
                      ],
                    ),
                  ),
                ),

                // RippleButton(
                //   onTap: _handleLogin, // Pass the login logic as a callback
                // ),
                SizedBox(height: 24),
                ElevatedButton(
                  autofocus: true,
                  style: ButtonStyle(
                      elevation: MaterialStatePropertyAll(0),
                      backgroundColor:
                          MaterialStatePropertyAll(Colors.white.withAlpha(0))),
                  onPressed: _isButtonDisabled ? null : () => _handleLogin(),
                  // Button is disabled if _isButtonDisabled is true
                  child: Container(
                      width: propWidth(600),
                      height: propHeight(55),
                      decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(propWidth(17))),
                      child: Center(
                        child: Text(
                          'Login',
                          style: AppFonts.login,
                        ),
                      )),
                ),
                SizedBox(height: propHeight(10)),
                GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => registerPage()),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Not a member?',
                          style: AppFonts.subtitle,
                        ),
                        Text(
                          ' Register now',
                          style: AppFonts.subtitle1,
                        ),
                      ],
                    )),
                Divider(
                    thickness: 3,
                    indent: 10,
                    endIndent: 10,
                    height: propHeight(35)),
                Text(
                  'OR',
                  style: AppFonts.login1,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                GestureDetector(
                  onTap: () => AuthService().signInWithGoogle(context),
                  child: CircleAvatar(
                    radius: propWidth(30),
                    backgroundColor: AppColors.grey2,
                    child: Image.asset('assets/images/glogo.png',
                        width: propWidth(40), height: propHeight(40)),
                  ),
                ),
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

class AuthService {
// Google Sign In
  // Google Sign In
  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      // Begin interactive sign-in process
      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

      // Check if the sign-in was aborted by the user
      if (gUser == null) {
        // Handle the situation where the user cancelled the sign-in
        print('Google sign-in was cancelled by the user.');
        return;
      }

      // Obtain auth details from the sign-in request
      final GoogleSignInAuthentication gAuth = await gUser.authentication;

      // Create a new credential for the user
      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      // Finally, let's sign in with the credential
      await FirebaseAuth.instance.signInWithCredential(credential);

      // Navigate to the main layout after successful sign-in
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => MainLayout()),
      );
    } catch (e) {
      // Handle any errors that occur during sign-in
      print('Error signing in with Google: $e');
      // Optionally show an error message to the user
    }
  }
}
