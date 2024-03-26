// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, library_private_types_in_public_api, unused_import, file_names

import 'package:flutter/material.dart';
import 'package:kitchensync/screens/appBar.dart';
import 'package:kitchensync/screens/customDeviceCard.dart';
import 'package:kitchensync/styles/AppColors.dart';
import 'package:kitchensync/styles/AppFonts.dart';
import 'size_config.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isDarkMode = false;
  ThemeMode _themeMode = ThemeMode.system; // Default theme
  void _toggleTheme() {
    setState(() {
      if (_themeMode == ThemeMode.light) {
        _themeMode = ThemeMode.dark;
      } else {
        _themeMode = ThemeMode.light;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    initSizeConfig(context);
    return Scaffold(
      appBar: CustomAppBar(),
      body: Padding(
        padding: EdgeInsets.only(
          left: 25.0,
          right: 25,
          top: 5.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(children: [
              Positioned(
                top: propHeight(41),
                child: Text(
                    'Good Morning, Anything on your mind for breakfast ?',
                    style: AppFonts.minittles),
              ),
              Row(
                children: [
                  Text(
                    'Hi, ',
                    style: AppFonts.welcomemsg2,
                  ),
                  Text(
                    'Ziad',
                    style: AppFonts.welcomemsg1,
                  ),
                ],
              ),
            ]),
            Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  'assets/images/kitchenLight.png',
                  width: propWidth(490),
                  height: propHeight(490),
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: propHeight(20),
                  right: propWidth(25),
                  child: GestureDetector(
                    child: Image.asset(
                      'assets/images/Do not Disturb iOS.png',
                      width: propHeight(35),
                      height: propWidth(35),
                    ),
                    onTap: () {
                      _toggleTheme;
                    },
                  ),
                ),
                Positioned(
                  top: propHeight(90),
                  right: propWidth(75),
                  child: GestureDetector(
                      child: Image.asset(
                    'assets/images/Items.png',
                    width: propWidth(110),
                    height: propHeight(105),
                  )),
                ),
                Positioned(
                  top: propHeight(135),
                  left: propWidth(120),
                  child: GestureDetector(
                      child: Image.asset(
                    'assets/images/Items 1.png',
                    width: propWidth(125),
                    height: propHeight(90),
                  )),
                ),
              ],
            ),
            SizedBox(
              height: propHeight(15),
            ),
            SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              clipBehavior: Clip.none,
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  CustomDeviceCard(
                    title: 'Refrigerator - 1',
                    itemCount: '41',
                    imagePath: 'assets/images/Refg.png',
                  ),
                  SizedBox(width: propWidth(25)),
                  CustomDeviceCard(
                    title: 'Cabinet - 1',
                    itemCount: '13',
                    imagePath: 'assets/images/cabi.png',
                  ),
                  SizedBox(width: propWidth(25)),
                  CustomDeviceCard(
                    title: 'Refrigerator - 2',
                    itemCount: '41',
                    imagePath: 'assets/images/Refg1.png',
                  ),
                  SizedBox(width: propWidth(25)),
                  CustomDeviceCard(
                    title: 'Cabinet - 2',
                    itemCount: '13',
                    imagePath: 'assets/images/cabi1.png',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
