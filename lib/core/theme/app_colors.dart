import 'package:flutter/material.dart';

/// Kid-friendly, high-contrast palette inspired by Duolingo's playful look.
class AppColors {
  AppColors._();

  // Brand / primary
  static const Color primary = Color(0xFF58CC02); // Duo green
  static const Color primaryDark = Color(0xFF58A700); // 3D button shadow
  static const Color primaryLight = Color(0xFFD7FFB8);

  // Accents
  static const Color blue = Color(0xFF1CB0F6);
  static const Color blueDark = Color(0xFF1899D6);
  static const Color purple = Color(0xFFCE82FF);
  static const Color purpleDark = Color(0xFFA568CC);
  static const Color yellow = Color(0xFFFFC800);
  static const Color yellowDark = Color(0xFFE6A800);
  static const Color orange = Color(0xFFFF9600);

  // Feedback
  static const Color correct = Color(0xFF58CC02);
  static const Color correctBg = Color(0xFFD7FFB8);
  static const Color wrong = Color(0xFFFF4B4B);
  static const Color wrongBg = Color(0xFFFFDFE0);
  static const Color wrongDark = Color(0xFFEA2B2B);

  // Hearts
  static const Color heart = Color(0xFFFF4B4B);

  // Neutrals
  static const Color ink = Color(0xFF3C3C3C);
  static const Color inkLight = Color(0xFF777777);
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE5E5E5);
  static const Color borderDark = Color(0xFFCFCFCF);
  static const Color disabled = Color(0xFFE5E5E5);
  static const Color disabledText = Color(0xFFAFAFAF);
  static const Color trackGrey = Color(0xFFE5E5E5);
}
