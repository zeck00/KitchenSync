// ignore_for_file: prefer_const_constructors, use_super_parameters, library_private_types_in_public_api, avoid_print

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:kitchensync/screens/appBar.dart';
import 'package:kitchensync/styles/AppColors.dart';
import 'package:kitchensync/styles/AppFonts.dart';
import 'package:kitchensync/screens/size_config.dart';
import 'package:kitchensync/screens/itemsPage.dart';
import '../backend/dataret.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({Key? key}) : super(key: key);

  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  bool _isLoading = true;
  List<Kitchen> kitchens = []; // To store kitchen data
  List<Device> devices = []; // To store device data
  List<Category> categories = []; // To store category data
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate data loading
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    kitchens = await Kitchen.fetchKitchens('assets/data/kitchens.json');
    for (var kitchen in kitchens) {
      await kitchen.loadDevices();
    }

    // Load categories and items
    categories = await Category.loadCategories('assets/data/categories.json');
    List<Item> items = await Item.loadAllItems('assets/data/items.json');
    // Assign items to their categories
    for (var category in categories) {
      category.assignItems(items);
    }
  }

  void simulatePageUpdate() async {
    setState(() => _isLoading = true);
    await Future.delayed(Duration(milliseconds: 1500));
    // Here, you might want to actually reload your data
    // For demonstration, we're just toggling the loading state
    setState(() => _isLoading = false);
    print("Data Reloaded");
  }

  Future<void> _reloadData() async {
    setState(() => _isLoading = true); // Show loading indicator
    await _loadData();
    await Future.delayed(
        Duration(milliseconds: 1500)); // Re-fetch the data + added wait time
    setState(() => _isLoading = false); // Hide loading indicator
    print("Data Reloaded");
  }

  @override
  Widget build(BuildContext context) {
    initSizeConfig(context);
    return Scaffold(
      appBar: CustomAppBar(),
      body: Stack(
        children: [
          // If _isLoading is true, show the loading indicator
          if (_isLoading)
            Center(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  alignment: Alignment.center,
                  color: AppColors.light
                      .withOpacity(0.8), // Semi-transparent overlay
                  child: CircularProgressIndicator(
                    color: AppColors.dark,
                    strokeWidth: 6,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.dark),
                    strokeCap: StrokeCap.round,
                    semanticsLabel: 'Loading',
                  ),
                ),
              ),
            ),
          // Else, show the main content
          if (!_isLoading) _buildKitchenPageView(),
        ],
      ),
    );
  }

  Widget _buildKitchenPageView() {
    return PageView.builder(
      physics: BouncingScrollPhysics(),
      controller: _pageController,
      onPageChanged: (int page) {
        setState(() {});
      },
      itemCount: kitchens.first.devices
          .length, // Assuming you want to display devices of the first kitchen
      itemBuilder: (context, index) {
        final device = kitchens.first.devices[index];
        return buildPage(
          device
              .deviceName, // deviceState is not available in your current model
          device.deviceName,
          'assets/images/001.png', // Adjust imagePath based on your assets or device data
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
                    _reloadData();
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
                  category.categoryName == 'Eggs'
                      ? '${category.getTotalQuantity()} Pcs'
                      : '${category.getTotalQuantity()} KG',
                  style: AppFonts.numbers),
            ],
          ),
        ),
      ),
    );
  }
}
