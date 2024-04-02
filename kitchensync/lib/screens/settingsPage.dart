// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api, file_names, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kitchensync/screens/appBar.dart';
import 'package:kitchensync/screens/customDeviceCard.dart';
import 'package:kitchensync/screens/loginPage.dart';
import 'package:kitchensync/styles/AppColors.dart';
import 'package:kitchensync/styles/AppFonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../styles/size_config.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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
      appBar: CustomAppBar(),
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
            child: Text(
              'Settings',
              style: AppFonts.welcomemsg1,
            ),
          ),
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(children: [
                Row(
                  children: [
                    Text('Manage Your Devices', style: AppFonts.servicename),
                    Expanded(child: Container()),
                    Image.asset(
                      'assets/images/Next.png',
                      color: AppColors.dark,
                      width: propWidth(32),
                      height: propHeight(32),
                    ),
                  ],
                ),
              ])),
          // Device management section
          _buildManageDevicesSection(),
          // Account, Privacy, and About sections
          SizedBox(height: propHeight(35)),
          _buildListItem('Manage Your Account', null),
          _buildListItem('Manage Your Privacy', null),
          _buildListItem(
            'About KitchenSync',
            () async {
              final Uri uri =
                  Uri.parse('https://saifalfalahi.github.io/hikitchensync/#');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              } else {
                throw 'Could not launch';
              }
            },
          ),
          SizedBox(height: propHeight(10)),
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
          // The "We Listen" section with communication options
          _buildCommunicationOptionsSection(),
        ],
      ),
    );
  }

  Widget _buildManageDevicesSection() {
    final devices = [
      {
        'name': 'Refrigerator',
        'count': '41',
        'imagePath': 'assets/images/Refg.png'
      },
      {
        'name': 'Freezer',
        'count': '37',
        'imagePath': 'assets/images/Refg1.png'
      },
      {
        'name': 'Refrigerator',
        'count': '41',
        'imagePath': 'assets/images/Refg.png'
      },
      // Add more device data here
    ];

    return Column(
      children: [
        SizedBox(
          height: propHeight(60),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.0),
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            clipBehavior: Clip.none,
            scrollDirection: Axis.horizontal,
            child: Row(
              children: devices.map((device) {
                return Padding(
                  padding: EdgeInsets.only(
                      right: propWidth(25)), // space between cards
                  child: CustomDeviceCard(
                    title: '${device['name']} - ${device['count']}',
                    // itemCount: device['count']!,
                    imagePath: device['imagePath']!,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

// Padding(
//   padding: EdgeInsets.symmetric(horizontal: 25, vertical: 20),
//   child: Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Text('Manage Your Devices', style: AppFonts.servicename),
//       SizedBox(height: 10),
//       Container(
//         height: 100, // Adjust based on your item card height
//         child: ListView.builder(
//           scrollDirection: Axis.horizontal,
//           itemCount: devices.length,
//           itemBuilder: (context, index) {
//             return CustomDeviceCard(
//               title: devices[index]['name']!,
//               itemCount: devices[index]['count']!,
//               imagePath:
//                   'assets/images/Refg.png', // Replace with actual image path
//             );
//           },
//         ),
//       ),
//     ],
//   ),

Widget _buildListItem(String title, onTap) {
  return InkWell(
    onTap: onTap,
    highlightColor: AppColors.light.withAlpha(255),
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
        children: [
          Row(
            children: [
              Text(title, style: AppFonts.servicename),
              Expanded(child: Container()),
              Image.asset(
                'assets/images/Next.png',
                color: AppColors.dark,
                width: propWidth(32),
                height: propHeight(32),
              ),
            ],
          ),
          SizedBox(height: 10),
          Container(
            width: double.infinity,
            height: 2,
            decoration: BoxDecoration(
                color: AppColors.grey2,
                borderRadius: BorderRadius.all(Radius.circular(10))),
          ),
          SizedBox(height: 5),
        ],
      ),
    ),
  );
}

Widget _buildCommunicationOptionsSection() {
  return Column(
    children: [
      SizedBox(height: propHeight(10)),
      Text(
        'We Listen!',
        style: AppFonts.appname,
      ),
      Text(
        'Please reach out if you have any inquiry',
        style: AppFonts.subtitle,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: () async {
              final Uri uri = Uri.parse('tel:+971547151059');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              } else {
                throw 'Could not launch $uri';
              }
            },
            child: Container(
              width: propWidth(175),
              height: propHeight(40),
              decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.all(Radius.circular(15))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/Ring.png',
                    width: propWidth(30),
                    height: propHeight(18),
                  ),
                  SizedBox(width: propWidth(10)),
                  Text(
                    'Call Us',
                    style: AppFonts.locCard,
                  )
                ],
              ),
            ),
          ),
          SizedBox(width: 5),
          InkWell(
            onTap: () async {
              final Uri email = Uri.parse('mailto:hikitchensync@gmail.com');
              if (await canLaunchUrl(email)) {
                await launchUrl(email);
              } else {
                throw 'Could not launch $email';
              }
            },
            child: Container(
              width: propWidth(175),
              height: propHeight(40),
              decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.all(Radius.circular(15))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/At.png',
                    width: propWidth(18),
                    height: propHeight(18),
                  ),
                  SizedBox(width: propWidth(10)),
                  Text(
                    'Write To Us',
                    style: AppFonts.locCard,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
      SizedBox(height: propHeight(10)),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () async {
              final Uri uri = Uri.parse('https://www.x.com/');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              } else {
                throw 'Could not launch $uri';
              }
            },
            child: Container(
              width: propWidth(55),
              height: propHeight(40),
              decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.all(Radius.circular(15))),
              child: Image.asset(
                'assets/images/X.png',
                width: propWidth(21),
              ),
            ),
          ),
          SizedBox(width: propWidth(5)),
          GestureDetector(
            onTap: () async {
              final Uri uri = Uri.parse('https://www.linkedin.com/');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              } else {
                throw 'Could not launch $uri';
              }
            },
            child: Container(
              width: propWidth(55),
              height: propHeight(40),
              decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.all(Radius.circular(15))),
              child: Image.asset(
                'assets/images/LinkedIn.png',
                width: propWidth(21),
              ),
            ),
          ),
          SizedBox(width: propWidth(5)),
          GestureDetector(
            onTap: () async {
              final Uri uri = Uri.parse('https://www.snapchat.com/');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              } else {
                throw 'Could not launch $uri';
              }
            },
            child: Container(
              width: propWidth(55),
              height: propHeight(40),
              decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.all(Radius.circular(15))),
              child: Image.asset(
                'assets/images/Snapchat.png',
                width: propWidth(21),
              ),
            ),
          ),
          SizedBox(width: propWidth(5)),
          GestureDetector(
            onTap: () async {
              final Uri uri = Uri.parse('https://www.youtube.com/');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              } else {
                throw 'Could not launch $uri';
              }
            },
            child: Container(
              width: propWidth(55),
              height: propHeight(40),
              decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.all(Radius.circular(15))),
              child: Image.asset(
                'assets/images/YouTube.png',
                width: propWidth(21),
              ),
            ),
          ),
          SizedBox(width: propWidth(5)),
          GestureDetector(
            onTap: () async {
              final Uri uri = Uri.parse('https://www.facebook.com/');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              } else {
                throw 'Could not launch $uri';
              }
            },
            child: Container(
              width: propWidth(55),
              height: propHeight(40),
              decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.all(Radius.circular(15))),
              child: Image.asset(
                'assets/images/Facebook.png',
                width: propWidth(21),
              ),
            ),
          ),
          SizedBox(width: propWidth(5)),
          GestureDetector(
            onTap: () async {
              final Uri uri =
                  Uri.parse('https://www.instagram.com/hikitchensync');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              } else {
                throw 'Could not launch $uri';
              }
            },
            child: Container(
              width: propWidth(55),
              height: propHeight(40),
              decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.all(Radius.circular(15))),
              child: Image.asset(
                'assets/images/Instagram.png',
                width: propWidth(21),
              ),
            ),
          )
        ],
      ),
    ],
  );
}
