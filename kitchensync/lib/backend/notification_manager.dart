// ignore_for_file: deprecated_member_use, unused_import, prefer_const_constructors, avoid_print, use_build_context_synchronously, non_constant_identifier_names

/*
_loadItemsAndScheduleNotifications(context);
      _checkAndRequestNotificationPermissions(context);
      await _showWelcomeNotification();

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
final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
const platform = MethodChannel('com.kitchensync.app/alarm_permission');

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

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
*/

import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kitchensync/styles/AppColors.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationManager {
  static final NotificationManager _notificationManager =
      NotificationManager._internal();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  factory NotificationManager() {
    return _notificationManager;
  }

  NotificationManager._internal();

  Future<void> initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    await FirebaseAPI().initFirebaseNotis();
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'kitchen_sync_channel', 'Item Expiration Notifications',
        description: 'Channel for Item Expiry Notifications',
        importance: Importance.max,
        playSound: true,
        enableVibration: true);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    print('notifications channel for expiry is created');
  }

  Future<void> requestPermissions(BuildContext context) async {
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      await Permission.notification.request();
    }
    if (status.isGranted) {
      scheduleWelcomeNotification();
    }
  }

  Future<void> scheduleWelcomeNotification() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('first_time') ?? true) {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
              'kitchen_sync_channel', 'Welcome Notification',
              importance: Importance.max,
              priority: Priority.high,
              playSound: true,
              enableVibration: true);
      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidDetails);
      await flutterLocalNotificationsPlugin.show(
        0,
        'Welcome to KitchenSync',
        'Notifications are set to keep you updated!',
        platformChannelSpecifics,
      );
      await prefs.setBool('first_time', false);
    }
  }

  Future<void> setupTimeZone() async {
    tz.initializeTimeZones();
    String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
    print("Time Zone initialized to: $timeZoneName");
  }

  Future<void> scheduleItemExpiryNotifications(DateTime expiryDate) async {
    await setupTimeZone();
    NotificationManager manager = NotificationManager();
    await manager.initNotifications();
    bool permissionGranted =
        await manager.checkAndRequestExactAlarmPermission();
    if (permissionGranted) {
      // Schedule your notifications
    } else {
      // Handle permission denial
      print("Permission to schedule exact alarms was denied.");
    }
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    for (int i = 5; i >= 0; i--) {
      final tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local,
              expiryDate.year, expiryDate.month, expiryDate.day, 19, 7, 50)
          .subtract(Duration(days: i));
      if (scheduledDate.isAfter(now)) {
        // Ensure we're not scheduling notifications in the past
        final int notificationId = 1000 + i; // Unique ID for each notification
        const AndroidNotificationDetails androidDetails =
            AndroidNotificationDetails('kitchen_sync_channel', 'Item Expiry',
                importance: Importance.max,
                priority: Priority.high,
                ticker: 'ticker',
                playSound: true,
                enableVibration: true);

        const NotificationDetails platformChannelSpecifics =
            NotificationDetails(android: androidDetails);
        await flutterLocalNotificationsPlugin.zonedSchedule(
          notificationId,
          'Item Expiring Soon',
          'Your item will expire in $i day${i == 1 ? '' : 's'}!',
          tz.TZDateTime.from(scheduledDate, tz.local),
          platformChannelSpecifics,
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      }

      var now1 = tz.TZDateTime.now(tz.local);
      print("Current time in local time zone: $now1");
      print("Scheduling notification for date: $scheduledDate");
    }
  }

  Future<void> requestPermissionsAndSendWelcome(BuildContext context) async {
    var status = await Permission.notification.request();

    if (status.isGranted) {
      // Setup notification
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
              'welcome_channel', // ID of the channel
              'Welcome Notifications', // Title of the channel
              channelDescription: 'Notifications for new users',
              importance: Importance.max,
              priority: Priority.high,
              ticker: 'ticker');
      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      // Show the notification
      await flutterLocalNotificationsPlugin.show(
        0, // Notification ID
        'Welcome to KitchenSync!', // Title
        'We are glad to have you on board.', // Body
        platformChannelSpecifics,
      );
    } else {
      // Handle the case where permission is denied
      QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        title: 'Notification Permission',
        backgroundColor: AppColors.light,
        text:
            "Notification permission was denied. Enable it from settings to receive important updates.",
        barrierDismissible: true,
        animType: QuickAlertAnimType.slideInUp,
        cancelBtnText: 'Ok',
        onCancelBtnTap: () => Navigator.of(context).pop(),
      );
    }
  }

  static const platform = MethodChannel('com.kitchensync.app/notifications');

  Future<bool> checkAndRequestExactAlarmPermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt >= 31) {
        final hasPermission =
            await platform.invokeMethod('checkExactAlarmPermission');
        if (!hasPermission) {
          final result =
              await platform.invokeMethod('requestExactAlarmPermission');
          return result;
        }
        return hasPermission;
      }
    }
    // If it's not Android 12 or above, exact alarm permission isn't necessary.
    return true;
  }

  NotificationManager.scheduleWelcomeNotification();
}

class FirebaseAPI {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  // Initialize notification settings
  Future<void> initFirebaseNotis() async {
    // Getting the token for the device
    final FCMToken = await _firebaseMessaging.getToken();
    print('Token is: $FCMToken');

    // Create a channel (Android only)
    AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // ID
      'High Importance Notifications', // Title
      description:
          'This channel is used for important notifications.', // Description
      importance: Importance.high,
      enableLights: true,
      enableVibration: true,
      playSound: true,
      ledColor: AppColors.green,
      showBadge: true,
    );

    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Set up the channel
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              // Add other properties if needed
            ),
          ),
        );
        print('working MF!');
      }
    });

    // Handle messages when the app is in background but not terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
    });
  }
}
