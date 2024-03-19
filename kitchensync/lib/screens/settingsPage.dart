import 'package:flutter/material.dart';
import 'package:kitchensync/screens/appBar.dart';
import 'package:kitchensync/screens/customDeviceCard.dart';
import 'package:kitchensync/styles/AppColors.dart';
import 'package:kitchensync/styles/AppFonts.dart';

class SettingsScreen extends StatefulWidget {
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
          // The header part with "Settings" text
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text(
              'Settings',
              style: AppFonts.welcomemsg2,
              textAlign: TextAlign.center,
            ),
          ),
          // Device management section
          _buildManageDevicesSection(),
          // Account, Privacy, and About sections
          _buildListItem('Manage Your Account'),
          _buildListItem('Manage Your Privacy'),
          _buildListItem('About KitchenSync'),
          // The "We Listen" section with communication options
          _buildCommunicationOptionsSection(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildManageDevicesSection() {
    // Replace with actual data
    final devices = [
      {'name': 'Refrigerator', 'count': '41'},
      {'name': 'Freezer', 'count': '37'},
      // Add more device data here
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Manage Your Devices', style: AppFonts.servicename),
          SizedBox(height: 10),
          Container(
            height: 100, // Adjust based on your item card height
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: devices.length,
              itemBuilder: (context, index) {
                return CustomDeviceCard(
                  title: devices[index]['name']!,
                  itemCount: devices[index]['count']!,
                  imagePath:
                      'assets/images/device_image.png', // Replace with actual image path
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(String title) {
    return ListTile(
      title: Text(title),
      trailing: Icon(Icons.arrow_forward_ios),
      onTap: () {
        // Handle list item tap
      },
    );
  }

  Widget _buildCommunicationOptionsSection() {
    // Replace with your actual contact methods data
    final contactMethods = [
      {'label': 'Call us', 'icon': Icons.phone},
      {'label': 'Write to us', 'icon': Icons.email},
      // Add more methods here
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('We Listen!', style: AppFonts.cardTitle),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: contactMethods.map((method) {
              return FloatingActionButton(
                heroTag: method['label'],
                child: Icon(method['icon'] as IconData?),
                onPressed: () {
                  // Handle contact method tap
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      // Bottom navigation bar items
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
        // Add more navigation items if needed
      ],
      // Configuration for BottomNavigationBar
    );
  }
}
