import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Bold, rounded typography for a playful kids' feel. Uses Nunito via
/// google_fonts (falls back to the bundled system font offline).
class AppTextStyles {
  AppTextStyles._();

  static TextStyle get display => GoogleFonts.nunito(
        fontSize: 30,
        fontWeight: FontWeight.w800,
        color: AppColors.ink,
      );

  static TextStyle get heading => GoogleFonts.nunito(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: AppColors.ink,
      );

  static TextStyle get title => GoogleFonts.nunito(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      );

  static TextStyle get body => GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      );

  static TextStyle get button => GoogleFonts.nunito(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
      );

  static TextStyle get caption => GoogleFonts.nunito(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.inkLight,
      );
}
