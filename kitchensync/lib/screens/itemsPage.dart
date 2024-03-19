// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:kitchensync/screens/customListItem.dart';
import 'package:kitchensync/screens/homePage.dart';
import 'package:kitchensync/styles/AppColors.dart';
import 'package:kitchensync/styles/AppFonts.dart';
import 'package:kitchensync/screens/size_config.dart';
import 'dart:ui' as ui;

// Your item structure here is simplified for demonstration
final List<Map<String, dynamic>> categories = [
  {
    "category": "Poultry",
    "totalWeight": "3.02 KG",
    "iconPath":
        "assets/images/Thanksgiving.png", // Replace with actual icon path
    "items": [
      {
        "itemName": "Whole Chicken",
        "weight": "1.02 KG",
        "isFresh": false, // Example of an item that's not fresh
      },
      {
        "itemName": "Minced Chicken",
        "weight": "0.45 KG",
        "isFresh": true,
      },
      {
        "itemName": "Chicken Thighs",
        "weight": "0.45 KG",
        "isFresh": false,
      }
      // Add other items here...
    ],
  },
  // Add other categories here...
];

class ItemsScreen extends StatelessWidget {
  final String deviceId; // The device ID passed to this screen
  final String deviceName =
      "Antartica 1.3"; // Replace with actual device name if needed
  void _showPopup(BuildContext context) {
    Navigator.of(context).push(_PopupRoute());
  }

  ItemsScreen({Key? key, required this.deviceId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    initSizeConfig(context); // Initialize the size configuration

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(
          left: propWidth(25),
          right: propWidth(25),
          top: propHeight(5),
        ),
        child: Column(
          children: [
            SizedBox(height: propHeight(40)), // Add spacing
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Image.asset(
                    'assets/images/Prvs.png',
                    width: propWidth(30),
                    height: propHeight(30),
                  ),
                ),
                Expanded(child: Container()),
                Text(
                  deviceName,
                  style: AppFonts.welcomemsg1,
                ),
                Expanded(child: Container()),
                GestureDetector(
                  onTap: () => _showPopup(context),
                  child: Image.asset(
                    'assets/images/Filter.png',
                    width: propWidth(30),
                    height: propHeight(30),
                  ),
                ),
              ],
            ),

            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(propWidth(17)),
                    ),
                    color: AppColors.primary,
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        unselectedWidgetColor: AppColors.light,
                      ),
                      child: CustomExpansionTile(category: category),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomExpansionTile extends StatefulWidget {
  final Map<String, dynamic> category;

  CustomExpansionTile({Key? key, required this.category}) : super(key: key);

  @override
  _CustomExpansionTileState createState() => _CustomExpansionTileState();
}

class _CustomExpansionTileState extends State<CustomExpansionTile> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final category = widget.category;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(propWidth(17)),
      ),
      color: isExpanded
          ? AppColors.primary
          : AppColors.primary, // Change the background color when expanded
      child: Theme(
        data: Theme.of(context).copyWith(
          unselectedWidgetColor: AppColors.light, // Set icon color here
        ),
        child: ExpansionTile(
          onExpansionChanged: (bool expanded) {
            setState(() {
              isExpanded = expanded;
            });
          },
          leading: Image.asset(
            category['iconPath'],
            width: propWidth(36),
            height: propHeight(36),
          ),
          title: Row(
            children: <Widget>[
              Text(
                category['category'],
                style: AppFonts.cardTitle,
              ),
              SizedBox(width: propWidth(13)),
              Text(
                category['totalWeight'],
                style: AppFonts.numbers,
              ),
              Spacer(), // Use Spacer for automatically calculated remaining space
              GestureDetector(
                  child: Image.asset(
                    'assets/images/CookBook.png',
                    width: propWidth(30),
                    height: propHeight(30),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              HomeScreen()), // Replace HomeScreen() with the recpies generation page
                    );
                  }),
            ],
          ),
          trailing: Image.asset(
            isExpanded ? 'assets/images/Minus.png' : 'assets/images/Down.png',
            width: propWidth(30),
            height: propHeight(30),
          ),
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.grey2, // Color for the expanded area content
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(propWidth(17)),
                  bottomRight: Radius.circular(propWidth(17)),
                ),
              ),
              child: Column(
                children: category['items'].map<Widget>((item) {
                  return ListTile(
                    title: Row(
                      children: [
                        Text(
                          item['itemName'],
                          style: AppFonts.servicename,
                        ),
                        if (!item['isFresh']) // Show warning icon if not fresh
                          Padding(
                            padding: EdgeInsets.only(left: propWidth(8)),
                            child: Image.asset(
                              'assets/images/Warning.png',
                              width: propWidth(24),
                              height: propHeight(24),
                            ),
                          ),
                      ],
                    ),
                    trailing: Text(
                      item['weight'],
                      style: AppFonts.numbers1,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Overrides [Size.preferredSize] to set the AppBar height.
///
/// The _PopupRoute class extends [PopupRoute] to customize the popup
/// for selecting a kitchen. It sets properties like barrier color,
/// dismissibility, etc. and builds the popup UI.
@override
Size get preferredSize => Size.fromHeight(propHeight(107.5));

class _PopupRoute extends PopupRoute {
  @override
  Color get barrierColor => AppColors.greySub.withOpacity(0.2);

  @override
  bool get barrierDismissible => true;

  @override
  String get barrierLabel => 'Select Kitchen';

  @override
  Duration get transitionDuration => Duration(milliseconds: 250);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return BackdropFilter(
      filter: ui.ImageFilter.blur(
        sigmaX: 12.0,
        sigmaY: 12.0,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Center(
          child: ClipRect(
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  Center(
                      child: Text(
                    "Choose Your Kitchen",
                    style: AppFonts.choose1,
                  )),
                  SizedBox(height: propHeight(25)),
                  GestureDetector(
                    child: CustomListItem(
                        width: 100,
                        height: 60,
                        mainTxt: 'Ziad\'s Kitchen 1',
                        numberTxt: '4',
                        subTxt: 'Devices',
                        imagePath: 'assets/images/KitchenRoom.png'),
                    onTap: () {},
                  ),
                  SizedBox(height: propHeight(15)),
                  GestureDetector(
                    child: CustomListItem(
                        width: 100,
                        height: 60,
                        mainTxt: 'Rama\'s Kitchen',
                        numberTxt: '10',
                        subTxt: 'Devices',
                        imagePath: 'assets/images/KitchenRoom1.png'),
                    onTap: () {},
                  ),
                  SizedBox(height: propHeight(15)),
                  GestureDetector(
                    child: CustomListItem(
                        width: 100,
                        height: 60,
                        mainTxt: 'Ziad\'s Kitchen 2',
                        numberTxt: '1',
                        subTxt: 'Device',
                        imagePath: 'assets/images/KitchenRoom1.png'),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
