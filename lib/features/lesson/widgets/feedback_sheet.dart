import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/pop_button.dart';

/// Bottom sheet shown after an answer is checked: green celebration for a
/// correct answer, red with an explanation for a wrong one.
class FeedbackSheet extends StatelessWidget {
  const FeedbackSheet({
    super.key,
    required this.isCorrect,
    required this.correctAnswer,
    required this.onContinue,
    this.explanation,
  });

  final bool isCorrect;
  final String correctAnswer;
  final String? explanation;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final accent = isCorrect ? AppColors.correct : AppColors.wrong;
    final bg = isCorrect ? AppColors.correctBg : AppColors.wrongBg;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.white,
                  child: Icon(
                    isCorrect ? Icons.check_rounded : Icons.close_rounded,
                    color: accent,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  isCorrect ? 'Great job! 🎉' : 'Not quite',
                  style: AppTextStyles.heading.copyWith(color: accent),
                ),
              ],
            ),
            if (!isCorrect) ...[
              const SizedBox(height: 12),
              Text('Correct answer:',
                  style: AppTextStyles.caption.copyWith(color: accent)),
              const SizedBox(height: 2),
              Text(correctAnswer,
                  style: AppTextStyles.title.copyWith(color: accent)),
              if (explanation != null) ...[
                const SizedBox(height: 8),
                Text(explanation!,
                    style: AppTextStyles.body.copyWith(color: accent)),
              ],
            ],
            const SizedBox(height: 18),
            PopButton(
              label: isCorrect ? 'Continue' : 'Got it',
              color: accent,
              shadowColor: isCorrect
                  ? AppColors.primaryDark
                  : AppColors.wrongDark,
              onPressed: onContinue,
            ),
          ],
        ),
      ),
    );
  }
}
