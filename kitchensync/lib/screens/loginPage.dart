// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unused_import, file_names

import 'package:flutter/material.dart';
import 'package:kitchensync/styles/AppColors.dart';
import 'package:kitchensync/styles/AppFonts.dart';
import 'package:kitchensync/styles/rippleButton.dart';
import 'package:kitchensync/styles/size_config.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  // Add your state variables here if you have any
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    // Always remember to dispose controllers when the state object is removed
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    // Implement your login logic here
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
                  style: AppFonts.appname,
                ),
                Text(
                  'Please Login',
                  style: AppFonts.subtitle,
                ),
                SizedBox(height: propHeight(20)),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(propWidth(17))),
                  ),
                  autofillHints: [AutofillHints.email],
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(propWidth(17))),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 24),
                RippleButton(
                  onTap: _handleLogin, // Pass the login logic as a callback
                ),

                // ElevatedButton(
                //   autofocus: true,
                //   style: ButtonStyle(
                //       elevation: MaterialStatePropertyAll(0),
                //       backgroundColor:
                //           MaterialStatePropertyAll(Colors.white.withAlpha(0))),
                //   onPressed: () {},
                //   child: Container(
                //       width: propWidth(90),
                //       height: propHeight(50),
                //       decoration: BoxDecoration(
                //           color: AppColors.primary,
                //           borderRadius: BorderRadius.circular(propWidth(17))),
                //       child: Center(
                //         child: Text(
                //           'Login',
                //           style: AppFonts.login,
                //         ),
                //       )),
                // ),
                TextButton(
                    onPressed: () {
                      // Navigate to the registration screen
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
                Divider(thickness: 2, height: propHeight(35)),
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
