import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Bold, rounded typography for a playful kids' feel. Uses Cairo via
/// google_fonts, which renders both Arabic (the interface language) and Latin
/// (the English words being taught). Note: letterSpacing is avoided because it
/// breaks Arabic letter joining.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle get display => GoogleFonts.cairo(
        fontSize: 30,
        fontWeight: FontWeight.w800,
        color: AppColors.ink,
      );

  static TextStyle get heading => GoogleFonts.cairo(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: AppColors.ink,
      );

  static TextStyle get title => GoogleFonts.cairo(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      );

  static TextStyle get body => GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      );

  static TextStyle get button => GoogleFonts.cairo(
        fontSize: 17,
        fontWeight: FontWeight.w800,
      );

  static TextStyle get caption => GoogleFonts.cairo(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.inkLight,
      );
}
