// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api, prefer_final_fields, file_names
import 'package:flutter/material.dart';
import 'package:kitchensync/screens/chatPage.dart';
import 'package:kitchensync/screens/donatePage.dart';
import 'package:kitchensync/screens/homePage.dart';
import 'package:kitchensync/screens/inventoryPage.dart';
import 'package:kitchensync/screens/settingsPage.dart';
import 'package:kitchensync/styles/size_config.dart';
import 'package:kitchensync/styles/AppColors.dart';
import 'package:kitchensync/screens/customFloatyBar.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  _MainLayoutState createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    InventoryScreen(),
    DonateScreen(),
    SettingsScreen(),
    ChatScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

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
          FloatyBar(
            resizeToAvoidBottomInset: true,
            showTitle: false,
            color: AppColors.light,
            borderRadius: 90,
            index: _selectedIndex,
            horizontalPadding: 15,
            hapticFeedback: true,
            items: [
              CustomFloatyBarItem(
                unselectedIcon: ImageIcon(AssetImage('assets/images/Hut.png'),
                    color: AppColors.primary),
                selectedIcon: ImageIcon(AssetImage('assets/images/HutS.png'),
                    color: AppColors.greySub),
                title: 'home',
                page: HomeScreen(),
              ),
              CustomFloatyBarItem(
                unselectedIcon: ImageIcon(
                    AssetImage('assets/images/Appliance.png'),
                    color: AppColors.primary),
                selectedIcon: ImageIcon(
                    AssetImage('assets/images/ApplianceS.png'),
                    color: AppColors.greySub),
                title: 'appliances',
                page: InventoryScreen(),
              ),
              CustomFloatyBarItem(
                unselectedIcon: ImageIcon(AssetImage('assets/images/Bot.png'),
                    color: AppColors.primary),
                selectedIcon: ImageIcon(AssetImage('assets/images/BotS.png'),
                    color: AppColors.greySub),
                title: 'bot',
                page: ChatScreen(),
              ),
              CustomFloatyBarItem(
                unselectedIcon: ImageIcon(AssetImage('assets/images/Hand.png'),
                    color: AppColors.primary),
                selectedIcon: ImageIcon(AssetImage('assets/images/HandS.png'),
                    color: AppColors.greySub),
                title: 'donate',
                page: DonateScreen(),
              ),
              CustomFloatyBarItem(
                unselectedIcon: ImageIcon(
                    AssetImage('assets/images/Settings.png'),
                    color: AppColors.primary),
                selectedIcon: ImageIcon(AssetImage('assets/images/Setting.png'),
                    color: AppColors.greySub),
                title: 'settings',
                page: SettingsScreen(),
              ),
            ],
            onItemSelected: _onItemTapped, // Ensure the index is updated
          ),
        ],
      ),
    );
  }
}
