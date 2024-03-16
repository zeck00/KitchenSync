import 'package:flutter/material.dart';
import 'package:kitchensync/styles/AppColors.dart';
import 'package:kitchensync/styles/AppFonts.dart';
import 'package:kitchensync/screens/appBar.dart';
import 'package:kitchensync/screens/size_config.dart';

class DonateScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    initSizeConfig(context);

    return Scaffold(
      appBar: CustomAppBar(), // Your custom app bar
      body: Padding(
        padding: EdgeInsets.only(
          left: propWidth(25),
          right: propWidth(25),
        ),
        child: Column(
          children: [
            SizedBox(height: propHeight(20)),
            Text(
              "Let's Donate",
              style: TextStyle(
                fontSize: propWidth(24), // Adjust the font size as needed
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            Image.asset(
              'assets/images/kitchenMain.png',
              filterQuality:
                  FilterQuality.high, // Replace with the actual image path
            ),
            SizedBox(height: propHeight(20)),
            Text(
              'Nearest Food Banks',
              style: AppFonts.subtitle, // Style as per your AppFonts
            ),
            // This can be a horizontal list view or just a row of widgets
            _buildNearestFoodBanks(),
            SizedBox(height: propHeight(20)),
            Text(
              'Schedule a Donation',
              style: AppFonts.subtitle, // Style as per your AppFonts
            ),
            // This would typically be a list of donation times
            _buildDonationSchedule(),
          ],
        ),
      ),
    );
  }

  Widget _buildNearestFoodBanks() {
    // Mock data, please replace with actual data
    var nearestFoodBanks = [
      {'name': 'UAE Food Bank', 'location': 'Dubai, UAE'},
      // Add more banks as needed
    ];

    return Container(
      height: propHeight(100), // Adjust as needed
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: nearestFoodBanks.length,
        itemBuilder: (BuildContext context, int index) {
          return _buildFoodBankCard(nearestFoodBanks[index]);
        },
      ),
    );
  }

  Widget _buildFoodBankCard(Map<String, String> foodBank) {
    return Card(
      // Style the card as needed
      child: Padding(
        padding: EdgeInsets.all(propWidth(8)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(foodBank['name']!, style: AppFonts.cardTitle),
            Text(foodBank['location']!, style: AppFonts.servicename),
            // You can add an icon or image here
          ],
        ),
      ),
    );
  }

  Widget _buildDonationSchedule() {
    // Mock data, please replace with actual data
    var donationSchedule = [
      {'date': '20th Mar, 2024', 'items': '7 Donables'},
      // Add more schedules as needed
    ];

    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: donationSchedule.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          title:
              Text(donationSchedule[index]['date']!, style: AppFonts.cardTitle),
          subtitle: Text(donationSchedule[index]['items']!,
              style: AppFonts.cardTitle),
          trailing: Icon(Icons.navigate_next), // Adjust icon as needed
        );
      },
    );
  }
}
