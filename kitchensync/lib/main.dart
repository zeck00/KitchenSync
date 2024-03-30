// ignore_for_file: prefer_const_constructors, use_super_parameters, deprecated_member_use, prefer_const_constructors_in_immutables, use_build_context_synchronously, library_private_types_in_public_api, avoid_print, unused_element, unused_import

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
const platform = MethodChannel('com.example.kitchensync/alarm_permission');

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await initializeAppData();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Setup initialization settings for Android
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  // Define initialization settings for iOS and Android
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  // Initialize the plugin
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
  );

  // Create a channel for Android (Android 8.0+)
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'kitchen_sync_channel', // Same as used in notification details
    'Item Expiration Notifications', // Title for the channel
    description:
        'This channel is used for item expiration notifications.', // Description for the channel
    importance: Importance.max,
  );

  // Check for platform version and create the channel using the plugin
  if (Platform.isAndroid) {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  if (Platform.isAndroid) {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = androidInfo.version.sdkInt;
    if (sdkInt >= 31) {
      // Android 12 and above
      final bool? isPermissionGranted =
          await platform.invokeMethod('checkExactAlarmPermission');
      if (isPermissionGranted == false) {
        final bool? result =
            await platform.invokeMethod('requestExactAlarmPermission');
        if (result != null && result) {
          print('Exact alarm permission request successful');
        } else {
          print('Exact alarm permission request failed or denied');
        }
      } else {
        print('Exact alarm permission is already granted or not necessary.');
      }
    }
  }

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
    await requestPermissions(context);
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

Future<void> requestPermissions(BuildContext context) async {
  await requestStoragePermission(context);
}

Future<void> requestStoragePermission(BuildContext context) async {
  var status = await Permission.storage.status;
  if (!status.isGranted) {
    if (await Permission.storage.shouldShowRequestRationale) {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text("Storage Permission Required"),
          content: Text(
              "This app requires storage access to function properly. Please allow this permission in the next prompt."),
          actions: <Widget>[
            TextButton(
              child: Text("Deny"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text("Allow"),
              onPressed: () {
                Navigator.of(context).pop();
                _requestPermission(Permission.storage);
              },
            ),
          ],
        ),
      );
    } else {
      _requestPermission(Permission.storage);
    }
  }
}

Future<void> _requestPermission(Permission permission) async {
  final status = await permission.request();
  if (status.isPermanentlyDenied) {
    openAppSettings();
  }
}

Future<void> scheduleNotification(
    int daysBefore, String itemId, String itemName) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'kitchen_sync_channel',
    'Item Expiration',
    channelDescription: 'Notifications for items expiring soon',
    importance: Importance.max,
    priority: Priority.high,
    colorized: true,
    color: AppColors.primary,
    ticker: 'ticker',
  );
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  final now = tz.TZDateTime.now(tz.local);
  final scheduledDate = now.add(Duration(days: daysBefore));

  /// Ensure the scheduled time is in the future
  if (scheduledDate.isBefore(now)) {
    print("Scheduled date is in the past. Adjusting to future.");
    return; // This prevents scheduling a notification for the past.
  }

  // Generate a unique ID for each notification that fits within a 32-bit integer range
  var itemIdHash = itemId.hashCode;
  // Generate a unique ID for each notification
  int notificationId = itemIdHash %
      2147483647; // 2^31 - 1, which is the maximum positive value for a 32-bit signed binary integer

  await flutterLocalNotificationsPlugin.zonedSchedule(
    notificationId, // Use the unique ID
    'Item Expiring Soon',
    '$itemName is expiring in $daysBefore days.',
    scheduledDate,
    platformChannelSpecifics,
    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents:
        DateTimeComponents.time, // Consider adjusting based on requirements
  );
}

Future<void> _loadItemsAndScheduleNotifications(BuildContext context) async {
  try {
    final items = await Item.loadAllItems('items.json');
    for (var item in items) {
      await item.scheduleExpirationNotifications();
    }
  } catch (e, stacktrace) {
    print('Error: $e');
    print('Stacktrace: $stacktrace');
    _showErrorPage(context);
  }
}

void _showErrorPage(BuildContext context) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    navigatorKey.currentState?.pushReplacement(MaterialPageRoute(
      builder: (context) => ErrorScreen(),
    ));
  });
}

Future<void> _checkAndRequestNotificationPermissions(
    BuildContext context) async {
  final status = await Permission.notification.status;
  if (!status.isGranted) {
    // Showing a pre-permission dialog to explain why notifications are needed
    bool showRationale =
        await Permission.notification.shouldShowRequestRationale;
    if (showRationale) {
      // Show your own custom dialog or informational UI to explain why you need this permission
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Notification Permission"),
          content: Text(
              "We need notification permissions to alert you about item expirations. Allow notifications in the next prompt?"),
          actions: [
            TextButton(
              child: Text("Deny"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Allow"),
              onPressed: () {
                Navigator.of(context).pop();
                _requestNotificationPermission(); // Proceed to request permission
              },
            ),
          ],
        ),
      );
    } else {
      // Directly request for permission without rationale
      _requestNotificationPermission();
    }
  }
}

Future<void> _checkNotificationPermission() async {
  final status = await Permission.notification.status;
  if (!status.isGranted) {
    // Notifications permission has not been granted.
    // You can prompt the user with more information here if you want.
    _requestNotificationPermission();
  }
}

Future<void> _requestNotificationPermission() async {
  final status = await Permission.notification.request();
  if (status.isGranted) {
    // Permission granted
    print("Notification Permission granted.");
  } else if (status.isDenied) {
    // Permission denied
    print("Notification Permission denied.");
  } else if (status.isPermanentlyDenied) {
    // Open app settings if permission is permanently denied
    openAppSettings();
  }
}

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _loadItemsAndScheduleNotifications(context);
      _checkAndRequestNotificationPermissions(context);
      await _showWelcomeNotification();
    });
  }

  Future<void> _showWelcomeNotification() async {
    final prefs = await SharedPreferences.getInstance();
    // Check if 'first_time' key exists or is set to true
    if (prefs.getBool('first_time') ?? true) {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'kitchen_sync_channel',
        'Welcome to KitchenSync',
        channelDescription: 'General notifications',
        importance: Importance.max,
        priority: Priority.high,
        color: AppColors.primary,
        ticker: 'ticker',
      );
      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      await flutterLocalNotificationsPlugin.show(
        0,
        'Notification Permission Granted!',
        'We use notifications to enhance your experience. KitchenSync is happy to have you on board!',
        platformChannelSpecifics,
      );
      // Set 'first_time' key to false so this only happens once
      await prefs.setBool('first_time', false);
    }
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
      // Use system theme mode by default
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
