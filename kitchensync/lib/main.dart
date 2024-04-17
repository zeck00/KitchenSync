// ignore_for_file: unused_import, prefer_const_constructors, avoid_print, prefer_const_constructors_in_immutables, library_private_types_in_public_api

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kitchensync/backend/authPage.dart';
import 'package:kitchensync/backend/notification_manager.dart';
import 'package:kitchensync/screens/ErrorPage.dart';
import 'package:kitchensync/screens/bottomNavBar.dart';
import 'package:kitchensync/styles/size_config.dart';
import 'backend/dataret.dart';
import 'styles/AppColors.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:kitchensync/screens/onBoardingPages.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  tz.initializeTimeZones();
  await initializeAppData();
  await NotificationManager().initNotifications();
  runApp(Bootstrap());
}

class Bootstrap extends StatelessWidget {
  const Bootstrap({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (BuildContext context) {
            initializeApp(context);
            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  void initializeApp(BuildContext context) async {
    tz.initializeTimeZones();
    runApp(MyApp());
  }
}

Future<void> initializeAppData() async {
  try {
    // Add other file names as necessary
    await getLocalFile('items.json');
    await getLocalFile('items1.json');
    await getLocalFile('kitchens.json');
    await getLocalFile('categories.json');
    await getLocalFile('responses.json');
    await getLocalFile('kitchen_001.json');
    await getLocalFile('categories_002.json');
    await getLocalFile('kitchen_002.json');
    await getLocalFile('nearest_food_banks.json');
  } catch (e) {
    print("Failed to initialize app data: $e");
  }
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    WidgetsBinding.instance.addPostFrameCallback((_) async {});
  }

  // This widget is the root of application.
  @override
  Widget build(BuildContext context) {
    initSizeConfig(context);
    // Define light theme colors
    final ColorScheme lightColorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.light,
      // Define other colors if needed
    );

    // Define your dark theme colors
    final ColorScheme darkColorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.dark,
      background: AppColors.dark,
      brightness: Brightness.dark,
    );

    return MaterialApp(
      navigatorKey: navigatorKey,
      themeMode: ThemeMode.light,
      title: 'KitchenSync',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: lightColorScheme,
        useMaterial3: false, // Or true if you want to use Material 3
      ),
      darkTheme: ThemeData(
        colorScheme: darkColorScheme,
        useMaterial3: false,
      ),
      home: AuthPage(),
    );
  }
}
