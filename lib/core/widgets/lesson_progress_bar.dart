import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Rounded, animated progress bar for the top of the lesson runner.
class LessonProgressBar extends StatelessWidget {
  const LessonProgressBar({
    super.key,
    required this.progress,
    this.color = AppColors.primary,
  });

  /// 0.0 – 1.0
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final clamped = progress.clamp(0.0, 1.0);
        return Semantics(
          label: '${(clamped * 100).round()} percent complete',
          child: Container(
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.trackGrey,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOut,
                width: constraints.maxWidth * clamped,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: clamped > 0.06
                    ? Align(
                        alignment: Alignment.topCenter,
                        child: FractionallySizedBox(
                          widthFactor: 0.85,
                          heightFactor: 0.35,
                          child: Container(
                            margin: const EdgeInsets.only(top: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      )
                    : null,
              ),
            ),
          ),
        );
      },
    );
  }
}
