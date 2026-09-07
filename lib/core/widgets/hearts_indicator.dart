import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Compact hearts/lives counter shown in the lesson header.
class HeartsIndicator extends StatelessWidget {
  const HeartsIndicator({super.key, required this.hearts});

  final int hearts;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppStrings.heartsRemaining(hearts),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.wrongBg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.favorite, color: AppColors.heart, size: 22),
            const SizedBox(width: 4),
            Text(
              AppStrings.arDigits(hearts),
              style: AppTextStyles.title.copyWith(color: AppColors.heart),
            ),
          ],
        ),
      ),
    );
  }
}
