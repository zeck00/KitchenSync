// ignore_for_file: file_names, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:kitchensync/styles/AppColors.dart';
import 'package:kitchensync/styles/AppFonts.dart';
import '../styles/size_config.dart';

class CustomDeviceCard extends StatelessWidget {
  final String title;
  final String itemCount;
  final String imagePath;
  final Color containerColor;

  const CustomDeviceCard({
    super.key,
    required this.title,
    required this.itemCount,
    required this.imagePath,
    this.containerColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Row(
        children: [
          SizedBox(width: 20),
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: propWidth(175),
                height: propHeight(125),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(17),
                  color: containerColor,
                ),
              ),
              Positioned(
                top: propHeight(7),
                right: propWidth(7),
                child: Image.asset(
                  'assets/images/Synchronize.png',
                  width: propWidth(24),
                  height: propHeight(24),
                ),
              ),
              Positioned(
                bottom: propHeight(15),
                right: propWidth(1),
                left: propWidth(1),
                child: Image.asset(
                  imagePath,
                  width: propWidth(115),
                  height: propHeight(175),
                ),
              ),
              Positioned(
                bottom: propHeight(12),
                right: propWidth(12),
                left: propWidth(12),
                child: Row(
                  children: [
                    Text(
                      title,
                      style: AppFonts.locCard,
                    ),
                    Expanded(child: Container()),
                    Text(
                      itemCount,
                      style: AppFonts.locCard,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      onTap: () {
        // Define your onTap functionality here, if needed
      },
    );
  }
}
