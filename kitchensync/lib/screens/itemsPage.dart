// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, library_private_types_in_public_api, file_names, unused_field, unused_element, avoid_function_literals_in_foreach_calls, avoid_print

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kitchensync/screens/OCRItemPage.dart';
import 'package:kitchensync/screens/addItemPage.dart';
import 'package:kitchensync/screens/chatPage.dart';
import 'package:kitchensync/screens/customListItem.dart';
import 'package:kitchensync/screens/editItemPage.dart';
import 'package:kitchensync/styles/AppColors.dart';
import 'package:kitchensync/styles/AppFonts.dart';
import 'package:kitchensync/styles/size_config.dart';
import 'package:quickalert/quickalert.dart';
import 'dart:ui' as ui;
import '../backend/dataret.dart';
import 'inventoryPage.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ItemsScreen extends StatefulWidget {
  final String deviceId; // The device ID passed to this screen
  final String deviceName;

  const ItemsScreen({
    super.key,
    required this.deviceId,
    required this.deviceName,
  });

  @override
  _ItemsScreenState createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  bool _isLoading = true;
  List<Category> categories = [];

  void _showPopup(BuildContext context) {
    Navigator.of(context).push(_PopupRoute());
  }

  @override
  void initState() {
    super.initState();
    _loadCategoriesAndItems();
  }

  Future<void> _loadCategoriesAndItems() async {
    final allItems = await Item.loadAllItems('items.json');
    final loadedCategories = await Category.loadCategories('categories.json');
    allItems.forEach((item) {
      print("Item: ${item.itemName}, Category: ${item.category}");
      bool categoryExists =
          loadedCategories.any((cat) => cat.categoryName == item.category);
      if (!categoryExists) {
        print(
            "Warning: No category found for item: ${item.itemName}, Category: ${item.category}");
      }
    });

    // Right after loading all items and categories, before attempting to assign:
    print("Verifying loaded items' categories against known categories...");
    allItems.forEach((item) {
      print("Item: ${item.itemName}, Category: ${item.category}");
      bool categoryExists =
          loadedCategories.any((cat) => cat.categoryName == item.category);
      if (!categoryExists) {
        print(
            "Warning: No category found for item: ${item.itemName}, Category: ${item.category}");
      }
    });

    for (var category in loadedCategories) {
      category.assignItems(allItems);
    }

    for (Item item in allItems) {
      await item.scheduleExpiryNotifications();
    }
    setState(() {
      categories = loadedCategories;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    initSizeConfig(context);

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(
          left: propWidth(25),
          right: propWidth(25),
          top: propHeight(5),
        ),
        child: Column(
          children: [
            SizedBox(height: propHeight(40)), // Add spacing
            Row(
              children: [
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
                  'All Items',
                  style: AppFonts.welcomemsg1,
                ),
                Expanded(child: Container()),
                GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddItemPage()),
                      );
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.add_circle_rounded,
                          color: AppColors.dark,
                          size: propWidth(30),
                        ),
                        SizedBox(width: propHeight(10)),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OCRItemPage(),
                              ),
                            );
                          },
                          child: Icon(
                            Icons.receipt_long_rounded,
                            color: AppColors.dark,
                            size: propWidth(30),
                          ),
                        ),
                      ],
                    )),
              ],
            ),

            Expanded(
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(propWidth(17)),
                    ),
                    color: AppColors.primary,
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        unselectedWidgetColor: AppColors.light,
                      ),
                      child: CustomExpansionTile(category: category),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomExpansionTile extends StatefulWidget {
  final Category category;

  const CustomExpansionTile({super.key, required this.category});

  @override
  _CustomExpansionTileState createState() => _CustomExpansionTileState();
}

class _CustomExpansionTileState extends State<CustomExpansionTile> {
  // Initially set isExpanded to true for default expanded state
  bool isExpanded = true;

