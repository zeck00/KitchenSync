// ignore_for_file: prefer_final_fields, unused_import, unnecessary_null_comparison, avoid_print, prefer_const_constructors, library_private_types_in_public_api, file_names

import 'package:flutter/material.dart';
import 'package:kitchensync/backend/dataret.dart';
import 'package:kitchensync/screens/appBar.dart';
import 'package:kitchensync/screens/size_config.dart';
import 'package:kitchensync/styles/AppColors.dart';
import 'package:kitchensync/styles/AppFonts.dart';

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
    // Using DateTime to generate a unique ID for simplicity.
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  void createItem() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Create a new item using the controllers
      newItem = Item(
        itemID: generateItemId(),
        itemName: _itemNameController.text,
        nfcTagID: _nfcTagIdController.text,
        pDate: _pDateController.text,
        xDate: _xDateController.text,
        inDate: _inDateController.text,
        itemInfo: _itemInfoController.text,
        status: _statusController.text,
        category: selectedCategory ?? '',
        quantity: int.tryParse(_quantityController.text) ?? 0,
        unit: _unitController.text,
      );

      addItemToSelectedDevice(newItem!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Item Added: ${newItem!.itemName}')),
      );

      clearFormFields();
    }
  }

  void addItemToSelectedDevice(Item item) {
    // Add your logic to add the item to the selected device's list
    // Update the JSON file with the new list of items
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
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    try {
      kitchens = await Kitchen.fetchKitchens('assets/data/kitchens.json');
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
      devices = await kitchen.loadDevices();
      if (devices.isNotEmpty) {
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
                  ],
                ),
                SizedBox(height: propHeight(10)),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Item Name',
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
                  decoration: InputDecoration(
                    labelText: 'NFC Tag ID',
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
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Purchase Date',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        propHeight(17),
                      ),
                    ),
                  ),
                  onSaved: (newValue) {
                    newItem?.pDate = newValue ?? '';
                  },
                ),
                SizedBox(height: propHeight(10)),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Expiration Date',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        propHeight(17),
                      ),
                    ),
                  ),
                  onSaved: (newValue) {
                    newItem?.xDate = newValue ?? '';
                  },
                ),
                SizedBox(height: propHeight(10)),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Insertion Date',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        propHeight(17),
                      ),
                    ),
                  ),
                  onSaved: (newValue) {
                    newItem?.inDate = newValue ?? '';
                  },
                ),
                SizedBox(height: propHeight(10)),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Item Info',
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
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        propHeight(17),
                      ),
                    ),
                  ),
                  onSaved: (newValue) {
                    newItem?.status = newValue ?? '';
                  },
                ),
                SizedBox(height: propHeight(10)),
                TextFormField(
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
                    newItem?.quantity = int.tryParse(newValue ?? '0') ?? 0;
                  },
                ),
                SizedBox(height: propHeight(10)),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Unit',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        propHeight(17),
                      ),
                    ),
                  ),
                  onSaved: (newValue) {
                    newItem?.unit = newValue ?? '';
                  },
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
      onSaved: (newValue) => selectedKitchen = newValue!,
      onChanged: (newValue) {
        setState(() {
          selectedKitchen = newValue!;
          // TODO: Load devices based on selected kitchen
        });
      },
      items: kitchens.map<DropdownMenuItem<String>>((Kitchen kitchen) {
        return DropdownMenuItem<String>(
          value: kitchen.kitchenID,
          child: Text(kitchen.kitchenName),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: 'Select Kitchen',
        contentPadding: EdgeInsets.symmetric(
            horizontal: propWidth(20), vertical: propHeight(15)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(propHeight(17)),
          borderSide: BorderSide(color: AppColors.primary),
        ),
        filled: true,
        fillColor: AppColors.light,
      ),
    );
  }

  // TODO: Add methods to build Device and Category dropdowns, and fields for Item details

  // Build a Dropdown button for devices
  Widget buildDeviceDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedDevice,
      onSaved: (newValue) => selectedDevice = newValue!,
      onChanged: (newValue) async {
        setState(() {
          selectedDevice = newValue!;
          categories = []; // Clear categories when device changes
        });
        // Find the selected device
        var selectedDeviceObj = devices.firstWhere(
          (device) => device.deviceID == selectedDevice,
          orElse: () =>
              Device(deviceID: '', deviceName: '', categoriesFile: ''),
        );
        await selectedDeviceObj
            .loadCategories('assets/data/${selectedDeviceObj.categoriesFile}');
        setState(() {
          categories = selectedDeviceObj.categories;
          selectedCategory =
              categories.isNotEmpty ? categories.first.categoryID : null;
        });
      },
      items: devices.map<DropdownMenuItem<String>>((Device device) {
        return DropdownMenuItem<String>(
          value: device.deviceID,
          child: Text(device.deviceName),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: 'Select Device',
        contentPadding: EdgeInsets.symmetric(
            horizontal: propWidth(20), vertical: propHeight(15)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(propHeight(17)),
          borderSide: BorderSide(color: AppColors.primary),
        ),
        filled: true,
        fillColor: AppColors.light,
      ),
    );
  }

  // Build a Dropdown button for categories
  Widget buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedCategory,
      onSaved: (newValue) => selectedCategory = newValue!,
      onChanged: (newValue) {
        setState(() {
          selectedCategory = newValue!;
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
            horizontal: propWidth(20), vertical: propHeight(15)),
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
