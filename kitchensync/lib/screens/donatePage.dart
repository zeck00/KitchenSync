// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_super_parameters, file_names, no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:kitchensync/backend/dataret.dart';
import 'package:kitchensync/screens/mapPage.dart';
import 'package:kitchensync/styles/AppColors.dart';
import 'package:kitchensync/styles/AppFonts.dart';
import 'package:kitchensync/screens/appBar.dart';
import 'package:kitchensync/styles/size_config.dart';
import 'package:quickalert/quickalert.dart';
import 'dart:ui' as ui;
import 'package:url_launcher/url_launcher_string.dart';

class DonateScreen extends StatelessWidget {
  const DonateScreen({super.key});

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
            Row(
              children: [
                Text(
                  'Let\'s ',
                  style: AppFonts.welcomemsg2,
                ),
                Text(
                  'Donate',
                  style: AppFonts.welcomemsg1,
                ),
                Expanded(child: Container()),
              ],
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  'assets/images/kitchenMain1.png',
                ),
                // Positioned(
                //   bottom: propHeight(80),
                //   right: propWidth(75),
                //   child: GestureDetector(
                //       child: Image.asset(
                //     'assets/images/Items.png',
                //     width: propWidth(110),
                //     height: propHeight(105),
                //   )),
                // ),
                // Positioned(
                //   top: propHeight(40),
                //   left: propWidth(80),
                //   child: GestureDetector(
                //       child: Image.asset(
                //     'assets/images/Items 1.png',
                //     width: propWidth(125),
                //     height: propHeight(90),
                //   )),
                // ),
              ],
            ),
            SizedBox(height: propHeight(20)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Nearest Food Banks',
                  style: AppFonts.servicename,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MapPage()),
                    );
                  },
                  child: Image.asset('assets/images/Next.png',
                      color: AppColors.dark,
                      height: propHeight(30),
                      width: propWidth(30)),
                ),
              ],
            ),

            SizedBox(
              height: propHeight(6),
            ),
            // This would typically be a list of nearest food banks
            _buildNearestFoodBanks(),
            SizedBox(height: propHeight(20)),
            Row(
              children: [
                Text(
                  'Schedule a Donation',
                  style: AppFonts.servicename,
                ),
              ],
            ),
            // This would typically be a list of donation times
            _buildDonationSchedule(),
          ],
        ),
      ),
    );
  }

  Widget _buildNearestFoodBanks() {
    return FutureBuilder<List<FoodBank>>(
      future: FoodBank.loadNearestFoodBanks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return Center(child: Text('No food banks found.'));
        } else {
          var nearestFoodBanks = snapshot.data!;
          return SizedBox(
            height: propHeight(55),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.hardEdge,
              physics: BouncingScrollPhysics(),
              itemCount: nearestFoodBanks.length,
              itemBuilder: (BuildContext context, int index) {
                return _buildFoodBankCard(nearestFoodBanks[index]);
              },
            ),
          );
        }
      },
    );
  }

  Widget _buildFoodBankCard(FoodBank foodBank) {
    return Row(
      children: [
        Container(
          width: propWidth(165),
          height: propHeight(55),
          padding: EdgeInsets.only(left: propWidth(10), right: propWidth(10)),
          decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(propWidth(17))),
          child: InkWell(
            onTap: () => _launchURL(foodBank.link), // Open the link when tapped
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/images/Nav.png',
                    width: propWidth(25), height: propHeight(25)),
                SizedBox(width: propWidth(5)), // Space between icon and text
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(foodBank.name, style: AppFonts.locCard),
                    Text(foodBank.location, style: AppFonts.locSub),
                  ],
                )
              ],
            ),
          ),
        ),
        SizedBox(width: propWidth(10))
      ],
    );
  }

  void _launchURL(String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

Widget _buildDonationSchedule() {
  // Mock data, please replace with actual data
  var donationSchedule = [
    {'date': '1st June, 2024', 'items': '5'},
    {'date': '2nd June, 2024', 'items': '7'},
    {'date': '15th June, 2024', 'items': '3'},
    {'date': '18th June, 2024', 'items': '1'},
    {'date': '30th June, 2024', 'items': '2'},
    {'date': '7th July, 2024', 'items': '4'},
    {'date': '10th July, 2024', 'items': '3'},
    {'date': '14th July, 2024', 'items': '1'},
  ];

  return SizedBox(
    width: double.infinity,
    height: propHeight(280),
    child: SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: ListView.builder(
        physics: BouncingScrollPhysics(),
        shrinkWrap: true,
        itemCount: donationSchedule.length,
        itemBuilder: (BuildContext context, int index) {
          return DonationTile(
            date: donationSchedule[index]['date']!,
            itemsCount: donationSchedule[index]['items']!,
            onTap: () {
              // Handle the tap event
            },
          );
        },
      ),
    ),
  );
}

class DonationTile extends StatelessWidget {
  final String date;
  final String itemsCount;
  final VoidCallback onTap;

  const DonationTile({
    Key? key,
    required this.date,
    required this.itemsCount,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    initSizeConfig(context); // Initialize size configuration
    void _showPopup(BuildContext context) {
      Navigator.of(context).push(_PopupRoute());
    }

    return GestureDetector(
      onTap: () => _showPopup(context),
      child: Column(
        children: [
          Container(
            width: propWidth(380),
            height: propHeight(60),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(17),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: propWidth(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    date,
                    style: AppFonts.cardTitle,
                  ),
                  Row(
                    children: [
                      Text(
                        itemsCount,
                        style: AppFonts.cntrstText1,
                      ),
                      Text(
                        ' Donables',
                        style: AppFonts.cntrstText2,
                      ),
                    ],
                  ),
                  Image.asset('assets/images/Schedule.png',
                      width: propWidth(26), height: propHeight(26))
                ],
              ),
            ),
          ),
          SizedBox(
            height: propHeight(10),
          )
        ],
      ),
    );
  }
}

class _PopupRoute extends PopupRoute {
  @override
  Color get barrierColor => AppColors.greySub.withOpacity(0.2);

  @override
  bool get barrierDismissible => true;

  @override
  String get barrierLabel => 'Confirm Action';

  @override
  Duration get transitionDuration => Duration(milliseconds: 250);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return BackdropFilter(
      filter: ui.ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
      child: Material(
        type: MaterialType.transparency,
        child: Center(
          child: ClipRect(
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Center(
                      child: Text("Confirm Scheduling?",
                          style: AppFonts.welcomemsg2)),
                  SizedBox(height: 20),
                  InkWell(
                    onTap: () async {
                      // Close this confirmation dialog
                      Navigator.of(context).pop();
                      // Show the success alert
                      await QuickAlert.show(
                        context: context,
                        type: QuickAlertType.success,
                        title: 'Success',
                        text:
                            'Donation Scheduled! The pickup team should contact you soon.',
                        confirmBtnText: 'Ok',
                        confirmBtnColor: AppColors.primary,
                      );
                    },
                    child: Container(
                      width: 160,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          'Confirm',
                          style: AppFonts.cntrstText,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
