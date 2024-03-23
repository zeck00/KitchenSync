// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, library_private_types_in_public_api, file_names, unused_field, unused_element

import 'package:flutter/material.dart';
import 'package:kitchensync/screens/addItemPage.dart';
import 'package:kitchensync/screens/customListItem.dart';
import 'package:kitchensync/screens/homePage.dart';
import 'package:kitchensync/styles/AppColors.dart';
import 'package:kitchensync/styles/AppFonts.dart';
import 'package:kitchensync/screens/size_config.dart';
import 'dart:ui' as ui;
import '../backend/dataret.dart';

class ItemsScreen extends StatefulWidget {
  final String deviceId; // The device ID passed to this screen
  final String deviceName;

  const ItemsScreen({
    super.key,
    required this.deviceId,
    required this.deviceName,
  });

  @override
  _ItemsScreenState createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  bool _isLoading = true;
  List<Category> categories = [];

  void _showPopup(BuildContext context) {
    Navigator.of(context).push(_PopupRoute());
  }

  @override
  void initState() {
    super.initState();
    _loadCategoriesAndItems();
  }

  Future<void> _loadCategoriesAndItems() async {
    final allItems = await Item.loadAllItems('assets/data/items.json');
    final loadedCategories =
        await Category.loadCategories('assets/data/categories.json');

    for (var category in loadedCategories) {
      category.assignItems(allItems);
    }

    setState(() {
      categories = loadedCategories;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    initSizeConfig(context);

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
                  'deviceName',
                  style: AppFonts.welcomemsg1,
                ),
                Expanded(child: Container()),
                GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddItemPage()),
                      );
                    },
                    child: Icon(
                      Icons.add_circle_outline_rounded,
                      color: AppColors.dark,
                      size: propWidth(30),
                    )),
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
  final Category category;

  const CustomExpansionTile({super.key, required this.category});

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
            category.catIcon,
            width: propWidth(36),
            height: propHeight(36),
          ),
          title: Row(
            children: <Widget>[
              Text(
                category.categoryName,
                style: AppFonts.cardTitle,
              ),
              SizedBox(width: propWidth(13)),
              Text(
                '${category.getTotalQuantity()}',
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
                children: category.items.map<Widget>((item) {
                  return ListTile(
                    title: Row(
                      children: [
                        Text(
                          item.itemName,
                          style: AppFonts.servicename,
                        ),
                        if (item.status !=
                            'fresh') // Show warning icon if not fresh
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
                      '${item.quantity}',
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
