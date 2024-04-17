// ignore_for_file: prefer_final_fields, prefer_const_constructors, prefer_const_literals_to_create_immutables, camel_case_types, file_names, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kitchensync/backend/notification_manager.dart';
import 'package:kitchensync/screens/bottomNavBar.dart';
import 'package:kitchensync/screens/loginPage.dart';
import 'package:kitchensync/styles/AppColors.dart';
import 'package:kitchensync/styles/AppFonts.dart';
import 'package:kitchensync/styles/size_config.dart';
import 'package:confetti/confetti.dart';

class registerPage extends StatefulWidget {
  const registerPage({
    super.key,
  });

  @override
  State<registerPage> createState() => _registerPageState();
}

class _registerPageState extends State<registerPage> {
  final NotificationManager notificationManager = NotificationManager();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _conpasswordController = TextEditingController();
  late ConfettiController _confettiController;

  void rqnotif(BuildContext context) {
    notificationManager.requestPermissionsAndSendWelcome(context);
  }

  bool _showEmailError = false;
  bool _showPasswordError = false;

  bool passwordConfirmed() {
    if (_passwordController.text.trim() == _conpasswordController.text.trim()) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> _handleRegister() async {
    if (!passwordConfirmed()) {
      setState(() {
        _showPasswordError =
            true; // Update to show an appropriate error message.
      });
      return; // Exit early since the passwords do not match.
    }

    setState(() {
      _showPasswordError = false; // Reset the password error if needed.
    });

    try {
      // Use `await` to wait for the registration process to complete.
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // If successful, navigate to the MainLayout.
      _showCustomOverlay(context);
      _confettiController.play();
      await Future.delayed(Duration(seconds: 1)); // Wait for confetti to finish

      // Optionally, add additional delay or wait for user action to navigate away
      await Future.delayed(Duration(seconds: 2));

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => MainLayout()),
      );
    } on FirebaseAuthException catch (e) {
      // Handle errors from Firebase Auth here, such as email already in use.
      // You can use `e.code` to show specific error messages.
      showErrorMessage(
          e.code); // This function should be implemented to handle errors.
    }
    rqnotif(context);
  }

  void showErrorMessage(String errorCode) {
    String errorMessage;

    if (errorCode == 'user-not-found') {
      errorMessage = 'No user found for that email.';
    } else if (errorCode == 'wrong-password') {
      errorMessage = 'Wrong password provided for that user.';
    } else {
      errorMessage = 'An unexpected error occurred.';
    }

    if (mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            elevation: 20,
            shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.circular(propWidth(17))),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Registration Error',
                  style: AppFonts.warning,
                ),
              ],
            ),
            content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [Text(errorMessage)]),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextButton(
                    child: Text(
                      'OK',
                      style: AppFonts.appname,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                  ),
                ],
              ),
            ],
          );
        },
      );
    }
  }

  void _showCustomOverlay(BuildContext context) {
    final overlay = Overlay.of(context);
    final overlayEntry = _createOverlayEntry(context);

    // Insert the overlay entry to the overlay
    overlay.insert(overlayEntry);

    // Wait for 2 seconds and remove the overlay
    Future.delayed(Duration(seconds: 3)).then((value) => overlayEntry.remove());
  }

  OverlayEntry _createOverlayEntry(BuildContext context) {
    return OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.5,
        left: MediaQuery.of(context).size.width * 0.25,
        width: MediaQuery.of(context).size.width * 0.5,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.green,
              borderRadius: BorderRadius.circular(17),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.light,
                  child: Icon(Icons.check, size: 50, color: AppColors.primary),
                ),
                SizedBox(height: propHeight(10)),
                Text(
                  'Sucessfully Registered !',
                  style: AppFonts.registeration,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showOverlay(BuildContext context) async {
    OverlayState overlayState = Overlay.of(context);
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height / 2 - 100,
        left: MediaQuery.of(context).size.width / 2 - 100,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Item Added',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
        ),
      ),
    );

    overlayState.insert(overlayEntry);

    // Wait for 3 seconds and remove the overlay
    await Future.delayed(Duration(seconds: 3));
    overlayEntry.remove();
  }

  @override
  void initState() {
    super.initState();
    notificationManager.initNotifications();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    initSizeConfig(context);
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
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
                      'Please Register',
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
                    SizedBox(height: propHeight(17)),
                    TextField(
                      controller: _conpasswordController, // And this one
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
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
                    SizedBox(height: 24),

                    // RippleButton(
                    //   onTap: _handleLogin, // Pass the login logic as a callback
                    // ),

                    ElevatedButton(
                      autofocus: true,
                      style: ButtonStyle(
                          elevation: MaterialStatePropertyAll(0),
                          backgroundColor: MaterialStatePropertyAll(
                              Colors.white.withAlpha(0))),
                      onPressed: _handleRegister,
                      child: Container(
                          width: propWidth(600),
                          height: propHeight(55),
                          decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius:
                                  BorderRadius.circular(propWidth(17))),
                          child: Center(
                            child: Text(
                              'Sign Up',
                              style: AppFonts.login,
                            ),
                          )),
                    ),
                    SizedBox(height: propHeight(10)),
                    GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already a member?',
                              style: AppFonts.subtitle,
                            ),
                            Text(
                              ' Login now',
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
                    SizedBox(height: propHeight(80)),
                    Text(
                        '© ${DateTime.now().year} KitchenSync. All Rights Reserved.',
                        style: AppFonts.minittles)
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: [
                AppColors.primary,
                AppColors.light,
                AppColors.red,
              ],
              // add more properties for customization as needed
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _conpasswordController.dispose();
    _confettiController.dispose();
    super.dispose();
  }
}
