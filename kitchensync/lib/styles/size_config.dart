import 'package:flutter/widgets.dart';

// Global screen configuration variables
late double screenWidth;
late double screenHeight;
late double blockSizeHorizontal;
late double blockSizeVertical;
late double safeAreaHorizontal;
late double safeAreaVertical;
late double safeBlockHorizontal;
late double safeBlockVertical;

void initSizeConfig(BuildContext context) {
  screenWidth = MediaQuery.of(context).size.width;
  screenHeight = MediaQuery.of(context).size.height;
  blockSizeHorizontal = screenWidth / 100;
  blockSizeVertical = screenHeight / 100;

  var padding = MediaQuery.of(context).padding;
  safeAreaHorizontal = screenWidth - padding.left - padding.right;
  safeAreaVertical = screenHeight - padding.top - padding.bottom;
  safeBlockHorizontal = safeAreaHorizontal / 100;
  safeBlockVertical = safeAreaVertical / 100;
}

// Global functions for proportionate sizes
double propHeight(double inputHeight) {
  // 932 is the layout height that designer use
  return (inputHeight / 932.0) * screenHeight;
}

double propWidth(double inputWidth) {
  // 430 is the layout width that designer use
  return (inputWidth / 430.0) * screenWidth;
}
