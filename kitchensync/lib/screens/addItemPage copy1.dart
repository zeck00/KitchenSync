// ignore_for_file: file_names, use_super_parameters, library_private_types_in_public_api, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:kitchensync/backend/dataret.dart';

class AddItemPage extends StatefulWidget {
  const AddItemPage({Key? key}) : super(key: key);

  @override
  _AddItemPageState createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<Kitchen> kitchens = [];
  List<Device> devices = [];
  List<Category> categories = [];
  String? selectedKitchen;
  String? selectedDevice;
  String? selectedCategory;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Item'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                if (kitchens.isNotEmpty) ...[
                  DropdownButtonFormField<String>(
                    value: selectedKitchen,
                    onChanged: (value) async {
                      selectedKitchen = value;
                      var kitchen =
                          kitchens.firstWhere((k) => k.kitchenID == value);
                      devices = await kitchen.loadDevices();
                      if (devices.isNotEmpty) {
                        selectedDevice = devices.first.deviceID;
                        categories = await devices.first
                            .loadCategories(devices.first.categoriesFile);
                        if (categories.isNotEmpty) {
                          selectedCategory = categories.first.categoryID;
                        }
                      }
                      setState(() {});
                    },
                    items: kitchens
                        .map<DropdownMenuItem<String>>((Kitchen kitchen) {
                      return DropdownMenuItem<String>(
                        value: kitchen.kitchenID,
                        child: Text(kitchen.kitchenName),
                      );
                    }).toList(),
                  ),
                  if (devices.isNotEmpty) ...[
                    DropdownButtonFormField<String>(
                      value: selectedDevice,
                      onChanged: (value) async {
                        selectedDevice = value;
                        var device =
                            devices.firstWhere((d) => d.deviceID == value);
                        categories =
                            await device.loadCategories(device.categoriesFile);
                        if (categories.isNotEmpty) {
                          selectedCategory = categories.first.categoryID;
                        }
                        setState(() {});
                      },
                      items: devices
                          .map<DropdownMenuItem<String>>((Device device) {
                        return DropdownMenuItem<String>(
                          value: device.deviceID,
                          child: Text(device.deviceName),
                        );
                      }).toList(),
                    ),
                  ],
                  if (categories.isNotEmpty) ...[
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      onChanged: (value) {
                        selectedCategory = value;
                        setState(() {});
                      },
                      items: categories
                          .map<DropdownMenuItem<String>>((Category category) {
                        return DropdownMenuItem<String>(
                          value: category.categoryID,
                          child: Text(category.categoryName),
                        );
                      }).toList(),
                    ),
                  ],
                ],
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      // Implement item addition logic here
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
}
