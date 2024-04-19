// ignore_for_file: prefer_const_constructors, use_super_parameters, library_private_types_in_public_api, file_names

import 'package:flutter/material.dart';
import 'package:kitchensync/styles/AppColors.dart';
import 'package:kitchensync/styles/AppFonts.dart';
import 'package:kitchensync/styles/size_config.dart';
import 'package:kitchensync/screens/loginPage.dart';
import 'package:kitchensync/screens/registerPage.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    initSizeConfig(context);
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/hero.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Positioned(
          //   top: propHeight(500),
          //   child: Padding(
          //     padding: EdgeInsets.all(propWidth(16)),
          //     child: Text(
          //       'Discover the best kitchen experience!',
          //       style: TextStyle(
          //         fontSize: propWidth(20), // Adjust the font size
          //         fontWeight: FontWeight.bold,
          //         color: Colors.black,
          //       ),
          //     ),
          //   ),
          // ),
          // Padding(
          //   padding: EdgeInsets.only(bottom: propHeight(20)),
          //   child: Text(
          //     'Let Trip Planner guide you',
          //     style: TextStyle(
          //       fontSize: propWidth(16), // Adjust the font size
          //       color: Colors.black,
          //     ),
          //   ),
          // ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Spacer(),
              Container(
                width: double.infinity,
                height: propHeight(300),
                decoration: BoxDecoration(
                  color: AppColors.light,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(propHeight(30)),
                      topRight: Radius.circular(propHeight(30))),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Spacer(),
                    ElevatedButton(
                      autofocus: true,
                      style: ButtonStyle(
                          elevation: MaterialStatePropertyAll(0),
                          backgroundColor: MaterialStatePropertyAll(
                              Colors.white.withAlpha(0))),
                      onPressed: () => navigateToRegistration(context),
                      child: Container(
                          width: propWidth(370),
                          height: propHeight(65),
                          decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius:
                                  BorderRadius.circular(propWidth(30))),
                          child: Center(
                            child: Text(
                              'Create New Account',
                              style: AppFonts.login,
                            ),
                          )),
                    ),
                    SizedBox(height: propHeight(15)),
                    GestureDetector(
                      onTap: () => navigateToLogin(context),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'I already have an account',
                            style: AppFonts.subtitle1,
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    Container(
                        width: propWidth(370),
                        height: propHeight(2),
                        decoration: BoxDecoration(
                          color: AppColors.greySub,
                          borderRadius: BorderRadius.circular(propWidth(30)),
                        )),
                    SizedBox(height: propHeight(20)),
                    Text(
                        '© ${DateTime.now().year} KitchenSync. All Rights Reserved.',
                        style: AppFonts.minittles),
                    // SizedBox(
                    //   height: propHeight(60),
                    // )
                    Spacer()
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void navigateToRegistration(BuildContext context) {
    // Navigate to registration page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => registerPage()),
    );
  }

  void navigateToLogin(BuildContext context) {
    // Navigate to login page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }
}
