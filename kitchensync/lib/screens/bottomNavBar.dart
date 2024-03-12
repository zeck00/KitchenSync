// ignore_for_file: prefer_const_constructors

import 'package:floating_navbar/floating_navbar_item.dart';
import 'package:flutter/material.dart';
import 'package:kitchensync/screens/homePage.dart';
import 'package:kitchensync/screens/inventoryPage.dart';
import 'package:kitchensync/screens/size_config.dart';
import 'package:kitchensync/styles/AppColors.dart';
import 'package:floating_navbar/floating_navbar.dart';

class MainLayout extends StatefulWidget {
  @override
  _MainLayoutState createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  // Define your screens here
  final List<Widget> _screens = [
    HomeScreen(),
    InventoryScreen(),
    // Add other screens as needed
  ];

  @override
  Widget build(BuildContext context) {
    initSizeConfig(context);

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Stack(
        children: [
          FloatingNavBar(
            resizeToAvoidBottomInset: true,
            showTitle: false,
            color: AppColors.light,
            //color: Color.fromRGBO(0, 0, 0, 0),
            borderRadius: 90,
            index: _selectedIndex,
            selectedIconColor: AppColors.primary,
            unselectedIconColor: AppColors.blue1,
            items: [
              FloatingNavBarItem(
                icon: ImageIcon(AssetImage('assets/images/Hut.png')),
                useImageIcon: true,
                title: 'home',
                page: HomeScreen(),
              ),
              FloatingNavBarItem(
                icon: ImageIcon(AssetImage('assets/images/Appliance.png')),
                useImageIcon: true,
                title: 'home',
                page: InventoryScreen(),
              ),
              FloatingNavBarItem(
                icon: ImageIcon(AssetImage('assets/images/Hand.png')),
                useImageIcon: true,
                title: 'home',
                page: HomeScreen(),
              ),
              FloatingNavBarItem(
                icon: ImageIcon(AssetImage('assets/images/Setting.png')),
                useImageIcon: true,
                title: 'home',
                page: HomeScreen(),
              ),
            ],
            horizontalPadding: 15,

            hapticFeedback: true,
          ),
        ],
      ),
    );
  }
}