  void _deleteItem(Item item) async {
    // Show confirmation dialog
    final confirm = await QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: 'Delete Item',
      backgroundColor: AppColors.light,
      text: 'Are you sure you want to delete the item?',
      barrierDismissible: false,
      cancelBtnText: 'Cancel',
      confirmBtnText: 'Delete',
      confirmBtnColor: AppColors.primary,
      onCancelBtnTap: () => Navigator.of(context).pop(false),
      onConfirmBtnTap: () => Navigator.of(context).pop(true),
      animType: QuickAlertAnimType.slideInUp,
    );

    // await showDialog<bool>(
    //   context: context,
    //   builder: (context) => BackdropFilter(
    //     filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
    //     child: Center(
    //       child: AlertDialog(
    //         shape: ContinuousRectangleBorder(
    //             borderRadius: BorderRadius.circular(propWidth(17))),
    //         backgroundColor: AppColors.light,
    //         title: Text('Delete Item'),
    //         content: Text('Are you sure you want to delete this item?'),
    //         actions: [
    //           TextButton(
    //             child: Text('Cancel'),
    //             onPressed: () => Navigator.of(context).pop(false),
    //           ),
    //           TextButton(
    //             child: Text('Delete', style: TextStyle(color: AppColors.red)),
    //             onPressed: () => Navigator.of(context).pop(true),
    //           ),
    //         ],
    //       ),
    //     ),
    //   ),
    // );

