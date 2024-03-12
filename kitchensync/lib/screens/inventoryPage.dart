import 'package:flutter/material.dart';
import 'package:kitchensync/screens/appBar.dart';
import 'package:kitchensync/styles/AppFonts.dart'; // Assuming this is where your text styles are defined
// Import other necessary custom widgets and utilities as needed

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({Key? key}) : super(key: key);

  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  bool isDarkMode = false;
  // Add any other state variables you might need

  @override
  Widget build(BuildContext context) {
    // Initialize SizeConfig if you use it for responsive sizing
    return Scaffold(
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16), // Adjust as needed
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Ziad\'s Refrigerator',
                style: AppFonts.subtitle1, // Replace with your actual style
              ),
            ),
            SizedBox(height: 16), // Adjust as needed
            Center(
              child: Image.asset(
                'assets/images/RefgOpen.png', // Replace with your image path
                // Set your width and height accordingly
              ),
            ),
            SizedBox(height: 16), // Adjust as needed
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'What’s In Antarctica 1.3?',
                style: AppFonts.subtitle, // Replace with your actual style
              ),
            ),
            SizedBox(height: 16), // Adjust as needed
            Container(
              height: 200, // Adjust based on your card height
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 10, // Replace with the actual number of items
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding:
                        EdgeInsets.only(left: index == 0 ? 16 : 8, right: 8),
                    child: _buildCard(
                        context, index), // We will define this method next
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, int index) {
    // Replace with your actual data model
    final item = {
      'title': 'Item $index',
      'quantity': 'x${index + 1}',
      'iconPath': 'assets/images/Milk.png', // Replace with your item icon path
    };

    return Container(
      width: 160, // Adjust as needed
      child: Card(
        elevation: 4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              item['iconPath']!,
              width: 48, // Adjust as needed
              height: 48, // Adjust as needed
            ),
            SizedBox(height: 8), // Adjust as needed
            Text(item['title']!,
                style: AppFonts.cardTitle), // Use your custom style
            Text(item['quantity']!,
                style: AppFonts.cardTitle), // Use your custom style
          ],
        ),
      ),
    );
  }
}
