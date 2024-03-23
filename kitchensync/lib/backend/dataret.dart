// ignore_for_file: unused_import

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:kitchensync/main.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

Future<dynamic> loadJsonFromAssets(String path) async {
  final jsonString = await rootBundle.loadString(path);
  return jsonDecode(jsonString);
}

class Kitchen {
  Kitchen({
    required this.kitchenID,
    required this.kitchenName,
    required this.devicesPath,
  });

  final String kitchenID;
  final String kitchenName;
  String devicesPath;
  List<Device> devices = []; // Initialize the devices list.

  // Adjusted to load Kitchen object(s) along with their devices
  static Future<List<Kitchen>> fetchKitchens(String assetPath) async {
    final data = await loadJsonFromAssets(assetPath);
    return (data as List)
        .map((kitchenData) => Kitchen.fromJson(kitchenData))
        .toList();
  }

  factory Kitchen.fromJson(Map<String, dynamic> json) {
    return Kitchen(
      kitchenID: json['kitchenID'],
      kitchenName: json['kitchenName'],
      devicesPath:
          json['devicesPath'], // Make sure this key matches your JSON file.
    );
  }

  Future<void> loadDevices() async {
    final devicesJson = await loadJsonFromAssets('assets/data/$devicesPath');
    devices = (devicesJson['devices'] as List)
        .map((deviceJson) => Device.fromJson(deviceJson))
        .toList();
  }
}

class Device {
  Device({
    required this.deviceID,
    required this.deviceName,
    required this.categoriesFile,
  });

  String deviceID;
  String deviceName;
  String categoriesFile;

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      deviceID: json['deviceID'],
      deviceName: json['deviceName'],
      categoriesFile: json['categoriesFile'],
    );
  }

  Future<Device> loadDev(String devName) async {
    final String response =
        await rootBundle.loadString('assets/data/$devName' '.json');
    final data = await json.decode(response);
    return Device.fromJson(data);
  }

  List<Category> categories = [];

  Future<void> loadCategories(String categoriesFilePath) async {
    final categoriesJson = await loadJsonFromAssets(categoriesFilePath);
    // Assuming the JSON structure matches the given example.
    categories = (categoriesJson as List)
        .map((categoryData) => Category.fromJson(categoryData))
        .toList();
  }
}

class Category {
  Category(
      {required this.categoryID,
      required this.categoryName,
      required this.catIcon});

  String categoryID;
  String categoryName;
  String catIcon;

  List<Item> items = []; // Initialize `items` here only.

  factory Category.fromJson(Map<String, dynamic> data) {
    // Assuming `items` key is an array of item JSON objects
    var itemsList = <Item>[];
    if (data['items'] != null) {
      itemsList = (data['items'] as List)
          .map((itemData) => Item.fromJson(itemData))
          .toList();
    }

    return Category(
      categoryID: data['categoryID'],
      categoryName: data['categoryName'],
      catIcon: data['iconPath'],
    )..items =
        itemsList; // Use the cascade operator to assign `items` if it's not empty.
  }

  Future<Category> loadCat(String catName) async {
    final String response =
        await rootBundle.loadString('assets/data/categories.json');
    final data = await json.decode(response);
    return Category.fromJson(data);
  }

  // Assign the items from a master list of items based on the category.
  void assignItems(List<Item> allItems) {
    items = allItems.where((item) => item.category == categoryName).toList();
  }

  // Calculate the total quantity of items in this category.
  double getTotalQuantity() {
    return items.fold(0.0, (total, item) => total + item.quantity);
  }

  static Future<List<Category>> loadCategories(
      String categoriesFilePath) async {
    final categoriesJson = await loadJsonFromAssets(categoriesFilePath);
    // This now correctly checks for the 'categories' key and casts the value to List
    List<dynamic> categoriesList = categoriesJson['categories'] as List;
    return categoriesList
        .map((categoryData) =>
            Category.fromJson(categoryData as Map<String, dynamic>))
        .toList();
  }
}

class Item {
  Item({
    required this.itemID,
    required this.itemName,
    required this.nfcTagID,
    required this.pDate,
    required this.xDate,
    required this.inDate,
    required this.itemInfo,
    required this.status,
    required this.category,
    required this.quantity,
    required this.unit,
  });

  String itemID;
  String itemName;
  String nfcTagID;
  String pDate;
  String xDate;
  String inDate;
  String itemInfo;
  String status;
  String category;
  int quantity;
  String unit;

  factory Item.fromJson(Map<String, dynamic> data) {
    return Item(
      itemID: data['itemID'],
      itemName: data['itemName'],
      nfcTagID: data['nfcTagID'],
      pDate: data['pDate'],
      xDate: data['xDate'],
      inDate: data['inDate'],
      itemInfo: data['itemInfo'],
      status: data['status'],
      category: data['category'],
      quantity: data['quantity'],
      unit: data['unit'],
    );
  }

  DateTime get exDate {
    return DateTime.parse(xDate);
  }

  static Future<List<Item>> loadAllItems(String itemsFilePath) async {
    final itemsJson = await loadJsonFromAssets(itemsFilePath);
    // This now correctly checks for the 'items' key and casts the value to List
    List<dynamic> itemsList = itemsJson['items'] as List;
    return itemsList
        .map((itemData) => Item.fromJson(itemData as Map<String, dynamic>))
        .toList();
  }

  Future<void> scheduleExpirationNotifications() async {
    final now = tz.TZDateTime.now(tz.local);
    final expiration = tz.TZDateTime.from(exDate, tz.local);

    // Check if the expiration date is in the future
    if (expiration.isAfter(now)) {
      final difference = expiration.difference(now).inDays;
      // Schedule notifications for 5, 3, 2, 1, and 0 days before expiration
      if (difference <= 5) {
        if (difference >= 1) {
          // Schedule a notification for each day
          for (var i = difference; i >= 1; i--) {
            await scheduleNotification(i, itemName, itemID);
          }
        } else {
          // Schedule for the day of expiration
          await scheduleNotification(0, itemName, itemID);
          // Schedule a second notification for recipes after 10 minutes
          // await scheduleRecipeSuggestion(itemName);
        }
      }
    }
  }
}
