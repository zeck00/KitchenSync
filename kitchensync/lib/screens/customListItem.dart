// ignore_for_file: must_be_immutable, prefer_const_constructors, file_names

import 'package:flutter/material.dart';
import 'package:kitchensync/styles/AppColors.dart';
import 'package:kitchensync/styles/AppFonts.dart';
import '../styles/size_config.dart';

class CustomListItem extends StatelessWidget {
  String mainTxt;
  String numberTxt;
  String subTxt;
  String imagePath;
  double width;
  double height;

  CustomListItem(
      {super.key,
      required this.mainTxt,
      required this.numberTxt,
      required this.subTxt,
      required this.imagePath,
      this.width = double.infinity,
      required this.height});

  @override
  Widget build(BuildContext context) {
    initSizeConfig(context);
    return Container(
      width: propWidth(width),
      height: propHeight(height), // Using your proportional height function
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius:
            BorderRadius.circular(propWidth(17)), // Proportional corner radius
      ),
      child: Row(
        children: [
          Padding(
            padding:
                EdgeInsets.only(left: propWidth(16)), // Proportional padding
            child: Text(mainTxt, style: AppFonts.cntrstText),
          ),
          Expanded(child: Container()),
          Text('$numberTxt ', style: AppFonts.cntrstText1),
          Text(subTxt, style: AppFonts.cntrstText2),
          Expanded(child: Container()),
          Padding(
            padding: EdgeInsets.only(right: 15),
            child: Image.asset(
              imagePath,
              width: propWidth(26), // Proportional width
              height: propHeight(26), // Proportional height
            ),
          ),
        ],
      ),
    );
  }
}