    // If deletion is confirmed
    if (confirm == true) {
      await item.delete();

      // Update the state to reflect the change
      setState(() {
        // Assuming you have a method to remove the item from the category
        widget.category.items.remove(item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final category = widget.category;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(propWidth(17)),
      ),
      color: isExpanded
          ? AppColors.primary
          : AppColors
              .primary, // You may want to use different colors for expanded/non-expanded state
      child: Theme(
        data: Theme.of(context).copyWith(
          unselectedWidgetColor: AppColors.light, // Set icon color here
        ),
        child: ExpansionTile(
          initiallyExpanded: isExpanded, // Set to true for default expanded
          onExpansionChanged: (bool expanded) {
            setState(() {
              isExpanded = expanded;
            });
          },
          leading: Image.asset(
            category.catIcon,
            width: propWidth(36),
            height: propHeight(36),
          ),
          title: Row(
            children: <Widget>[
              Text(
                category.categoryName,
                style: AppFonts.cardTitle,
              ),
              SizedBox(width: propWidth(13)),
              Text(
                  getUnitForCategory(
                      category.categoryName, category.getTotalQuantity()),
                  style: AppFonts.numbers),
              Spacer(), // Use Spacer for automatically calculated remaining space
              GestureDetector(
                  child: Image.asset(
                    'assets/images/CookBook.png',
                    width: propWidth(30),
                    height: propHeight(30),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ChatScreen()),
                    );
                  }),
            ],
          ),
          trailing: Image.asset(
            isExpanded ? 'assets/images/Minus.png' : 'assets/images/Down.png',
            width: propWidth(30),
            height: propHeight(30),
          ),
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.grey2, // Color for the expanded area content
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(propWidth(17)),
                  bottomRight: Radius.circular(propWidth(17)),
                ),
              ),
              child: Column(
                children: category.items.map<Widget>((item) {
                  // Parse the expiration date string to a DateTime object.
                  DateTime expiryDate =
                      DateFormat('yyyy-MM-dd').parse(item.xDate);
                  // Get the current date.
                  DateTime currentDate = DateTime.now();
                  // Calculate the difference in days between the current date and the expiration date.
                  int difference = expiryDate.difference(currentDate).inDays;

                  return Slidable(
                    startActionPane: ActionPane(
                      motion: StretchMotion(),
                      children: [
                        SlidableAction(
                          onPressed: ((context) => _deleteItem(item)),
                          backgroundColor: AppColors.red,
                          icon: Icons.delete_rounded,
                        )
                      ],
                    ),
                    endActionPane: ActionPane(
                      motion: StretchMotion(),
                      children: [
                        SlidableAction(
                          onPressed: ((context) => _deleteItem(item)),
                          backgroundColor: AppColors.red,
                          icon: Icons.delete,
                        )
                      ],
                    ),
                    child: ListTile(
                      onTap: () => _showItemDetailsPopup(context, item),
                      title: Row(
                        children: [
                          Text(
                            item.itemName,
                            style: AppFonts.servicename,
                          ),
                          if (difference >= 0 && difference <= 5)
                            Padding(
                              padding: EdgeInsets.only(left: propWidth(8)),
                              child: Image.asset(
                                'assets/images/Warning.png',
                                width: propWidth(24),
                                height: propHeight(24),
                              ),
                            ),
                        ],
                      ),
                      trailing: Text(
                        '${item.quantity} ${item.unit}',
                        style: AppFonts.numbers1,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Overrides [Size.preferredSize] to set the AppBar height.
///
/// The _PopupRoute class extends [PopupRoute] to customize the popup
/// for selecting a kitchen. It sets properties like barrier color,
/// dismissibility, etc. and builds the popup UI.
@override
Size get preferredSize => Size.fromHeight(propHeight(107.5));

class _PopupRoute extends PopupRoute {
  @override
  Color get barrierColor => AppColors.greySub.withOpacity(0.2);

  @override
  bool get barrierDismissible => true;

  @override
  String get barrierLabel => 'Select Kitchen';

  @override
  Duration get transitionDuration => Duration(milliseconds: 250);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return BackdropFilter(
      filter: ui.ImageFilter.blur(
        sigmaX: 12.0,
        sigmaY: 12.0,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Center(
          child: ClipRect(
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  Center(
                      child: Text(
                    "Choose Your Kitchen",
                    style: AppFonts.choose1,
                  )),
                  SizedBox(height: propHeight(25)),
                  GestureDetector(
                    child: CustomListItem(
                        width: 100,
                        height: 60,
                        mainTxt: 'Ziad\'s Kitchen 1',
                        numberTxt: '4',
                        subTxt: 'Devices',
                        imagePath: 'assets/images/KitchenRoom.png'),
                    onTap: () {},
                  ),
                  SizedBox(height: propHeight(15)),
                  GestureDetector(
                    child: CustomListItem(
                        width: 100,
                        height: 60,
                        mainTxt: 'Rama\'s Kitchen',
                        numberTxt: '10',
                        subTxt: 'Devices',
                        imagePath: 'assets/images/KitchenRoom1.png'),
                    onTap: () {},
                  ),
                  SizedBox(height: propHeight(15)),
                  GestureDetector(
                    child: CustomListItem(
                        width: 100,
                        height: 60,
                        mainTxt: 'Ziad\'s Kitchen 2',
                        numberTxt: '1',
                        subTxt: 'Device',
                        imagePath: 'assets/images/KitchenRoom1.png'),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void _showItemDetailsPopup(BuildContext context, Item item) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.itemName,
                    style: AppFonts.appname,
                  ),
                  IconButton(
                    icon: Icon(Icons.mode_edit_rounded),
                    onPressed: () {
                      Navigator.pop(context); // Close the dialog first
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => EditItemPage(itemToEdit: item),
                        ),
                      );
                    },
                  ),
                ],
              ),
              Text(
                item.itemInfo,
                style: AppFonts.numbers1,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          backgroundColor: AppColors.light.withOpacity(0.9),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: Text("NFC Tag:", style: AppFonts.appname),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(item.nfcTagID, style: AppFonts.numbers1),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: Text("Prod. Date:", style: AppFonts.appname),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(item.pDate, style: AppFonts.numbers1),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: Text("Exp Date:", style: AppFonts.appname),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(item.xDate, style: AppFonts.numbers1),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: Text("Status:", style: AppFonts.appname),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(item.status, style: AppFonts.numbers1),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: Text("Quantity:", style: AppFonts.appname),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text('${item.quantity} ${item.unit}',
                        style: AppFonts.numbers1),
                  ),
                ],
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close', style: AppFonts.appname),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    },
  );
}
