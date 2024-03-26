// Import statements remain the same
// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:intl/intl.dart';
import 'package:kitchensync/backend/dataret.dart';
import 'package:kitchensync/screens/appBar.dart';
import 'package:kitchensync/screens/itemsPage.dart';
import 'package:kitchensync/styles/size_config.dart';
import 'package:kitchensync/styles/AppColors.dart';
import 'package:kitchensync/styles/AppFonts.dart';
import 'package:path_provider/path_provider.dart';

class OCRItemPage extends StatefulWidget {
  const OCRItemPage({Key? key}) : super(key: key);

  @override
  _OCRItemPageState createState() => _OCRItemPageState();
}

class _OCRItemPageState extends State<OCRItemPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _pDateController = TextEditingController();
  final TextEditingController _xDateController = TextEditingController();
  final TextEditingController _nfcTagIdController = TextEditingController();
  final TextEditingController _inDateController =
      TextEditingController(); // For manual entry
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _itemInfoController =
      TextEditingController(); // For manual entry
  final TextEditingController _quantityController =
      TextEditingController(); // For manual entry
  String _selectedStatus = 'Fresh'; // Defaulted to 'Fresh'
  String? selectedKitchen;
  String? selectedDevice;
  String? selectedCategory;
  Item? newItem;

  List<String> _units = [
    'Milliliters',
    'Liters',
    'Grams',
    'Kilograms',
    'Pieces',
    'Packs',
    'Cans',
    'Bottles'
  ]; // Units
  String? _selectedUnit;
  final ImagePicker _picker = ImagePicker();

  // Assuming you have predefined lists for kitchens, devices, and categories
  List<Kitchen> kitchens = []; // Populate with your data
  List<Device> devices = []; // Populate based on selected kitchen
  List<Category> categories = []; // Populate based on selected device
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
        unit: _selectedUnit ?? '',
      );

      addNewItem(newItem!);

      _showCustomOverlay(
          context, newItem!.itemName); // Pass the item name dynamically

      clearFormFields();

      _showCustomOverlay(context, newItem!.itemName);
    }
  }

  void clearFormFields() {
    _itemNameController.clear();
    _pDateController.clear();
    _xDateController.clear();
    _inDateController.clear();
    _itemInfoController.clear();
    _quantityController.clear();
    _unitController.clear();
    _selectedStatus = 'null';
    selectedKitchen = null;
    selectedDevice = null;
    selectedCategory = null;
    newItem = null;
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

  Future<void> pickImageAndRecognizeText(
      TextEditingController controller) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      final inputImage = InputImage.fromFilePath(image.path);
      final textRecognizer =
          TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);
      setState(() {
        controller.text = recognizedText.text;
      });
    }
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

  @override
  Widget build(BuildContext context) {
    initSizeConfig(context);
    return Scaffold(
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
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
                      'OCR an Item',
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
                  ],
                ),
                TextFormField(
                  controller: _itemNameController,
                  decoration: InputDecoration(
                    labelText: 'Item Name',
                    suffixIcon: IconButton(
                      icon:
                          Icon(Icons.camera_alt_rounded, color: AppColors.dark),
                      onPressed: () =>
                          pickImageAndRecognizeText(_itemNameController),
                    ),
                    fillColor: AppColors.light,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        propHeight(17),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: propHeight(10)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _pDateController,
                        decoration: InputDecoration(
                          labelText: 'Production Date',
                          suffixIcon: IconButton(
                            icon: Icon(Icons.camera_alt_rounded,
                                color: AppColors.dark),
                            onPressed: () =>
                                pickImageAndRecognizeText(_pDateController),
                          ),
                          fillColor: AppColors.light,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              propHeight(17),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _xDateController,
                        decoration: InputDecoration(
                          labelText: 'Expiration Date',
                          suffixIcon: IconButton(
                            icon: Icon(Icons.camera_alt_rounded,
                                color: AppColors.dark),
                            onPressed: () =>
                                pickImageAndRecognizeText(_xDateController),
                          ),
                          fillColor: AppColors.light,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              propHeight(17),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
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
                // Dropdowns for category, kitchen, and device
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  onChanged: (newValue) {
                    setState(() {
                      selectedCategory = newValue!;
                    });
                  },
                  items: categories
                      .map<DropdownMenuItem<String>>((Category category) {
                    return DropdownMenuItem<String>(
                      value: category.categoryID,
                      child: Text(category.categoryName),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: 'Category',
                    fillColor: AppColors.light,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        propHeight(17),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: propHeight(10)),
                DropdownButtonFormField<String>(
                  value: selectedKitchen,
                  onChanged: (newValue) {
                    setState(() {
                      selectedKitchen = newValue;
                      // This is where you would also update the devices list based on the selected kitchen
                    });
                  },
                  items:
                      kitchens.map<DropdownMenuItem<String>>((Kitchen kitchen) {
                    return DropdownMenuItem<String>(
                      value: kitchen.kitchenID,
                      child: Text(kitchen.kitchenName),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: 'Kitchen',
                    fillColor: AppColors.light,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        propHeight(17),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: propHeight(10)),
                DropdownButtonFormField<String>(
                  value: selectedDevice,
                  onChanged: (newValue) {
                    setState(() {
                      selectedDevice = newValue;
                      // This is where you would also update the categories list based on the selected device
                    });
                  },
                  items: devices.map<DropdownMenuItem<String>>((Device device) {
                    return DropdownMenuItem<String>(
                      value: device.deviceID,
                      child: Text(device.deviceName),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: 'Device',
                    fillColor: AppColors.light,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        propHeight(17),
                      ),
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
                ),
                SizedBox(height: propHeight(10)),
                TextFormField(
                  controller: _quantityController,
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                    fillColor: AppColors.light,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        propHeight(17),
                      ),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
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
                DropdownButtonFormField<String>(
                  value: _selectedUnit,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedUnit = newValue!;
                    });
                  },
                  items: _units.map<DropdownMenuItem<String>>((String unit) {
                    return DropdownMenuItem<String>(
                      value: unit,
                      child: Text(unit),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: 'Unit',
                    fillColor: AppColors.light,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        propHeight(17),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _pDateController.dispose();
    _xDateController.dispose();
    _inDateController.dispose();
    _itemInfoController.dispose();
    _quantityController.dispose();
    super.dispose();
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
