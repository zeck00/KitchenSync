// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, library_private_types_in_public_api, unused_import, file_names, sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:kitchensync/screens/appBar.dart';
import 'package:kitchensync/screens/customDeviceCard.dart';
import 'package:kitchensync/styles/AppColors.dart';
import 'package:kitchensync/styles/AppFonts.dart';
import '../styles/size_config.dart';
import '../backend/dataret.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key}); // Use Key? key instead of super.key

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Kitchen> kitchens = []; // Define kitchens here within the state
  bool isDarkMode = false;
  ThemeMode _themeMode = ThemeMode.system; // Default theme
  @override
  void initState() {
    super.initState();
    loadKitchensAndDevices();
  }

  Future<void> loadKitchensAndDevices() async {
    try {
      // Fetch kitchens
      List<Kitchen> kitchensLoaded =
          await Kitchen.fetchKitchens('kitchens.json');

      // For each kitchen, load devices, categories, and items
      for (var kitchen in kitchensLoaded) {
        for (var device in kitchen.devices) {
          // Assuming loadCategoriesAndItems() is an async method in the Device class
          await device.loadCategoriesAndItems();
        }
      }

      // Once all data is loaded, update the state
      setState(() {
        kitchens = kitchensLoaded;
      });
    } catch (error) {
      print('An error occurred while loading kitchens and devices: $error');
      // Handle error state if necessary
    }
  }

  Future<Kitchen> loadKitchen() async {
    final data =
        await loadJson('kitchen_001.json'); // Ensure this returns a valid JSON
    return Kitchen.fromJson(data); // Make sure this maps the JSON correctly
  }

  void _toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  String getGreetingMessage() {
    var hour = DateTime.now().hour; // Gets the current hour
    if (hour < 12) {
      return 'Good Morning, Anything on your mind for breakfast?';
    } else if (hour < 17) {
      return 'Good Afternoon, What\'s for lunch today?';
    } else {
      return 'Good Evening, Thinking about something for dinner?';
    }
  }

  @override
  Widget build(BuildContext context) {
    initSizeConfig(context);
    return Scaffold(
      appBar: CustomAppBar(),
      body: Padding(
        padding: EdgeInsets.only(
          left: 25.0,
          right: 25,
          top: 5.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(children: [
              Positioned(
                top: propHeight(41),
                child: Text(getGreetingMessage(), style: AppFonts.minittles),
              ),
              Row(
                children: [
                  Text(
                    'Hi, ',
                    style: AppFonts.welcomemsg2,
                  ),
                  Text(
                    'Ziad',
                    style: AppFonts.welcomemsg1,
                  ),
                ],
              ),
            ]),
            Stack(
              alignment: Alignment.center,
              children: [
                isDarkMode
                    ? Image.asset(
                        'assets/images/kitchenDark.png',
                        width: propWidth(460),
                        height: propHeight(460),
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        'assets/images/kitchenLight.png',
                        width: propWidth(460),
                        height: propHeight(460),
                        fit: BoxFit.cover,
                      ),
                Positioned(
                  top: propHeight(20),
                  right: propWidth(25),
                  child: GestureDetector(
                    child: isDarkMode
                        ? Icon(Icons.light, color: AppColors.dark, size: 35)
                        : Icon(Icons.dark_mode_rounded,
                            color: AppColors.dark, size: 35),
                    onTap: () {
                      _toggleTheme();
                    },
                  ),
                ),
                Positioned(
                  top: propHeight(90),
                  right: propWidth(75),
                  child: GestureDetector(
                      child: Image.asset(
                    'assets/images/Items.png',
                    width: propWidth(110),
                    height: propHeight(105),
                  )),
                ),
                Positioned(
                  top: propHeight(135),
                  left: propWidth(120),
                  child: GestureDetector(
                      child: Image.asset(
                    'assets/images/Items 1.png',
                    width: propWidth(125),
                    height: propHeight(90),
                  )),
                ),
              ],
            ),
            SizedBox(height: propHeight(10)),
            Container(
              height: propHeight(230),
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                clipBehavior: Clip.hardEdge,
                scrollDirection: Axis.horizontal,
                itemCount: kitchens.length,
                itemBuilder: (context, index) {
                  final kitchen = kitchens[index];
                  return Row(
                    children: kitchen.devices.map((device) {
                      String itemCountText =
                          device.getTotalItemCount().toString();
                      return FutureBuilder<void>(
                        future: device
                            .loadCategoriesAndItems(), // Ensure this is the correct method name
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            // Data loading is complete, display the itemCount
                            return CustomDeviceCard(
                              title: device.deviceName,
                              itemCount: itemCountText,
                              imagePath: 'assets/images/${device.imagePath}',
                            );
                          } else {
                            // Data loading in progress or encountered an error
                            return Text('          ');
                          }
                        },
                      );
                    }).toList(),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

//not working future loading logic !! 
// use with hazard !!
//             FutureBuilder<Kitchen>(
//               future: _kitchenFuture,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return Center(child: CircularProgressIndicator());
//                 } else if (snapshot.hasError) {
//                   return Center(
//                       child: Text("Error loading data: ${snapshot.error}"));
//                 } else if (snapshot.hasData && snapshot.data != null) {
//                   // Ensure devices is not null and is a list
//                   final devices = snapshot.data!.devices;
//                   if (devices.isEmpty) {
//                     return Center(child: Text("No devices found"));
//                   }
//                   return SingleChildScrollView(
//                     clipBehavior: Clip.none,
//                     scrollDirection: Axis.horizontal,
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: devices.map((device) {
//                         return CustomDeviceCard(
//                           title: device.deviceName,
//                           itemCount: device.categories
//                               .fold<int>(
//                                   0,
//                                   (previousValue, category) =>
//                                       previousValue + category.items.length)
//                               .toString(),
//                           imagePath: 'assets/images/${device.imagePath}',
//                         );
//                       }).toList(),
//                     ),
//                   );
//                 } else {
//                   return Center(
//                       child: Column(
//                     children: [
//                       Icon(
//                         Icons.cloud_off_rounded,
//                         size: 100,
//                         color: AppColors.red,
//                       ),
//                       Text("No Data Found"),
//                     ],
//                   ));
//                 }
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }