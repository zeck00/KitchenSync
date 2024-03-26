// ignore_for_file: library_private_types_in_public_api, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:kitchensync/screens/appBar.dart';
import 'package:kitchensync/styles/AppColors.dart';
import 'package:kitchensync/styles/AppFonts.dart';
import 'package:kitchensync/styles/size_config.dart';
import 'package:kitchensync/screens/itemsPage.dart';
import '../backend/dataret.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  List<Kitchen> kitchens = []; // To store kitchen data
  List<Device> devices = []; // To store device data
  List<Category> categories = []; // To store category data
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _loadData().then((_) {
      setState(() {
        // Update the state to reflect the loaded data
      });
    });
  }

  Future<void> _loadData() async {
    try {
      kitchens = await Kitchen.fetchKitchens('kitchens.json');
      for (var kitchen in kitchens) {
        await kitchen.loadDevices();
        for (var device in kitchen.devices) {
          device.categories =
              await device.loadCategories(device.categoriesFile);
        }
      }
      categories = await Category.loadCategories('categories.json');
      final itemsLoaded = await Item.loadAllItems('items.json');
      for (var category in categories) {
        category.assignItems(itemsLoaded);
      }
    } catch (e) {
      rethrow;
    }
  }

  void simulatePageUpdate() async {
    await Future.delayed(Duration(milliseconds: 1500));
    _reloadData();
    // For demonstration, we're just toggling the loading state
  }

  Future<void> _reloadData() async {
// Show loading indicator
    await _loadData();
    await Future.delayed(
        Duration(milliseconds: 1500)); // Re-fetch the data + added wait time
// Hide loading indicator
  }

  @override
  Widget build(BuildContext context) {
    initSizeConfig(context);
    return Scaffold(
      appBar: CustomAppBar(),
      body: FutureBuilder(
        future: _loadData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error Contacting Server'),
            );
          }
          return _buildKitchenPageView();
        },
      ),
    );
  }

  Widget _buildKitchenPageView() {
    if (kitchens.isEmpty || kitchens.first.devices.isEmpty) {
      return Center(child: Text("No devices available"));
    }

    return PageView.builder(
      controller: _pageController, // Ensure the controller is used
      physics: BouncingScrollPhysics(), // This enables the swipe effect
      itemCount: kitchens.first.devices.length, // Confirm this is > 1
      itemBuilder: (context, index) {
        final device = kitchens.first.devices[index];
        return buildPage(
          device.deviceName,
          device.deviceName,
          'assets/images/${device.imagePath}',
          device.deviceID,
        );
      },
    );
  }

  Widget buildPage(String deviceState, String deviceName, String imagePath,
      String deviceId) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
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
                    simulatePageUpdate();

                    // Trigger loading overlay and delay
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
                          deviceId: deviceId,
                          deviceName: deviceName,
                        ),
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
                clipBehavior: Clip.hardEdge,
                physics: BouncingScrollPhysics(),
                addRepaintBoundaries: false,
                scrollDirection: Axis.horizontal,
                itemCount:
                    categories.length, // Use the length of categories list
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: EdgeInsets.only(left: 0, right: 10),
                    child: _buildCard(
                        context, categories[index]), // Pass the Category object
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, Category category) {
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
                category.catIcon, // Replace with your category icon path
                width: propWidth(50),
                height: propHeight(50),
              ),
              Text(category.categoryName, style: AppFonts.cardTitle),
              SizedBox(height: propHeight(10)),
              Text(
                  getUnitForCategory(
                      category.categoryName, category.getTotalQuantity()),
                  style: AppFonts.numbers),
            ],
          ),
        ),
      ),
    );
  }
}

// class UnitInfo {
//   final String unit;
//   final double conversionFactor; // Useful for unit conversion if needed

//   UnitInfo({required this.unit, this.conversionFactor = 1.0});
// }

// class CategoryUnits {
//   static final Map<String, UnitInfo> _categoryToUnit = {
//     'Dairy': UnitInfo(unit: 'mL'),
//     'Poultry': UnitInfo(unit: 'g'),
//     'Produce': UnitInfo(unit: 'g'),
//     'Eggs': UnitInfo(unit: 'Pcs'),
//     'SeaFood': UnitInfo(unit: 'g'),
//     'Meat': UnitInfo(unit: 'g'),
//     'Pantry': UnitInfo(unit: 'g'),
//     // Add more categories as needed
//   };

//   static String getUnitForCategory(String categoryName, double quantity) {
//     final unitInfo = _categoryToUnit[categoryName];
//     if (unitInfo != null) {
//       return '$quantity ${unitInfo.unit}';
//     } else {
//       // Implement logic for determining a default unit, if desired
//       // For example, check if quantity suggests a liquid or solid, etc.
//       return '$quantity Units'; // A generic fallback
//     }
//   }

//   // Example method for adding a new category and its unit dynamically
//   static void addCategoryUnit(String category, UnitInfo unitInfo) {
//     _categoryToUnit[category] = unitInfo;
//   }
// }

String getUnitForCategory(String categoryName, double quantity) {
  switch (categoryName) {
    case 'Dairy':
      return '$quantity mL'; // Assuming dairy is measured in liters
    case 'Poultry':
      return '$quantity g'; // Assuming poultry is measured in kilograms
    case 'Produce':
      return '$quantity g'; // Assuming produce is measured in kilograms
    case 'Eggs':
      return '$quantity Pcs'; // Eggs are counted in pieces
    case 'SeaFood':
      return '$quantity g'; // Seafood is assumed to be measured in kilograms
    case 'Meat':
      return '$quantity g'; // Meat is also measured in grams
    case 'Pantry':
      return '$quantity g'; // Pantry is also measured in grams
    // Add more cases as needed for other categories
    default:
      return '$quantity Units'; // A generic fallback
  }
}
