// ignore_for_file: prefer_final_fields, prefer_const_constructors, prefer_const_literals_to_create_immutables, camel_case_types, file_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kitchensync/screens/bottomNavBar.dart';
import 'package:kitchensync/screens/loginPage.dart';
import 'package:kitchensync/styles/AppColors.dart';
import 'package:kitchensync/styles/AppFonts.dart';
import 'package:kitchensync/styles/size_config.dart';

class registerPage extends StatefulWidget {
  const registerPage({
    super.key,
  });

  @override
  State<registerPage> createState() => _registerPageState();
}

class _registerPageState extends State<registerPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _conpasswordController = TextEditingController();
  bool _isButtonDisabled = true; // Initial state of the login button
  bool _showEmailError = false;
  bool _showPasswordError = false;

  Future _handleRegister() async {
    if (passwordConfirmed()) {
      FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    }
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => MainLayout(),
    ));
  }

  bool passwordConfirmed() {
    if (_passwordController.text.trim() == _conpasswordController.text.trim()) {
      return true;
    } else {
      return false;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _conpasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    initSizeConfig(context);
    return Scaffold(
      body: Padding(
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
                      backgroundColor:
                          MaterialStatePropertyAll(Colors.white.withAlpha(0))),
                  onPressed: _isButtonDisabled ? null : () => _handleRegister(),
                  // Button is disabled if _isButtonDisabled is true
                  child: Container(
                      width: propWidth(600),
                      height: propHeight(55),
                      decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(propWidth(17))),
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
                        MaterialPageRoute(builder: (context) => LoginPage()),
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
                  child: CircleAvatar(
                    radius: propWidth(30),
                    backgroundColor: AppColors.grey2,
                    child: Image.asset('assets/images/glogo.png',
                        width: propWidth(40), height: propHeight(40)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
