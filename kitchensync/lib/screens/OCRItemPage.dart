// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, file_names, library_private_types_in_public_api, unused_field, avoid_print, no_leading_underscores_for_local_identifiers, unnecessary_null_comparison, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:intl/intl.dart';
import 'package:kitchensync/backend/const.dart';
import 'package:kitchensync/backend/dataret.dart';
import 'package:kitchensync/screens/ErrorPage.dart';
import 'package:kitchensync/screens/appBar.dart';
import 'package:kitchensync/styles/size_config.dart';
import 'package:kitchensync/styles/AppColors.dart';
import 'package:kitchensync/styles/AppFonts.dart';
import 'package:flutter_pro_barcode_scanner/flutter_pro_barcode_scanner.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:nfc_manager/nfc_manager.dart';

class AddOrOCRItemPage extends StatefulWidget {
  const AddOrOCRItemPage({super.key});

  @override
  _AddOrOCRItemPageState createState() => _AddOrOCRItemPageState();
}

class _AddOrOCRItemPageState extends State<AddOrOCRItemPage> {
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

  final List<String> _units = [
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
        pDate: _pDateController.text,
        xDate: _xDateController.text,
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

  void showCustomMessageOverlay(BuildContext context, String message,
      IconData icon, Color backgroundColor) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.5,
        left: MediaQuery.of(context).size.width * 0.25,
        width: MediaQuery.of(context).size.width * 0.5,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(17),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.light,
                  child: Icon(icon, size: 50, color: AppColors.primary),
                ),
                SizedBox(height: 20),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(Duration(seconds: 3)).then((value) => overlayEntry.remove());
  }

  Future<void> fetchProductDetails(String barcode) async {
    final String url =
        'https://world.openfoodfacts.org/api/v0/product/$barcode.json';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final productData = json.decode(response.body);
        if (productData['status'] == 1) {
          // Product found
          final product = productData['product'];
          setState(() {
            _itemNameController.text =
                product['product_name'] ?? 'Unknown Product';
            _itemInfoController.text =
                product['ingredients_text'] ?? 'No ingredients information';
            // Add more fields as needed
          });
        } else {
          showCustomMessageOverlay(
              context, "Product not found", Icons.error, Colors.red);
          print('Product not found');
        }
      } else {
        showCustomMessageOverlay(context, "Failed to fetch product details.",
            Icons.cloud_off, Colors.red);
        print('Failed to fetch product details.');
      }
    } catch (e) {
      print('Error fetching product details: $e');
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => ErrorScreen()));
    }
  }

  void scanBarcode(TextEditingController _itemName) async {
    String scannedCode = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => const ScannerScreen()));

    if (scannedCode.isNotEmpty) {
      fetchProductDetails(scannedCode);
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

  // Method to pick an image, recognize text, and extract date using GPT-3
  Future<void> pickImageAndRecognizeText(
      TextEditingController controller, bool isDate) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      final inputImage = InputImage.fromFilePath(image.path);
      final textRecognizer =
          TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);

      print("Recognized text: ${recognizedText.text}"); // Debug output

      if (isDate) {
        // If the recognized text is supposed to be a date, ask GPT-3 to extract and format it
        fetchDateFromGPT(recognizedText.text, controller);
      } else {
        // Update the controller directly for non-date text
        setState(() {
          controller.text = recognizedText.text;
        });
      }
    }
  }

  // Method to call GPT-3 to extract and format the date from text
  Future<void> fetchDateFromGPT(
      String recognizedText, TextEditingController dateController) async {
    final List<Map<String, dynamic>> messages = [
      {
        "role": "system",
        "content":
            "Extract the date from the following text and format it as 'yyyy-MM-dd'."
      },
      {
        "role": "user",
        "content": recognizedText,
      },
    ];

    final Map<String, dynamic> body = {
      "model": "gpt-3.5-turbo",
      "messages": messages,
    };

    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiKeys.LapiKey}',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final String botReply =
            responseData['choices'][0]['message']['content'].trim();

        DateTime? parsedDate = DateFormat('yyyy-MM-dd').parseStrict(botReply);
        if (parsedDate != null) {
          // Update the date field only if the date was successfully parsed
          setState(() {
            dateController.text = DateFormat('yyyy-MM-dd').format(parsedDate);
          });
        } else {
          print("Date could not be parsed");
        }
      } else {
        print('API call failed with status: ${response.statusCode}');
        print('Error response: ${response.body}');
      }
    } catch (e) {
      print('Error sending message to ChatGPT: $e');
    }
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
  void initState() {
    super.initState();
    loadInitialData();
  }

  DateTime selectedInDate = DateTime.now();
  String? selectedStatus;
  Timer? _timeoutTimer;
  OverlayEntry? _overlayEntry;
  String? selectedUnit;

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
  void dispose() {
    _itemNameController.dispose();
    _pDateController.dispose();
    _xDateController.dispose();
    _inDateController.dispose();
    _itemInfoController.dispose();
    _quantityController.dispose();
    _timeoutTimer?.cancel();
    _overlayEntry?.remove();
    NfcManager.instance.stopSession();
    super.dispose();
  }

  void _showNfcReadOverlay() {
    _overlayEntry = _createNfcOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  OverlayEntry _createNfcOverlayEntry() {
    return OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height / 2 - 50,
        left: MediaQuery.of(context).size.width / 2 - 50,
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(17),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircularProgressIndicator(
                    strokeWidth: 5,
                    color: AppColors.green,
                    strokeCap: StrokeCap.round,
                  ),
                  SizedBox(height: 16),
                  Text("Reading NFC...", style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void startNFCSession() async {
    bool isAvailable = await NfcManager.instance.isAvailable();
    if (!isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.nearby_error_rounded, color: AppColors.light),
              Text("NFC is not available on this device"),
            ],
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    _showNfcReadOverlay();
    _timeoutTimer = Timer(Duration(seconds: 10), () {
      _updateOverlayForFailure(); // Update the overlay to show failure
    }); // Show the overlay

    try {
      await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          _timeoutTimer?.cancel(); // Cancel the timer on successful read
          final ndef = Ndef.from(tag);
          if (ndef?.cachedMessage == null) return;
          for (final record in ndef!.cachedMessage!.records) {
            String recordData = String.fromCharCodes(record.payload);
            String jsonPayload = recordData.substring(3);
            Map<String, dynamic> data = json.decode(jsonPayload);
            print('NFC Record Data: $recordData');

            setState(() {
              _itemNameController.text = data['itemName'] ?? '';
              _nfcTagIdController.text = data['nfcTagId'] ?? '';

              // Use the correct format that matches the NFC record's date format
              if (data.containsKey('pDate') && data['pDate'].isNotEmpty) {
                DateTime pDate = DateFormat('yyyy/MM/dd').parse(data['pDate']);
                _pDateController.text = DateFormat('yyyy-MM-dd').format(pDate);
              }

              if (data.containsKey('xDate') && data['xDate'].isNotEmpty) {
                DateTime xDate = DateFormat('yyyy/MM/dd').parse(data['xDate']);
                _xDateController.text = DateFormat('yyyy-MM-dd').format(xDate);
              }

              _itemInfoController.text = data['itemInfo'] ?? '';
              _selectedStatus = data['status'] ?? '';
              _quantityController.text = data['quantity'].toString();
              selectedUnit =
                  _units.contains(data['unit']) ? data['unit'] : null;
              selectedStatus = [
                'Fresh',
                'Old',
                'Expired',
                'Better Used Soon',
                'Damaged'
              ].firstWhere((status) => status == data['status'],
                  orElse: () => 'Fresh');
            });
          }

          NfcManager.instance.stopSession();
          _overlayEntry?.remove();
          _overlayEntry = null;
        },
        pollingOptions: {
          NfcPollingOption.iso14443,
          NfcPollingOption.iso15693,
          NfcPollingOption.iso18092
        },
      );
    } catch (e) {
      _timeoutTimer?.cancel();
      _updateOverlayForFailure();
      print('Error: $e');
    }
  }

  void _updateOverlayForFailure() {
    _overlayEntry?.remove(); // Remove any existing overlay
    _overlayEntry = _createFailureOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);

    // Set a timer to remove the failure overlay after a duration.
    Future.delayed(Duration(seconds: 2)).then((_) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
  }

  OverlayEntry _createFailureOverlayEntry() {
    return OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height / 2 - 50,
        left: MediaQuery.of(context).size.width / 2 - 50,
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                color: AppColors.red,
                borderRadius: BorderRadius.circular(17),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.nearby_error_rounded,
                      color: Colors.white, size: 50),
                  SizedBox(height: propHeight(10)),
                  Text("Couldn't Read", style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
                      'Add or OCR an Item',
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
                      onPressed: startNFCSession,
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(10),
                      ),
                      child: Icon(Icons.nfc_rounded),
                    ),
                    SizedBox(width: propWidth(10)),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _itemNameController,
                        decoration: InputDecoration(
                          labelText: 'Item Name',
                          fillColor: AppColors.light,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(propHeight(17)),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon:
                          Icon(Icons.camera_alt_rounded, color: AppColors.dark),
                      onPressed: () =>
                          pickImageAndRecognizeText(_itemNameController, false),
                    ),
                    IconButton(
                      icon: Icon(Icons.barcode_reader, color: AppColors.dark),
                      onPressed: () => scanBarcode(_itemNameController),
                    ),
                  ],
                ),
                SizedBox(height: propHeight(10)),
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _pDateController,
                            decoration: InputDecoration(
                              labelText: 'Production Date',
                              fillColor: AppColors.light,
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(propHeight(17)),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.camera_alt),
                          onPressed: () =>
                              pickImageAndRecognizeText(_pDateController, true),
                        ),
                      ],
                    ),
                    SizedBox(height: propHeight(10)),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _xDateController,
                            decoration: InputDecoration(
                              labelText: 'Expiry Date',
                              fillColor: AppColors.light,
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(propHeight(17)),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.camera_alt),
                          onPressed: () =>
                              pickImageAndRecognizeText(_xDateController, true),
                        ),
                      ],
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
                SizedBox(height: propHeight(10)),
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
                  onChanged: (newValue) async {
                    if (newValue != null) {
                      selectedKitchen = newValue;
                      var kitchen =
                          kitchens.firstWhere((k) => k.kitchenID == newValue);
                      devices = await kitchen.loadDevices();
                      selectedDevice =
                          devices.isNotEmpty ? devices.first.deviceID : null;
                      categories = selectedDevice != null
                          ? await devices.first
                              .loadCategories(devices.first.categoriesFile)
                          : [];
                      selectedCategory = categories.isNotEmpty
                          ? categories.first.categoryID
                          : null;
                    } else {
                      devices = [];
                      categories = [];
                      selectedDevice = null;
                      selectedCategory = null;
                    }
                    setState(() {});
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
                  onChanged: (newValue) async {
                    if (newValue != null) {
                      selectedDevice = newValue;
                      var device =
                          devices.firstWhere((d) => d.deviceID == newValue);
                      categories =
                          await device.loadCategories(device.categoriesFile);
                      selectedCategory = categories.isNotEmpty
                          ? categories.first.categoryID
                          : null;
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
              ],
            ),
          ),
        ),
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

void showOverlay(BuildContext context) async {
  OverlayState overlayState = Overlay.of(context);
  OverlayEntry overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: MediaQuery.of(context).size.height / 2 - 100,
      left: MediaQuery.of(context).size.width / 2 - 100,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            'Item Added',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ),
    ),
  );

  overlayState.insert(overlayEntry);

  // Wait for 3 seconds and remove the overlay
  await Future.delayed(Duration(seconds: 3));
  overlayEntry.remove();
}
