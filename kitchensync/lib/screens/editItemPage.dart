// ignore_for_file: prefer_final_fields, unused_import, unnecessary_null_comparison, avoid_print, prefer_const_constructors, library_private_types_in_public_api, file_names, prefer_const_literals_to_create_immutables, unused_element, unnecessary_import

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:kitchensync/backend/dataret.dart';
import 'package:kitchensync/screens/appBar.dart';
import 'package:kitchensync/styles/size_config.dart';
import 'package:kitchensync/styles/AppColors.dart';
import 'package:kitchensync/styles/AppFonts.dart';
import 'package:path_provider/path_provider.dart';

class EditItemPage extends StatefulWidget {
  final Item itemToEdit;

  const EditItemPage({super.key, required this.itemToEdit});

  @override
  _EditItemPageState createState() => _EditItemPageState();
}

class _EditItemPageState extends State<EditItemPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late List<Kitchen> kitchens = [];
  late List<Device> devices = [];
  late List<Category> categories = [];
  String? selectedKitchen;
  String? selectedDevice;
  String? selectedCategory;
  Item? newItem;

  // Modify your controllers initialization to use the existing item data
  late final TextEditingController _itemNameController =
      TextEditingController(text: widget.itemToEdit.itemName);
  late final TextEditingController _statusController =
      TextEditingController(text: widget.itemToEdit.status);
  late final TextEditingController _nfcTagIdController =
      TextEditingController(text: widget.itemToEdit.nfcTagID);
  late final TextEditingController _pDateController =
      TextEditingController(text: widget.itemToEdit.pDate);
  late final TextEditingController _xDateController =
      TextEditingController(text: widget.itemToEdit.xDate);
  late final TextEditingController _inDateController =
      TextEditingController(text: widget.itemToEdit.inDate);
  late final TextEditingController _itemInfoController =
      TextEditingController(text: widget.itemToEdit.itemInfo);
  late final TextEditingController _quantityController =
      TextEditingController(text: widget.itemToEdit.quantity.toString());
  late final TextEditingController _unitController =
      TextEditingController(text: widget.itemToEdit.unit);

  // This method assumes you have some way to update the item in your data store.
  Future<void> initializeData() async {
    //   final directory = await getApplicationDocumentsDirectory();
    //   final path = directory.path;
    //   final file = File('$path/items.json');

    //   // If the file does not exist in the documents directory, then copy from assets
    //   if (!(await file.exists())) {
    //     // Load the initial JSON data from assets
    //     String data = await rootBundle.loadString('assets/data/items.json');

    //     // Write the data to the documents directory
    //     await file.writeAsString(data);
    //   }
    // }

    // Future<void> updateItem(Item updatedItem) async {
    //   final directory = await getApplicationDocumentsDirectory();
    //   final path = directory.path;
    //   final file = File('$path/items.json');

    //   // Read the current items JSON file
    //   final String response = await file.readAsString();
    //   List<dynamic> data = await json.decode(response);

    //   // Convert the JSON to a list of Items
    //   List<Item> items = List<Item>.from(data.map((item) => Item.fromJson(item)));

    //   // Find and replace the updated item
    //   int index = items.indexWhere((item) => item.itemID == updatedItem.itemID);
    //   if (index != -1) {
    //     items[index] = updatedItem;
    //   } else {
    //     // If the item is not found in the list, it is new so we add it
    //     items.add(updatedItem);
    //   }

    //   String updatedJson =
    //       json.encode(items.map((item) => item.toJson()).toList());

    //   // Write the updated JSON string to the file
    //   await file.writeAsString(updatedJson);
  }

  Future<File> get _localFile async {
    final directory =
        await getApplicationDocumentsDirectory(); // Gets the directory where your app can store files.
    final path = directory.path; // Gets the full path of that directory.
    return File(
        '$path/items.json'); // Creates and returns a File instance pointing to 'items.json' in that directory.
  }

  Future<void> updateItem(Item updatedItem) async {
    final file = await _localFile;

    try {
      List<dynamic> itemsList = [];
      // Check if the file exists and has content
      if (await file.exists() && await file.readAsString() != '') {
        final contents = await file.readAsString();
        final decoded = json.decode(contents);
        if (decoded is Map<String, dynamic> && decoded.containsKey('items')) {
          itemsList = decoded['items'] as List;
        }
      }

      // Find and replace the updated item
      int index =
          itemsList.indexWhere((item) => item['itemID'] == updatedItem.itemID);
      if (index != -1) {
        itemsList[index] = updatedItem.toJson();
      } else {
        // If the item is not found, just add it (or handle this case differently)
        itemsList.add(updatedItem.toJson());
      }

      // Prepare the data in the expected structure
      final Map<String, dynamic> updatedData = {"items": itemsList};

      // Write the updated data back to the file
      await file.writeAsString(json.encode(updatedData));
      print("Item updated successfully: ${updatedItem.itemName}");
    } catch (e) {
      print("Error updating items.json: $e");
    }
  }

  void editItem() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Update the existing item using the controllers
      Item updatedItem = widget.itemToEdit.copyWith(
        itemName: _itemNameController.text,
        nfcTagID: _nfcTagIdController.text,
        pDate: _pDateController.text,
        xDate: _xDateController.text,
        inDate: _inDateController.text,
        itemInfo: _itemInfoController.text,
        status: _statusController.text,
        category: selectedCategory ?? widget.itemToEdit.category,
        quantity: int.tryParse(_quantityController.text) ??
            widget.itemToEdit.quantity,
        unit: _unitController.text,
      );

      updateItem(updatedItem);

      // Show a success message or take other appropriate action
      _showCustomOverlay(context, "${updatedItem.itemName} Edited");
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

  void clearFormFields() {
    // Clear the controllers for the next item entry
    _itemNameController.clear();
    _nfcTagIdController.clear();
    _pDateController.clear();
    _xDateController.clear();
    _inDateController.clear();
    _itemInfoController.clear();
    _statusController.clear();
    _quantityController.clear();
    _unitController.clear();

    // Reset dropdown values
    setState(() {
      selectedCategory = null;
      selectedDevice = null;
      selectedKitchen = null;
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
    // Ensure that the initial status is in the list, or null if not.
    String? initialStatus = widget.itemToEdit.status;
    List<String> statusOptions = [
      'fresh',
      'Fresh',
      'Old',
      'Expired',
      'Better Used Soon',
      'Damaged',
      'Dry',
    ];

    if (!statusOptions.contains(initialStatus)) {
      initialStatus = 'Fresh'; // or some default value like 'Fresh'
    }

    selectedStatus = initialStatus;
    selectedCategory = widget.itemToEdit.category;
    selectedPDate = DateFormat('yyyy-MM-dd').parse(widget.itemToEdit.pDate);
    selectedXDate = DateFormat('yyyy-MM-dd').parse(widget.itemToEdit.xDate);
    selectedInDate = DateFormat('yyyy-MM-dd').parse(widget.itemToEdit.inDate);
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    try {
      kitchens = await Kitchen.fetchKitchens('kitchens.json');
      if (kitchens.isNotEmpty) {
        // Select the first kitchen by default
        selectedKitchen = kitchens.first.kitchenID;
        await loadDevicesForKitchen(selectedKitchen!);
      }
    } catch (e) {
      // Handle errors, perhaps log them or show a message to the user
      print('Error loading initial data: $e');
    }
  }

  Future<void> loadDevicesForKitchen(String kitchenId) async {
    var kitchen = kitchens.firstWhere((k) => k.kitchenID == kitchenId);
    if (kitchen != null) {
      await kitchen.loadDevices();
      if (kitchen.devices.isNotEmpty) {
        // Select the first device by default
        selectedDevice = devices.first.deviceID;
        await loadCategoriesForDevice(selectedDevice!);
      }
    }
  }

  Future<void> loadCategoriesForDevice(String deviceId) async {
    var device = devices.firstWhere((d) => d.deviceID == deviceId);
    if (device != null) {
      categories =
          await device.loadCategories('assets/data/${device.categoriesFile}');
      if (categories.isNotEmpty) {
        // Select the first category by default
        selectedCategory = categories.first.categoryID;
      }
    }
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
                      'Edit Item',
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
                          editItem();
                          // Call the function to save the new item
                        }
                      },
                      child: Text('Edit'),
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
                    child: Text(
                      selectedPDate != null
                          ? DateFormat('yyyy-MM-dd').format(selectedPDate!)
                          : 'Select Date',
                      style: TextStyle(
                          color: Colors.black54), // Add text style if needed
                    ),
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
                    child: Text(
                      selectedPDate != null
                          ? DateFormat('yyyy-MM-dd').format(selectedXDate!)
                          : 'Select Date',
                      style: TextStyle(
                          color: Colors.black54), // Add text style if needed
                    ),
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
                    child: Text(
                      selectedInDate != null
                          ? DateFormat('yyyy-MM-dd').format(selectedInDate)
                          : 'Select Date',
                      style: TextStyle(
                          color: Colors.black54), // Add text style if needed
                    ),
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
                      _statusController.text = newValue!;
                    });
                  },
                  items: <String>[
                    'fresh',
                    'Fresh',
                    'Old',
                    'Expired',
                    'Better Used Soon',
                    'Damaged',
                    'Dry',
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Build a Dropdown button for categories
  Widget buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedCategory, // make sure this is the initially selected value
      onChanged: (newValue) {
        setState(() {
          selectedCategory = newValue;
        });
      },
      items: categories.map<DropdownMenuItem<String>>((Category category) {
        return DropdownMenuItem<String>(
          value: category.categoryID,
          child: Text(category.categoryName),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: 'Select Category',
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
    );
  }
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
                'Edited Successfully!',
                style: AppFonts.locCard,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
