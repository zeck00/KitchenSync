// ignore_for_file: prefer_final_fields, unused_import, library_private_types_in_public_api, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:kitchensync/backend/dataret.dart';
import 'package:kitchensync/screens/size_config.dart';

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});

  @override
  _AddItemPageState createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late List<Kitchen> kitchens;
  late List<Device> devices;
  late List<Category> categories;
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

  Future<void> loadCategoriesForDevice(String deviceId) async {
    var device = devices.firstWhere((device) => device.deviceID == deviceId);
    await device.loadCategories('assets/data/${device.categoriesFile}');
    setState(() {
      categories = device.categories;
      selectedCategory =
          categories.isNotEmpty ? categories.first.categoryID : null;
    });
  }

  String generateItemId() {
    // Using DateTime to generate a unique ID for simplicity.
    // In a production scenario, consider a more robust method for ID generation.
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

  fetchInitialData() async {
    kitchens = await Kitchen.fetchKitchens('assets/data/kitchens.json');
    // Assuming the first kitchen is the default
    selectedKitchen = kitchens.first.kitchenID;
    await kitchens.first.loadDevices();
    devices = kitchens.first.devices;
    selectedDevice = devices.first.deviceID;
    await devices.first
        .loadCategories('assets/data/${devices.first.categoriesFile}');
    categories = devices.first.categories;
    selectedCategory = categories.first.categoryID;

    // Once data is fetched, refresh the state to update the UI
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    initSizeConfig(context); // Make sure to call this before using SizeConfig
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Item'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                buildKitchenDropdown(),
                buildDeviceDropdown(),
                buildCategoryDropdown(),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Item Name'),
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
                TextFormField(
                  decoration: InputDecoration(labelText: 'NFC Tag ID'),
                  onSaved: (newValue) {
                    newItem?.nfcTagID = newValue ?? '';
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Purchase Date'),
                  onSaved: (newValue) {
                    newItem?.pDate = newValue ?? '';
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Expiration Date'),
                  onSaved: (newValue) {
                    newItem?.xDate = newValue ?? '';
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Insertion Date'),
                  onSaved: (newValue) {
                    newItem?.inDate = newValue ?? '';
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Item Info'),
                  onSaved: (newValue) {
                    newItem?.itemInfo = newValue ?? '';
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Status'),
                  onSaved: (newValue) {
                    newItem?.status = newValue ?? '';
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Quantity'),
                  keyboardType: TextInputType.number,
                  onSaved: (newValue) {
                    newItem?.quantity = int.tryParse(newValue ?? '0') ?? 0;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Unit'),
                  onSaved: (newValue) {
                    newItem?.unit = newValue ?? '';
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      createItem();
                      // Call the function to save the new item
                    }
                  },
                  child: Text('Add Item'),
                )
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
      decoration: InputDecoration(labelText: 'Select Kitchen'),
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
      decoration: InputDecoration(labelText: 'Select Device'),
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
      decoration: InputDecoration(labelText: 'Select Category'),
    );
  }
}
