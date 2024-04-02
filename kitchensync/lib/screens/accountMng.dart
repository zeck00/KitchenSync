// ignore_for_file: prefer_const_constructors, camel_case_types, file_names, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kitchensync/screens/forgotPasswordPage.dart';
import 'package:kitchensync/screens/loginPage.dart';
import 'package:kitchensync/styles/AppColors.dart';
import 'package:kitchensync/styles/AppFonts.dart';
import 'package:kitchensync/styles/size_config.dart';

class accMgmtPage extends StatefulWidget {
  const accMgmtPage({super.key});

  @override
  State<accMgmtPage> createState() => _accMgmtPageState();
}

class _accMgmtPageState extends State<accMgmtPage> {
  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to sign out'),
      ));
    }

    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));
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
                  'You Can Either Reset Your Password Or Sign Out Of Your Account, We Are Working On More Customization Features Soon',
                  style: AppFonts.servicename,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: propHeight(20)),
                SizedBox(height: propHeight(20)),
                ElevatedButton(
                  autofocus: true,
                  style: ButtonStyle(
                      elevation: MaterialStatePropertyAll(0),
                      backgroundColor:
                          MaterialStatePropertyAll(Colors.white.withAlpha(0))),
                  onPressed: _signOut,
                  child: Container(
                      width: propWidth(200),
                      height: propHeight(45),
                      decoration: BoxDecoration(
                          color: AppColors.red,
                          borderRadius: BorderRadius.circular(propWidth(17))),
                      child: Center(
                        child: Text(
                          'Sign Out',
                          style: AppFonts.login,
                        ),
                      )),
                ),
                SizedBox(height: propHeight(30)),
                ElevatedButton(
                  autofocus: true,
                  style: ButtonStyle(
                      elevation: MaterialStatePropertyAll(0),
                      backgroundColor:
                          MaterialStatePropertyAll(Colors.white.withAlpha(0))),
                  onPressed: () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => forgotPasswordPage()));
                  },
                  child: Container(
                      width: propWidth(200),
                      height: propHeight(45),
                      decoration: BoxDecoration(
                          color: AppColors.red,
                          borderRadius: BorderRadius.circular(propWidth(17))),
                      child: Center(
                        child: Text(
                          'Reset Your Password',
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
