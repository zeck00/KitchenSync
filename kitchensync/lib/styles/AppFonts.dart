// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'AppColors.dart';

class AppFonts {
  static final TextStyle minittles = GoogleFonts.cairo(
    fontSize: 15,
    fontWeight: FontWeight.w300,
    color: AppColors.primary,
  );

  static final TextStyle appname = GoogleFonts.cairo(
    fontSize: 20,
    fontWeight: FontWeight.w900,
    color: AppColors.dark,
  );

  static final TextStyle cardTitle = GoogleFonts.cairo(
    fontSize: 20,
    fontWeight: FontWeight.w300,
    color: AppColors.light,
  );

  static final TextStyle servicename = GoogleFonts.cairo(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );

  static final TextStyle welcomemsg1 = GoogleFonts.cairo(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );

  static final TextStyle choose1 = GoogleFonts.cairo(
    fontSize: 36,
    fontWeight: FontWeight.w900,
    color: AppColors.light,
  );

  static final TextStyle warning = GoogleFonts.cairo(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.red, // This will be added to AppColors
  );

  static final TextStyle welcomemsg2 = GoogleFonts.cairo(
    fontSize: 36,
    fontWeight: FontWeight.w300,
    color: AppColors.primary,
  );

  static final TextStyle numbers = GoogleFonts.cairo(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: AppColors.green,
  );

  static final TextStyle subtitle = GoogleFonts.cairo(
    fontSize: 20,
    fontWeight: FontWeight.w300,
    color: AppColors.dark,
  );

  static final TextStyle subtitle1 = GoogleFonts.cairo(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.dark,
  );

  static final TextStyle date = GoogleFonts.cairo(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.light,
  );

  static final TextStyle locCard = GoogleFonts.cairo(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.light,
  );

  static final TextStyle locSub = GoogleFonts.cairo(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.greySub, // This will be added to AppColors
  );

  static final TextStyle cntrstText = GoogleFonts.cairo(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.light, // This will be added to AppColors
  );

  static final TextStyle cntrstText1 = GoogleFonts.cairo(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.greySub, // This will be added to AppColors
  );

  static final TextStyle cntrstText2 = GoogleFonts.cairo(
    fontSize: 20,
    fontWeight: FontWeight.w300,
    color: AppColors.greySub, // This will be added to AppColors
  );
}
