
class Kitchen{
  Kitchen({required this.kitchenID, required this.kitchenName, required this.devicesFile});
  final String kitchenID;
  final String kitchenName;
  final String devicesFile;

  factory Kitchen.fromJson(Map<String, dynamic> data) {
    final kitchenID = data['kitchenID']; // dynamic
    final kitchenName = data['kitchenName']; // dynamic
    final devicesFile = data['devicesFile']; // dynamic
    // implicit cast from dynamic to String
    if (kitchenID is String && kitchenName is String && devicesFile is String) {
    return Kitchen(kitchenID: kitchenID, kitchenName: kitchenName, devicesFile: devicesFile);
  } else {
    throw FormatException('Invalid JSON: $data');
  }
  }
}

class Device{
  Device({required this.deviceID, required this.deviceName, required this.categoriesFile});
  final String deviceID;
  final String deviceName;
  final String categoriesFile;

  factory Device.fromJson(Map<String, dynamic> data) {
    final deviceID = data['DeviceID']; // dynamic
    final deviceName = data['DeviceName']; // dynamic
    final categoriesFile = data['categoriesFile']; // dynamic
    // implicit cast from dynamic to String
    if (deviceID is String && deviceName is String && categoriesFile is String) {
    return Device(deviceID: deviceID, deviceName: deviceName, categoriesFile: categoriesFile);
  } else {
    throw FormatException('Invalid JSON: $data');
  }
  }
}

class Category{
  Category({required this.categoryID, required this.categoryName, required this.itemsFile});
  final String categoryID;
  final String categoryName;
  final String itemsFile;

  factory Category.fromJson(Map<String, dynamic> data) {
    final categoryID = data['categoryID']; // dynamic
    final categoryName = data['categoryName']; // dynamic
    final itemsFile = data['itemsFile']; // dynamic
    // implicit cast from dynamic to String
    if (categoryID is String && categoryName is String && itemsFile is String) {
    return Category(categoryID: categoryID, categoryName: categoryName, itemsFile: itemsFile);
  } else {
    throw FormatException('Invalid JSON: $data');
  }
  }
}

class Item{
  Item({this.nfcTagID, this.pDate, this.inDate, this.itemInfo, this.status, this.quantity, 
  this.unit, required this.itemID, required this.itemName, required this.xDate, required this.category});
  final String itemID;
  final String itemName;
  final String? nfcTagID;
  final String? pDate;
  final String xDate;
  final String? inDate;
  final String? itemInfo;
  final String? status;
  final String category;
  final String? quantity;
  final String? unit;

  factory Item.fromJson(Map<String, dynamic> data) {
    final itemID = data['itemID']; // dynamic
    final itemName = data['itemName']; // dynamic
    final xDate = data['xDate']; // dynamic
    final category = data['category']; // dynamic

    // implicit cast from dynamic to String
    if (itemID is String && itemName is String && xDate is String && category is String) {
    return Item(itemID: itemID, itemName: itemName, xDate: xDate, category: category);
  } else {
    throw FormatException('Invalid JSON: $data');
  }
  }
}
