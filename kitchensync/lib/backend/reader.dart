// reader.dart
// ignore_for_file: void_checks

import 'dart:convert';
import 'dart:io';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:path_provider/path_provider.dart';

class NfcService {
  Future<void> startNFC() async {
    bool isAvailable = await NfcManager.instance.isAvailable();
    if (!isAvailable) return;

    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      final ndef = Ndef.from(tag);
      if (ndef == null ||
          ndef.cachedMessage?.records == null ||
          ndef.cachedMessage!.records.isEmpty) {
        return Future.value("Empty NDEF message");
      }

      final payload = ndef.cachedMessage!.records.first.payload;
      if (payload == null || payload.isEmpty) {
        return Future.value("Empty NDEF record payload");
      }

      String nfcData = String.fromCharCodes(payload);
      Map<String, dynamic> tagData = json.decode(nfcData);
      await _addDataToJsonFile(tagData);
    });
  }

  Future<File> _getLocalFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/items.json');
  }

  Future<void> _addDataToJsonFile(Map<String, dynamic> newData) async {
    final file = await _getLocalFile();
    List<dynamic> inventory = [];

    if (await file.exists()) {
      String contents = await file.readAsString();
      inventory = json.decode(contents)['items'];
    }

    // Add real-life current date as inDate
    String currentDate = DateTime.now().toIso8601String().split('T').first;
    newData['inDate'] = currentDate;

    // Map of keywords to units
    const Map<String, String> unitMap = {
      // Liquid volumes
      'juice': 'Liters',
      'milk': 'Liters',
      'drink': 'Liters',
      'water': 'Liters',
      'oil': 'Liters',
      'vinegar': 'Milliliters',
      'soda': 'Milliliters',
      'beer': 'Milliliters',
      'wine': 'Milliliters',

      // Weights
      'flour': 'Grams',
      'sugar': 'Grams',
      'butter': 'Grams',
      'meat': 'Kilograms',
      'chicken': 'Kilograms',
      'beef': 'Kilograms',
      'fish': 'Kilograms',
      'cheese': 'Grams',
      'ham': 'Grams',
      'salt': 'Grams',
      'pepper': 'Grams',
      'pasta': 'Grams',
      'rice': 'Kilograms',
      'nuts': 'Grams',

      // Countable items
      'egg': 'Pieces',
      'apples': 'Pieces',
      'oranges': 'Pieces',
      'lemons': 'Pieces',
      'bananas': 'Pieces',
      'tomato': 'Pieces',
      'potato': 'Pieces',
      'onion': 'Pieces',
      'carrot': 'Pieces',

      // Bunches or heads for vegetables
      'lettuce': 'Heads',
      'cabbage': 'Heads',
      'garlic': 'Heads',
      'broccoli': 'Heads',

      // For bread or similar items
      'bread': 'Loaves',
      'bun': 'Pieces',
      'bagel': 'Pieces',
      'doughnut': 'Pieces',

      // For packaged sets
      'yogurt': 'Packs',
      'tofu': 'Packs',
      'noodles': 'Packs',

      // Others
      'coffee': 'Grams',
      'tea': 'Grams',
      'honey': 'Grams',
      'syrup': 'Milliliters',
      'jam': 'Grams',
      'spaghetti': 'Grams',
      'cereal': 'Grams',
      // Add more mappings as needed
    };

    // Determine the unit based on the item name using the unitMap
    String unit = "Pieces"; // Default unit
    String nameLowercase = newData['itemName'].toString().toLowerCase();
    unitMap.forEach((key, value) {
      if (nameLowercase.contains(key)) {
        unit = value;
      }
    });

    // Assign the determined unit to the new data
    newData['unit'] = unit;

    // Set the status to 'fresh' by default
    newData['status'] = 'fresh';

    // Set a default quantity if not already present
    newData['quantity'] = newData['quantity'] ?? 1;

    // Add the new item data to the inventory list
    inventory.add(newData);
    await file.writeAsString(json.encode({'items': inventory}));
  }

  void stopNFC() {
    NfcManager.instance.stopSession();
  }
}
