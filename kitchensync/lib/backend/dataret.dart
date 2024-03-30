// ignore_for_file: unused_import, unnecessary_this, prefer_const_constructors, avoid_print

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:kitchensync/main.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

// This function will get the file from the local directory if it exists,
// otherwise it will copy it from the assets into the local directory.
Future<File> getLocalFile(String filename) async {
  final directory = await getApplicationDocumentsDirectory();
  final path = directory.path;
  final file = File('$path/$filename');

  if (!await file.exists()) {
    final data = await rootBundle.loadString('assets/data/$filename');
    await file.writeAsString(data);
  }
  return file;
}

Future<dynamic> loadJson(String filename) async {
  try {
    final file = await getLocalFile(filename);
    final jsonString = await file.readAsString();
    return jsonDecode(jsonString);
  } catch (e) {
    rethrow;
  }
}

class Kitchen {
  final String kitchenID;
  final String kitchenName;
  String devicesPath;
  List<Device> devices = [];

  Kitchen({
    required this.kitchenID,
    required this.kitchenName,
    required this.devicesPath,
  });

  factory Kitchen.fromJson(Map<String, dynamic> json) {
    return Kitchen(
      kitchenID: json['kitchenID'] as String? ?? 'defaultID',
      kitchenName: json['kitchenName'] as String? ?? 'defaultName',
      devicesPath: json['devicesPath'] as String? ?? 'defaultPath',
    );
  }

  // Call this method after initializing a Kitchen object to load its devices.
  Future<List<Device>> loadDevices() async {
    final deviceData = await loadJson(
        devicesPath); // This loads the kitchen JSON which includes devices.
    devices = (deviceData['devices'] as List)
        .map((deviceJson) => Device.fromJson(deviceJson))
        .toList();
    return devices;
  }

  static Future<List<Kitchen>> fetchKitchens(String assetPath) async {
    final data = await loadJson(assetPath);
    List<Kitchen> kitchens = (data as List)
        .map((kitchenData) => Kitchen.fromJson(kitchenData))
        .toList();

    // Load devices for each kitchen
    for (var kitchen in kitchens) {
      await kitchen.loadDevices();
    }
    return kitchens;
  }
}

class Device {
  Device({
    required this.deviceID,
    required this.deviceName,
    required this.categoriesFile,
    required this.imagePath,
    required this.bigImagePath,
  });

  String deviceID;
  String deviceName;
  String categoriesFile;
  String imagePath;
  String bigImagePath;

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
        deviceID: json['deviceID'] ?? '',
        deviceName: json['deviceName'] ?? '',
        categoriesFile: json['categoriesFile'] ?? '',
        imagePath: json['imagePath'] ?? '',
        bigImagePath: json['bigImagePath'] ?? '');
  }

  List<Category> categories = [];

  Future<List<Category>> loadCategories(String filePath) async {
    try {
      final categoriesJson = await loadJson(filePath);
      if (categoriesJson != null && categoriesJson['categories'] is List) {
        List<dynamic> categoriesList = categoriesJson['categories'];
        List<Category> categories = categoriesList
            .map((categoryData) => Category.fromJson(categoryData))
            .toList();
        return categories;
      } else {
        print('Categories list not found or invalid in $filePath.');
        return []; // Return an empty list to handle this gracefully.
      }
    } catch (e) {
      print('Error loading categories from $filePath: $e');
      return []; // Return an empty list on error.
    }
  }

  Future<void> loadCategoriesAndItems() async {
    // Load categories first
    await loadCategories(this.categoriesFile);
    // Now load items for each category
    for (var category in categories) {
      // Assuming `itemPath` leads to the items JSON and category names match.
      await category.loadItems(category.itemPath ?? 'items.json');
    }
  }

  // Adjust getTotalItemCount to be synchronous since items are pre-loaded
  int getTotalItemCount() {
    int totalCount = 0;
    for (var category in categories) {
      totalCount += category.items.length;
    }
    return totalCount;
  }
}

class Category {
  Category(
      {required this.categoryID,
      required this.categoryName,
      required this.catIcon,
      this.itemPath});

