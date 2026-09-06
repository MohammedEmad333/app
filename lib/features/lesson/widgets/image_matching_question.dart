import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/question.dart';
import '../../../services/tts_service.dart';
import 'question_widget.dart';

/// Visual 4-grid option selection. The learner taps the picture that matches
/// the prompt.
class ImageMatchingQuestion extends QuestionWidget {
  const ImageMatchingQuestion({
    super.key,
    required super.question,
    required super.onAnswerChanged,
    required super.showResult,
    required super.enabled,
  });

  @override
  State<ImageMatchingQuestion> createState() => _ImageMatchingQuestionState();
}

class _ImageMatchingQuestionState extends State<ImageMatchingQuestion> {
  String? _selectedId;

  void _select(QuestionOption option) {
    if (!widget.enabled) return;
    setState(() => _selectedId = option.id);
    TtsService.instance.speak(option.label);
    widget.onAnswerChanged(option.id == widget.question.correctOptionId);
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.question;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(q.prompt, style: AppTextStyles.heading),
        if (q.instruction != null) ...[
          const SizedBox(height: 6),
          Text(q.instruction!, style: AppTextStyles.caption),
        ],
        const SizedBox(height: 20),
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 1,
            physics: const NeverScrollableScrollPhysics(),
            children: q.options.map(_buildTile).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTile(QuestionOption option) {
    final isSelected = _selectedId == option.id;
    final isCorrect = option.id == widget.question.correctOptionId;

    Color border = AppColors.border;
    Color background = AppColors.surface;

    if (widget.showResult && isSelected) {
      border = isCorrect ? AppColors.correct : AppColors.wrong;
      background = isCorrect ? AppColors.correctBg : AppColors.wrongBg;
    } else if (widget.showResult && isCorrect) {
      border = AppColors.correct;
      background = AppColors.correctBg;
    } else if (isSelected) {
      border = AppColors.blue;
      background = AppColors.blue.withValues(alpha: 0.08);
    }

    return GestureDetector(
      onTap: () => _select(option),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border, width: 2.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(option.emoji ?? '❔', style: const TextStyle(fontSize: 56)),
            const SizedBox(height: 8),
            Text(option.label, style: AppTextStyles.title),
          ],
        ),
      ),
    );
  }
}
