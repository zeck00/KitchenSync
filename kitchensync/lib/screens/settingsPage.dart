// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api, file_names

import 'package:flutter/material.dart';
import 'package:kitchensync/screens/appBar.dart';
import 'package:kitchensync/screens/customDeviceCard.dart';
import 'package:kitchensync/styles/AppColors.dart';
import 'package:kitchensync/styles/AppFonts.dart';

import 'size_config.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: ListView(
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
          _buildListItem('Manage Your Account'),
          _buildListItem('Manage Your Privacy'),
          _buildListItem('About KitchenSync'),
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
            clipBehavior: Clip.none,
            scrollDirection: Axis.horizontal,
            child: Row(
              children: devices.map((device) {
                return Padding(
                  padding: EdgeInsets.only(
                      right: propWidth(25)), // space between cards
                  child: CustomDeviceCard(
                    title: '${device['name']} - ${device['count']}',
                    itemCount: device['count']!,
                    imagePath:
                        device['imagePath']!, // Replace with actual image path
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

Widget _buildListItem(String title) {
  return Padding(
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
  );
}

Widget _buildCommunicationOptionsSection() {
  return Column(
    children: [
      SizedBox(height: propHeight(30)),
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
          Container(
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
          SizedBox(width: 5),
          Container(
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
          )
        ],
      ),
      SizedBox(height: propHeight(10)),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
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
          SizedBox(width: propWidth(5)),
          Container(
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
          SizedBox(width: propWidth(5)),
          Container(
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
          SizedBox(width: propWidth(5)),
          Container(
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
          SizedBox(width: propWidth(5)),
          Container(
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
          SizedBox(width: propWidth(5)),
          Container(
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
        ],
      ),
    ],
  );
}