  String categoryID;
  String categoryName;
  String catIcon;
  String? itemPath;

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
      itemPath: data['itemPath'],
    )..items =
        itemsList; // Use the cascade operator to assign `items` if it's not empty.
  }

  // Assign the items from a master list of items based on the category

  // This method filters `allItems` and assigns matching items to `items`.
  void assignItems(List<Item> allItems) {
    items = allItems
        .where((item) =>
            item.category.trim().toLowerCase() ==
            categoryName.trim().toLowerCase())
        .toList();
  }

  double getTotalQuantity() {
    double total =
        items.fold(0.0, (previousValue, item) => previousValue + item.quantity);

    return total;
  }

  static Future<List<Category>> loadCategories(
      String categoriesFilePath) async {
    final categoriesJson = await loadJson(categoriesFilePath);
    // This now correctly checks for the 'categories' key and casts the value to List
    List<dynamic> categoriesList = categoriesJson['categories'] as List;
    return categoriesList
        .map((categoryData) =>
            Category.fromJson(categoryData as Map<String, dynamic>))
        .toList();
  }

  Future<void> loadItems(String itemsFilePath) async {
    final itemsJson = await loadJson(itemsFilePath);
    final List<dynamic> jsonItems = itemsJson['items'];
    // Filter and load items for this category
    items = jsonItems
        .where((item) => item['category'] == categoryName)
        .map((item) => Item.fromJson(item))
        .toList();
  }
}

class FoodBank {
  final String name;
  final String location;
  final String link;

  FoodBank({required this.name, required this.location, required this.link});

  factory FoodBank.fromJson(Map<String, dynamic> json) {
    return FoodBank(
      name: json['name'] as String,
      location: json['location'] as String,
      link: json['link'] as String,
    );
  }

  static Future<List<FoodBank>> loadNearestFoodBanks() async {
    final jsonString =
        await rootBundle.loadString('assets/data/nearest_food_banks.json');
    final jsonResponse = json.decode(jsonString) as List<dynamic>;
    return jsonResponse.map((data) => FoodBank.fromJson(data)).toList();
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
      itemID: data['itemID'] ?? 'UnknownID',
      itemName: data['itemName'] ?? 'Unknown Name',
      nfcTagID: data['nfcTagID'] ?? 'Unknown NFC Tag ID',
      pDate: data['pDate'] ?? '',
      xDate: data['xDate'] ?? '',
      inDate: data['inDate'] ?? '',
      itemInfo: data['itemInfo'] ?? '',
      status: data['status'] ?? 'Unknown Status',
      category: data['category'] ?? 'Unknown Category',
      quantity: data['quantity'] ?? 0,
      unit: data['unit'] ?? 'Unknown Unit',
    );
  }

  static DateTime _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) {
      // Handle the case where dateStr is null or empty
      return DateTime.now(); // or some other default date
    }
    try {
      return DateFormat('yyyy-MM-dd').parse(dateStr);
    } catch (e) {
      // Handle the case where parsing fails
      return DateTime.now(); // or some other default date
    }
  }

// Method to save updated item details
  Map<String, dynamic> toJson() => {
        'itemID': itemID,
        'itemName': itemName,
        'pDate': pDate.isNotEmpty ? pDate : null,
        'xDate': xDate.isNotEmpty ? xDate : null,
        'inDate': inDate.isNotEmpty ? inDate : null,
        'itemInfo': itemInfo.isNotEmpty ? itemInfo : null,
        'status': status.isNotEmpty ? status : null,
        'category': category.isNotEmpty ? category : null,
        'quantity': quantity != 0 ? quantity : 1, // Changed here
        'unit': unit.isNotEmpty ? unit : null,
      };

  Item copyWith({
    String? itemName,
    String? nfcTagID,
    String? pDate,
    String? xDate,
    String? inDate,
    String? itemInfo,
    String? status,
    String? category,
    int? quantity,
    String? unit,
  }) {
    return Item(
      itemID: this.itemID, // Keep the existing ID
      itemName: itemName ?? this.itemName,
      nfcTagID: nfcTagID ?? this.nfcTagID,
      pDate: pDate ?? this.pDate,
      xDate: xDate ?? this.xDate,
      inDate: inDate ?? this.inDate,
      itemInfo: itemInfo ?? this.itemInfo,
      status: status ?? this.status,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
    );
  }

  DateTime get exDate {
    return _parseDate(this.xDate);
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/items.json');
  }

  Future<File> ensureLocalFile() async {
    final file = await _localFile;

    if (!await file.exists()) {
      // Assuming 'items.json' is in your assets directory
      final data = await rootBundle.loadString('assets/items.json');
      await file.writeAsString(data, flush: true);
    }

    return file;
  }

  static Future<List<Item>> loadAllItems(String itemsFilePath) async {
    try {
      final file = await getLocalFile(itemsFilePath);
      final jsonString = await file.readAsString();
      final jsonMap = json.decode(jsonString);

      // Assuming the JSON structure starts with a Map, and contains a List<dynamic> under the "items" key
      if (jsonMap is Map<String, dynamic> && jsonMap.containsKey('items')) {
        final List<dynamic> jsonItems = jsonMap['items'];
        return jsonItems.map((itemJson) => Item.fromJson(itemJson)).toList();
      } else {
        // If the JSON doesn't contain the "items" key, or isn't structured as expected, return an empty list
        return [];
      }
    } catch (e) {
      print('Error loading items from $itemsFilePath: $e');
      return []; // Return an empty list on error.
    }
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
