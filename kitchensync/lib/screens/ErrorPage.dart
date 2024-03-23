// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api, file_names, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:kitchensync/screens/appBar.dart';
import 'package:kitchensync/styles/AppColors.dart';
import 'package:kitchensync/styles/AppFonts.dart';

import 'size_config.dart';

class ErrorScreen extends StatefulWidget {
  const ErrorScreen({super.key});

  @override
  _ErrorScreenState createState() => _ErrorScreenState();
}

class _ErrorScreenState extends State<ErrorScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
            child: Text(
              'Unexpected Error',
              style: AppFonts.welcomemsg1,
            ),
          ),
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(children: [])),
          SizedBox(height: propHeight(propHeight(200))),
          Icon(
            Icons.wifi_tethering_error_rounded_rounded,
            color: AppColors.red,
            size: 150,
          ),
          // Account, Privacy, and About sections
          SizedBox(height: propHeight(35)),
        ],
      ),
    );
  }
}
