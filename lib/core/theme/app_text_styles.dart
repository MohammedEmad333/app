import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Bold, rounded typography for a playful kids' feel. Uses the **bundled**
/// Cairo font (SIL OFL 1.1), which renders both Arabic (the interface language)
/// and Latin (the English words being taught) and works fully offline. Note:
/// letterSpacing is avoided because it breaks Arabic letter joining.
class AppTextStyles {
  AppTextStyles._();

  static const String _family = 'Cairo';

  static const TextStyle display = TextStyle(
    fontFamily: _family,
    fontSize: 30,
    fontWeight: FontWeight.w800,
    color: AppColors.ink,
  );

  static const TextStyle heading = TextStyle(
    fontFamily: _family,
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: AppColors.ink,
  );

  static const TextStyle title = TextStyle(
    fontFamily: _family,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  static const TextStyle body = TextStyle(
    fontFamily: _family,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
  );

  static const TextStyle button = TextStyle(
    fontFamily: _family,
    fontSize: 17,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: _family,
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AppColors.inkLight,
  );
}
