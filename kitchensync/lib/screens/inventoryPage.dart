// ignore_for_file: prefer_const_constructors, use_super_parameters, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:kitchensync/screens/appBar.dart';
import 'package:kitchensync/styles/AppColors.dart';
import 'package:kitchensync/styles/AppFonts.dart';
import 'package:kitchensync/screens/size_config.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({Key? key}) : super(key: key);

  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  bool isDarkMode = false;
  int _currentPage = 0;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    initSizeConfig(context);
    return Scaffold(
      appBar: CustomAppBar(),
      body: PageView(
        pageSnapping: true,
        scrollBehavior: MaterialScrollBehavior(),
        physics: BouncingScrollPhysics(),
        allowImplicitScrolling: true,
        controller: _pageController,
        onPageChanged: (int page) {
          setState(() {
            _currentPage = page;
          });
        },
        children: [
          buildPage('Antartica 1.3 State 1', 'Antartica 1.3',
              'assets/images/RefgOpen1.png'),
          buildPage('SavvyStow 2.0 State 1', 'SavvyStow 2.0',
              'assets/images/RefgOpen1.png'),
          buildPage('Antartica 1.2 State 1', 'Antartica 1.2',
              'assets/images/RefgOpen2.png'),
          buildPage('WasteWizard 1.0 State 1', 'WasteWizard 1.0',
              'assets/images/WasteWizard.png'),
          // Add more pages as needed
        ],
      ),
    );
  }

  Widget buildPage(String deviceState, String deviceName, String imagePath) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          left: propWidth(25),
          right: propWidth(25),
          top: propHeight(5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: propHeight(10)), // Adjust as needed
            Row(
              children: [
                Text(
                  'Ziad\'s ',
                  style: AppFonts.welcomemsg2,
                ),
                Text(
                  deviceName,
                  style: AppFonts.welcomemsg1,
                ),
                Expanded(child: Container()),
                Image.asset(
                  'assets/images/Synchronize.png',
                  color: AppColors.dark,
                  width: 35,
                  height: 35,
                ),
              ],
            ),
            SizedBox(height: propHeight(10)),
            Image.asset(
              imagePath,
              width: propWidth(420),
              height: propHeight(370),
            ),
            // Stack(clipBehavior: Clip.none, children: [
            //   Container(
            //     width: propWidth(360),
            //     height: propHeight(380),
            //     decoration: BoxDecoration(
            //         color: AppColors.greySub,
            //         borderRadius: BorderRadius.circular(17)),
            //   ),
            //   Center(
            //     child: Image.asset(
            //       'assets/images/RefgOpen.png',
            //       width: propWidth(370),
            //       height: propHeight(400),
            //     ),
            //   ),
            // ]),
            SizedBox(height: propHeight(10)), // Adjust as needed
            Row(
              children: [
                Text(
                  'What\'s In ',
                  style: AppFonts.subtitle,
                ),
                Text(
                  '$deviceName?',
                  style: AppFonts.subtitle1,
                ),
                Expanded(child: Container()),
                Image.asset(
                  'assets/images/Next.png',
                  color: AppColors.dark,
                  width: 35,
                  height: 35,
                ),
              ],
            ),
            SizedBox(height: propHeight(15)), // Adjust as needed
            SizedBox(
              height: 190,
              child: ListView.builder(
                clipBehavior: Clip.none,
                physics: BouncingScrollPhysics(),
                addRepaintBoundaries: false,
                scrollDirection: Axis.horizontal,
                itemCount: 6, // Replace with the actual number of items
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: EdgeInsets.only(left: 0, right: 10),
                    child: _buildCard(context, index), //defined below
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    int index,
  ) {
    final item = {
      'title': 'Item $index',
      'quantity': '2' '.0 KG',
      'iconPath': 'assets/images/Milk.png', // Replace with item icon path
    };

    return SizedBox(
      width: 135, // Adjust as needed
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: AppColors.primary,
        elevation: 4,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                item['iconPath']!,
                width: propWidth(50),
                height: propHeight(50),
              ),
              Text(item['title']!, style: AppFonts.cardTitle),
              SizedBox(height: propHeight(10)),
              Text(item['quantity']!, style: AppFonts.numbers),
            ],
          ),
        ),
      ),
    );
  }
}

class DeviceStateScreen extends StatelessWidget {
  final String deviceState;

  const DeviceStateScreen({Key? key, required this.deviceState})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // This is a placeholder widget. Replace it with your actual widget that shows the device state
    return Center(
      child: Text(deviceState),
    );
  }
}







// body: Padding(
//   padding: EdgeInsets.only(
//     left: 25,
//     right: 25,
//     top: 5.0,
//   ),
//   child: Column(
//     crossAxisAlignment: CrossAxisAlignment.center,
//     children: [
//       SizedBox(height: propHeight(10)), // Adjust as needed
//       Row(
//         children: [
//           Text(
//             'Ziad\'s ',
//             style: AppFonts.welcomemsg2,
//           ),
//           Text(
//             'Refrigerator',
//             style: AppFonts.welcomemsg1,
//           ),
//           Expanded(child: Container()),
//           Image.asset(
//             'assets/images/Synchronize.png',
//             color: AppColors.dark,
//             width: 35,
//             height: 35,
//           ),
//         ],
//       ),
//       SizedBox(height: propHeight(10)),
//       Image.asset(
//         'assets/images/RefgOpen1.png',
//       ),
//       // Stack(clipBehavior: Clip.none, children: [
//       //   Container(
//       //     width: propWidth(360),
//       //     height: propHeight(380),
//       //     decoration: BoxDecoration(
//       //         color: AppColors.greySub,
//       //         borderRadius: BorderRadius.circular(17)),
//       //   ),
//       //   Center(
//       //     child: Image.asset(
//       //       'assets/images/RefgOpen.png',
//       //       width: propWidth(370),
//       //       height: propHeight(400),
//       //     ),
//       //   ),
//       // ]),
//       SizedBox(height: 10), // Adjust as needed
//       Row(
//         children: [
//           Text(
//             'What\'s In ',
//             style: AppFonts.subtitle,
//           ),
//           Text(
//             'Antartica 1.3?',
//             style: AppFonts.subtitle1,
//           ),
//           Expanded(child: Container()),
//           Image.asset(
//             'assets/images/Next.png',
//             color: AppColors.dark,
//             width: 35,
//             height: 35,
//           ),
//         ],
//       ),
//       SizedBox(height: propHeight(15)), // Adjust as needed
//       SizedBox(
//         height: 190, // Adjust as needed
//         child: ListView.builder(
//           addRepaintBoundaries: false,
//           scrollDirection: Axis.horizontal,
//           itemCount: 6, // Replace with the actual number of items
//           itemBuilder: (BuildContext context, int index) {
//             return Padding(
//               padding: EdgeInsets.only(left: 10, right: 10),
//               child: _buildCard(context, index), //defined below
//             );
//           },
//         ),
//       ),
//     ],
//   ),
// ),
// );
// }