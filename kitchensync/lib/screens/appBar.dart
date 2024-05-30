// ignore_for_file: prefer_const_constructors, dangling_library_doc_comments, file_names, unused_import

/// Builds a custom app bar widget that displays the app name, logo, and profile avatar.
///
/// The app bar shows the app name centered at the top, with the logo on the left
/// and profile avatar on the right. The logo and avatar are clickable.
///
/// This is used as the main app bar throughout the app. It is a stateless widget
/// that implements [PreferredSizeWidget] to define the app bar height.
import 'package:flutter/material.dart';
import 'package:kitchensync/screens/bottomNavBar.dart';
import 'package:kitchensync/screens/customListItem.dart';
import 'package:kitchensync/screens/homePage.dart';
import 'package:kitchensync/styles/AppColors.dart';
import 'package:kitchensync/styles/AppFonts.dart'; // Make sure the file name is correct and lowercase
import 'package:kitchensync/styles/size_config.dart';
import 'dart:ui' as ui;

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  void _showPopup(BuildContext context) {
    Navigator.of(context).push(_PopupRoute());
  }

  @override
  Widget build(BuildContext context) {
    initSizeConfig(context);
    return SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: propHeight(28),
          ),
          Text(
            'KitchenSync',
            style: AppFonts.appname,
            textAlign: TextAlign.center,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: propWidth(27)),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MainLayout()),
                    );
                  },
                  child: CircleAvatar(
                    radius: propWidth(21.1),
                    backgroundImage: AssetImage('assets/images/logo.png'),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _showPopup(context),
                child: Padding(
                  padding: EdgeInsets.only(right: propWidth(27)),
                  child: CircleAvatar(
                      radius: propWidth(21.1),
                      backgroundColor: AppColors.primary,
                      child: Image.asset(
                        'assets/images/person.png',
                        height: propHeight(25),
                        width: propWidth(25),
                      )),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Overrides [Size.preferredSize] to set the AppBar height.
  ///
  /// The _PopupRoute class extends [PopupRoute] to customize the popup
  /// for selecting a kitchen. It sets properties like barrier color,
  /// dismissibility, etc. and builds the popup UI.
  @override
  Size get preferredSize => Size.fromHeight(propHeight(107.5));
}

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
