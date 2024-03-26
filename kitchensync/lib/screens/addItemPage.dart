// ignore_for_file: prefer_final_fields, unused_import, unnecessary_null_comparison, avoid_print, prefer_const_constructors, library_private_types_in_public_api, file_names, prefer_const_literals_to_create_immutables, unused_element

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kitchensync/backend/dataret.dart';
import 'package:kitchensync/screens/OCRPage.dart';
import 'package:kitchensync/screens/appBar.dart';
import 'package:kitchensync/styles/size_config.dart';
import 'package:kitchensync/styles/AppColors.dart';
import 'package:kitchensync/styles/AppFonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:kitchensync/screens/inventoryPage.dart';

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});

  @override
  _AddItemPageState createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late List<Kitchen> kitchens = [];
  late List<Device> devices = [];
  late List<Category> categories = [];
  String? selectedKitchen;
  String? selectedDevice;
  String? selectedCategory;
  Item? newItem;

  // Initialize the text editing controllers
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _nfcTagIdController = TextEditingController();
  final TextEditingController _pDateController = TextEditingController();
  final TextEditingController _xDateController = TextEditingController();
  final TextEditingController _inDateController = TextEditingController();
  final TextEditingController _itemInfoController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();

  String generateItemId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  void createItem() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      String categoryName = categories
          .firstWhere((category) => category.categoryID == selectedCategory,
              orElse: () => Category(
                  categoryID: '',
                  categoryName: 'Diary',
                  catIcon:
                      'assets/images/Milk.png') // Provide a default or handle the case where the category is not found
              )
          .categoryName;

      // Create a new item using the controllers
      newItem = Item(
        itemID: generateItemId(),
        itemName: _itemNameController.text,
        nfcTagID: _nfcTagIdController.text,
        pDate: selectedPDate != null
            ? DateFormat('yyyy-MM-dd').format(selectedPDate!)
            : '',
        xDate: selectedXDate != null
            ? DateFormat('yyyy-MM-dd').format(selectedXDate!)
            : '',
        inDate: DateFormat('yyyy-MM-dd').format(selectedInDate),
        itemInfo: _itemInfoController.text,
        status: selectedStatus ?? '',
        category: categoryName,
        quantity: int.tryParse(_quantityController.text) ?? 0,
        unit: selectedUnit ?? '',
      );

      addNewItem(newItem!);

      _showCustomOverlay(
          context, newItem!.itemName); // Pass the item name dynamically

      clearFormFields();
    }
  }

  void _showCustomOverlay(BuildContext context, String itemName) {
    final overlay = Overlay.of(context);
    final overlayEntry = _createOverlayEntry(context, itemName);

    // Insert the overlay entry to the overlay
    overlay.insert(overlayEntry);

    // Wait for 2 seconds and remove the overlay
    Future.delayed(Duration(seconds: 3)).then((value) => overlayEntry.remove());
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/items.json');
  }

  Future<void> addNewItem(Item newItem) async {
    final file = await _localFile;

    try {
      List<dynamic> itemsList = [];
      // Check if the file exists and has content
      if (await file.exists() && await file.readAsString() != '') {
        final contents = await file.readAsString();
        final decoded = json.decode(contents);
        if (decoded is Map<String, dynamic> && decoded.containsKey('items')) {
          itemsList = decoded['items'];
        }
      }

      // Add the new item to the items list
      itemsList.add(newItem.toJson());

      // Prepare the data in the expected structure
      final Map<String, dynamic> updatedData = {"items": itemsList};

      // Write the updated data back to the file
      await file.writeAsString(json.encode(updatedData));
      print("Item added successfully: ${newItem.itemName}");
    } catch (e) {
      print("Error updating items.json: $e");
    }
  }

  void clearFormFields() {
    // Clear the text fields
    _itemNameController.clear();
    _nfcTagIdController.clear();
    _pDateController.clear();
    _xDateController.clear();
    _inDateController.clear();
    _itemInfoController.clear();
    _statusController.clear();
    _quantityController.clear();
    _unitController.clear();

    // Reset any selected dropdown values
    setState(() {
      selectedKitchen = null;
      selectedDevice = null;
      selectedCategory = null;
      selectedStatus = null;
      selectedUnit = null;
      selectedPDate = null;
      selectedXDate = null;
      selectedInDate = DateTime.now();
    });
  }

  // Make sure to dispose of the controllers when the state is disposed
  @override
  void dispose() {
    _itemNameController.dispose();
    _nfcTagIdController.dispose();
    _pDateController.dispose();
    _xDateController.dispose();
    _inDateController.dispose();
    _itemInfoController.dispose();
    _statusController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loadInitialData();
  }

  void loadInitialData() async {
    kitchens = await Kitchen.fetchKitchens('kitchens.json');
    if (kitchens.isNotEmpty) {
      selectedKitchen = kitchens.first.kitchenID;
      devices = await kitchens.first.loadDevices();
      if (devices.isNotEmpty) {
        selectedDevice = devices.first.deviceID;
        categories =
            await devices.first.loadCategories(devices.first.categoriesFile);
        if (categories.isNotEmpty) {
          selectedCategory = categories.first.categoryID;
        }
      }
    }
    setState(() {});
  }

  DateTime? selectedPDate;
  DateTime? selectedXDate;
  DateTime selectedInDate = DateTime.now();
  String? selectedStatus;
  // Method to show the date picker and update the state
  Future<void> _selectDate(BuildContext context, DateTime initialDate,
      ValueChanged<DateTime> onDateSelected) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000), // Adjust according to your requirement
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != initialDate) {
      onDateSelected(pickedDate);
    }
  }

  final List<String> units = [
    'Milliliters', 'Liters', 'Grams', 'Kilograms', 'Pieces', 'Packs', 'Cans',
    'Bottles', // ... add more units
  ];

  String? selectedUnit;

  @override
  Widget build(BuildContext context) {
    initSizeConfig(context); // Make sure to call this before using SizeConfig
    return Scaffold(
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(width: propWidth(10)),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Image.asset(
                        'assets/images/Prvs.png',
                        width: propWidth(30),
                        height: propHeight(30),
                      ),
                    ),
                    Expanded(child: Container()),
                    Text(
                      'Add Item',
                      style: AppFonts.appname,
                    ),
                    Expanded(child: Container()),
                    ElevatedButton(
                      style: ButtonStyle(
                          elevation: MaterialStateProperty.all(0),
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(17.0)))),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          createItem();
                          // Call the function to save the new item
                        }
                      },
                      child: Text('ADD'),
                    ),
                    SizedBox(width: propWidth(10)),
                    ElevatedButton(
                      style: ButtonStyle(
                          elevation: MaterialStateProperty.all(0),
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(17.0)))),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OCRPage(),
                          ),
                        );
                      },
                      child: Icon(Icons.receipt_long_rounded),
                    ),
                    SizedBox(width: propWidth(10)),
                  ],
                ),
                SizedBox(height: propHeight(10)),
                TextFormField(
                  controller: _itemNameController,
                  decoration: InputDecoration(
                    labelText: 'Item Name',
                    fillColor: AppColors.light,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        propHeight(17),
                      ),
                    ),
                  ),
                  onSaved: (newValue) {
                    newItem?.itemName = newValue ?? '';
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter item name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: propHeight(10)),
                buildCategoryDropdown(),
                SizedBox(height: propHeight(10)),
                TextFormField(
                  controller: _nfcTagIdController,
                  decoration: InputDecoration(
                    labelText: 'NFC Tag ID',
                    fillColor: AppColors.light,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        propHeight(17),
                      ),
                    ),
                  ),
                  onSaved: (newValue) {
                    newItem?.nfcTagID = newValue ?? '';
                  },
                ),
                SizedBox(height: propHeight(10)),
                InkWell(
                  onTap: () {
                    _selectDate(context, selectedPDate ?? DateTime.now(),
                        (newDate) {
                      setState(() {
                        selectedPDate = newDate;
                        _pDateController.text =
                            DateFormat('yyyy-MM-dd').format(newDate);
                      });
                    });
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Production Date',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(propHeight(17))),
                    ),
                    child: Text(selectedPDate == null
                        ? 'Select Date'
                        : DateFormat('yyyy-MM-dd').format(selectedPDate!)),
                  ),
                ),
                SizedBox(height: propHeight(10)),
                InkWell(
                  onTap: () {
                    _selectDate(context, selectedXDate ?? DateTime.now(),
                        (newDate) {
                      setState(() {
                        selectedXDate = newDate;
                        _xDateController.text =
                            DateFormat('yyyy-MM-dd').format(newDate);
                      });
                    });
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Expiration Date',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(propHeight(17))),
                    ),
                    child: Text(selectedXDate == null
                        ? 'Select Date'
                        : DateFormat('yyyy-MM-dd').format(selectedXDate!)),
                  ),
                ),
                SizedBox(height: propHeight(10)),
                InkWell(
                  onTap: () {
                    _selectDate(context, selectedInDate, (newDate) {
                      setState(() {
                        selectedInDate = newDate;
                        _inDateController.text =
                            DateFormat('yyyy-MM-dd').format(newDate);
                      });
                    });
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Insertion Date',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(propHeight(17))),
                    ),
                    child:
                        Text(DateFormat('yyyy-MM-dd').format(selectedInDate)),
                  ),
                ),
                SizedBox(height: propHeight(10)),
                TextFormField(
                  controller: _itemInfoController,
                  decoration: InputDecoration(
                    labelText: 'Item Info',
                    fillColor: AppColors.light,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        propHeight(17),
                      ),
                    ),
                  ),
                  onSaved: (newValue) {
                    newItem?.itemInfo = newValue ?? '';
                  },
                ),
                SizedBox(height: propHeight(10)),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  onChanged: (newValue) {
                    setState(() {
                      selectedStatus = newValue;
                    });
                  },
                  items: <String>[
                    'Fresh',
                    'Old',
                    'Expired',
                    'Better Used Soon',
                    'Damaged'
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(propHeight(17))),
                  ),
                ),
                SizedBox(height: propHeight(10)),
                TextFormField(
                  controller: _quantityController,
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        propHeight(17),
                      ),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onSaved: (newValue) {
                    newItem?.quantity = int.tryParse(newValue ?? '0') ?? 1;
                  },
                ),
                SizedBox(height: propHeight(10)),
                DropdownButtonFormField<String>(
                  value: selectedUnit,
                  onChanged: (newValue) {
                    setState(() {
                      selectedUnit = newValue!;
                    });
                  },
                  items: units.map<DropdownMenuItem<String>>((String unit) {
                    return DropdownMenuItem<String>(
                      value: unit,
                      child: Text(unit),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: 'Unit',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: propWidth(20),
                      vertical: propHeight(15),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(propHeight(17)),
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                    filled: true,
                    fillColor: AppColors.light,
                  ),
                ),
                SizedBox(height: propHeight(10)),
                buildKitchenDropdown(),
                SizedBox(height: propHeight(10)),
                buildDeviceDropdown(),
                SizedBox(height: propHeight(10)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Build a Dropdown button for kitchens
  Widget buildKitchenDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedKitchen,
      onChanged: (value) async {
        if (value != null) {
          selectedKitchen = value;
          var kitchen = kitchens.firstWhere((k) => k.kitchenID == value);
          devices = await kitchen.loadDevices();
          selectedDevice = devices.isNotEmpty ? devices.first.deviceID : null;
          categories = selectedDevice != null
              ? await devices.first.loadCategories(devices.first.categoriesFile)
              : [];
          selectedCategory =
              categories.isNotEmpty ? categories.first.categoryID : null;
        } else {
          devices = [];
          categories = [];
          selectedDevice = null;
          selectedCategory = null;
        }
        setState(() {});
      },
      items: kitchens.map<DropdownMenuItem<String>>((Kitchen kitchen) {
        return DropdownMenuItem<String>(
          value: kitchen.kitchenID,
          child: Text(kitchen.kitchenName),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: 'Select Kitchen',
        fillColor: AppColors.light,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            propHeight(17),
          ),
        ),
      ),
    );
  }

  // Build a Dropdown button for devices
  Widget buildDeviceDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedDevice,
      onChanged: (value) async {
        if (value != null) {
          selectedDevice = value;
          var device = devices.firstWhere((d) => d.deviceID == value);
          categories = await device.loadCategories(device.categoriesFile);
          selectedCategory =
              categories.isNotEmpty ? categories.first.categoryID : null;
        } else {
          categories = [];
          selectedCategory = null;
        }
        setState(() {});
      },
      items: devices.map<DropdownMenuItem<String>>((Device device) {
        return DropdownMenuItem<String>(
          value: device.deviceID,
          child: Text(device.deviceName),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: 'Select Device',
        fillColor: AppColors.light,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            propHeight(17),
          ),
        ),
      ),
    );
  }

  // Build a Dropdown button for categories
  Widget buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedCategory, // This should be the category ID
      onChanged: (String? newValue) {
        setState(() {
          selectedCategory = newValue; // newValue is the category ID
        });
      },
      items: categories.map<DropdownMenuItem<String>>((Category category) {
        return DropdownMenuItem<String>(
          value: category.categoryID, // Keep using categoryID as the value
          child:
              Text(category.categoryName), // Display categoryName to the user
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: 'Select Category',
        fillColor: AppColors.light,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            propHeight(17),
          ),
        ),
        // Display a hint text if no categories are available yet
        hintText: categories.isEmpty ? 'Please select a device first' : null,
      ),
      // Disable the dropdown if no categories are loaded yet
      disabledHint: Text('No categories available'),
      // Enable dropdown only if categories are available
    );
  }

  // return DropdownButtonFormField<String>(
  //   value: selectedCategory,
  //   onSaved: (newValue) => selectedCategory = newValue!,
  //   onChanged: (newValue) {
  //     setState(() {
  //       selectedCategory = newValue!;
  //     });
  //   },
  //   items: categories.map<DropdownMenuItem<String>>((Category category) {
  //     return DropdownMenuItem<String>(
  //       value: category.categoryID,
  //       child: Text(category.categoryName),
  //     );
  //   }).toList(),
  //   decoration: InputDecoration(
  //     labelText: 'Select Category',
  //     contentPadding: EdgeInsets.symmetric(
  //         horizontal: propWidth(20), vertical: propHeight(15)),
  //     border: OutlineInputBorder(
  //       borderRadius: BorderRadius.circular(propHeight(17)),
  //       borderSide: BorderSide(color: AppColors.primary),
  //     ),
  //     filled: true,
  //     fillColor: AppColors.light,
  //   ),
  // );
}

OverlayEntry _createOverlayEntry(BuildContext context, String itemName) {
  return OverlayEntry(
    builder: (context) => Positioned(
      top: MediaQuery.of(context).size.height * 0.5,
      left: MediaQuery.of(context).size.width * 0.25,
      width: MediaQuery.of(context).size.width * 0.5,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(17),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.light,
                child: Icon(Icons.check, size: 50, color: AppColors.primary),
              ),
              SizedBox(height: propHeight(10)),
              Text(
                '$itemName Added',
                style: AppFonts.locCard,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
