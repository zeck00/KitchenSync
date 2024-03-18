// ignore_for_file: prefer_const_constructors, use_super_parameters, library_private_types_in_public_api, unused_field

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:kitchensync/screens/appBar.dart';
import 'package:kitchensync/styles/AppColors.dart';
import 'package:kitchensync/styles/AppFonts.dart';
import 'package:kitchensync/screens/size_config.dart';
import 'package:kitchensync/screens/itemsPage.dart';
import 'dart:convert';
import 'dart:io';

class Kitchen{
  Kitchen({required this.kitchenID, required this.kitchenName, required this.devicesFile});
  final String kitchenID;
  final String kitchenName;
  final String devicesFile;

  factory Kitchen.fromJson(Map<String, dynamic> data) {
    final kitchenID = data['kitchenID']; // dynamic
    final kitchenName = data['kitchenName']; // dynamic
    final devicesFile = data['devicesFile']; // dynamic
    // implicit cast from dynamic to String
    if (kitchenID is String && kitchenName is String && devicesFile is String) {
    return Kitchen(kitchenID: kitchenID, kitchenName: kitchenName, devicesFile: devicesFile);
  } else {
    throw FormatException('Invalid JSON: $data');
  }
  }
}

class Device{
  Device({required this.deviceID, required this.deviceName, required this.categoriesFile});
  final String deviceID;
  final String deviceName;
  final String categoriesFile;

  factory Device.fromJson(Map<String, dynamic> data) {
    final deviceID = data['DeviceID']; // dynamic
    final deviceName = data['DeviceName']; // dynamic
    final categoriesFile = data['categoriesFile']; // dynamic
    // implicit cast from dynamic to String
    if (deviceID is String && deviceName is String && categoriesFile is String) {
    return Device(deviceID: deviceID, deviceName: deviceName, categoriesFile: categoriesFile);
  } else {
    throw FormatException('Invalid JSON: $data');
  }
  }
}

class Category{
  Category({required this.categoryID, required this.categoryName, required this.itemsFile});
  final String categoryID;
  final String categoryName;
  final String itemsFile;

  factory Category.fromJson(Map<String, dynamic> data) {
    final categoryID = data['categoryID']; // dynamic
    final categoryName = data['categoryName']; // dynamic
    final itemsFile = data['itemsFile']; // dynamic
    // implicit cast from dynamic to String
    if (categoryID is String && categoryName is String && itemsFile is String) {
    return Category(categoryID: categoryID, categoryName: categoryName, itemsFile: itemsFile);
  } else {
    throw FormatException('Invalid JSON: $data');
  }
  }
}

class Item{
  Item({this.nfcTagID, this.pDate, this.inDate, this.itemInfo, this.status, this.quantity, 
  this.unit, required this.itemID, required this.itemName, required this.xDate, required this.category});
  final String itemID;
  final String itemName;
  final String? nfcTagID;
  final String? pDate;
  final String xDate;
  final String? inDate;
  final String? itemInfo;
  final String? status;
  final String category;
  final String? quantity;
  final String? unit;

  factory Item.fromJson(Map<String, dynamic> data) {
    final itemID = data['itemID']; // dynamic
    final itemName = data['itemName']; // dynamic
    final xDate = data['xDate']; // dynamic
    final category = data['category']; // dynamic

    // implicit cast from dynamic to String
    if (itemID is String && itemName is String && xDate is String && category is String) {
    return Item(itemID: itemID, itemName: itemName, xDate: xDate, category: category);
  } else {
    throw FormatException('Invalid JSON: $data');
  }
  }
}

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({Key? key}) : super(key: key);

  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

Future<Map<String, dynamic>> readJsonFile(String filePath) async {
  final file = File(filePath);
  final contents = await file.readAsString();
  return json.decode(contents);
}

class _InventoryScreenState extends State<InventoryScreen> {
  bool isDarkMode = false;
  int _currentPage = 0;
  final PageController _pageController = PageController();
  bool _isLoading = false; // Add a new state variable for loading state
  void simulatePageUpdate() async {
    setState(() {
      _isLoading = true; // Show loading overlay
    });

    // Simulate network request or processing delay
    await Future.delayed(Duration(milliseconds: 1500));

    setState(() {
      _isLoading = false; // Hide loading overlay
    });
  }

  @override
  Widget build(BuildContext context) {
    initSizeConfig(context);
    return Scaffold(
      appBar: CustomAppBar(),
      body: Stack(
        children: [
          PageView(
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
                  'assets/images/RefgOpen1.png', '001'),
              buildPage('SavvyStow 2.0 State 1', 'SavvyStow 2.0',
                  'assets/images/RefgOpen1.png', '002'),
              buildPage('Antartica 1.2 State 1', 'Antartica 1.2',
                  'assets/images/RefgOpen2.png', '003'),
              buildPage('WasteWizard 1.0 State 1', 'WasteWizard 1.0',
                  'assets/images/WasteWizard.png', '004'),
              // Add more pages as needed
            ],
          ),
          if (_isLoading) // Conditionally display the loading overlay
            Container(
              decoration: BoxDecoration(
                  // Semi-transparent overlay
                  ),
              // Semi-transparent overlay
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.dark,
                    strokeWidth: 6,
                    semanticsLabel: 'wait',
                    semanticsValue: 'wait',
                    strokeCap: StrokeCap.round,
                    strokeAlign: 1,
                  ), // Loading indicator
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildPage(String deviceState, String deviceName, String imagePath,
      String deviceId) {
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
                GestureDetector(
                  child: Image.asset(
                    'assets/images/Synchronize.png',
                    color: AppColors.dark,
                    width: 35,
                    height: 35,
                  ),
                  onTap: () {
                    simulatePageUpdate(); // Trigger loading overlay and delay
                  },
                ),
              ],
            ),
            SizedBox(height: propHeight(10)),
            Image.asset(
              imagePath,
              width: propWidth(420),
              height: propHeight(370),
            ),
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
                GestureDetector(
                  child: Image.asset(
                    'assets/images/Next.png',
                    color: AppColors.dark,
                    width: 35,
                    height: 35,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ItemsScreen(
                            deviceId:
                                deviceId), // Replace '001' with your actual device ID
                      ),
                    );
                  },
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