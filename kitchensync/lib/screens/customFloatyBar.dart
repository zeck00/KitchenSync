// ignore_for_file: must_be_immutable, file_names, prefer_const_constructors, unnecessary_this, no_leading_underscores_for_local_identifiers, sized_box_for_whitespace, prefer_final_fields, library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FloatingNavBar extends StatefulWidget {
  int index;
  List<CustomFloatingNavBarItem> items;
  Color color;

  double horizontalPadding;
  bool hapticFeedback;
  double borderRadius;
  double? cardWidth;
  bool showTitle;
  bool resizeToAvoidBottomInset;
  final Function(int)? onItemSelected;

  FloatingNavBar({
    super.key,
    this.index = 0,
    this.borderRadius = 15.0,
    this.cardWidth,
    this.showTitle = false,
    this.resizeToAvoidBottomInset = false,
    required this.horizontalPadding,
    required this.items,
    required this.color,
    required this.hapticFeedback,
    this.onItemSelected,
  })  : assert(items.length > 1),
        assert(items.length <= 5);

  @override
  _FloatingNavBarState createState() {
    return _FloatingNavBarState();
  }
}

class _FloatingNavBarState extends State<FloatingNavBar> {
  PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            PageView(
              controller: _pageController,
              physics: NeverScrollableScrollPhysics(),
              children: widget.items.map((item) => item.page).toList(),
              onPageChanged: (index) => this._changePage(index),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 20,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: widget.horizontalPadding,
                ),
                child: Container(
                  height: 70,
                  width: widget.cardWidth ?? MediaQuery.of(context).size.width,
                  child: Card(
                    elevation: 15.0,
                    color: widget.color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children:
                          _widgetsBuilder(widget.items, widget.hapticFeedback),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _floatingNavBarItem(
      CustomFloatingNavBarItem item, int index, bool hapticFeedback) {
    if (widget.showTitle && item.title.isEmpty) {
      throw Exception(
          'Show title set to true: Missing FloatingNavBarItem title!');
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            if (hapticFeedback == true) {
              HapticFeedback.mediumImpact();
            }
            _changePage(index);
            if (widget.onItemSelected != null) {
              widget.onItemSelected!(index);
            }
          },
          child: Container(
            padding: EdgeInsets.all(6),
            width: 50,
            child:
                widget.index == index ? item.selectedIcon : item.unselectedIcon,
          ),
        ),
        widget.showTitle
            ? AnimatedContainer(
                duration: Duration(milliseconds: 1000),
                child: widget.index == index
                    ? Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.transparent,
                        ),
                      )
                    : SizedBox.shrink(),
              )
            : SizedBox.shrink(),
      ],
    );
  }

  List<Widget> _widgetsBuilder(
      List<CustomFloatingNavBarItem> items, bool hapticFeedback) {
    List<Widget> _floatingNavBarItems = [];
    for (int i = 0; i < items.length; i++) {
      Widget item = this._floatingNavBarItem(items[i], i, hapticFeedback);
      _floatingNavBarItems.add(item);
    }
    return _floatingNavBarItems;
  }

  _changePage(int index) {
    _pageController.jumpToPage(index);
    setState(() {
      widget.index = index;
    });
  }
}

class CustomFloatingNavBarItem {
  ImageIcon unselectedIcon;
  ImageIcon selectedIcon;
  String title;
  Widget page;

  CustomFloatingNavBarItem({
    required this.unselectedIcon,
    required this.selectedIcon,
    required this.title,
    required this.page,
  });
}
