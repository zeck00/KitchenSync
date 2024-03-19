// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:kitchensync/screens/bottomNavBar.dart';
import 'package:kitchensync/screens/size_config.dart';
import 'styles/AppColors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    initSizeConfig(context);
    // Define your light theme colors
    final ColorScheme lightColorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.light, // Replace with your light seed color
      // Define other colors if needed
    );

    // Define your dark theme colors
    final ColorScheme darkColorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.dark,
      background: AppColors.dark,
      brightness: Brightness.dark,
    );

    return MaterialApp(
      themeMode: ThemeMode.light, // Use system theme mode by default
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: lightColorScheme,
        useMaterial3: false, // Or true if you want to use Material 3
      ),
      darkTheme: ThemeData(
        colorScheme: darkColorScheme,
        useMaterial3: false, // Or true if you want to use Material 3
        // Define other dark theme settings if necessary
      ),
      home: MainLayout(),
    );
  }
}
