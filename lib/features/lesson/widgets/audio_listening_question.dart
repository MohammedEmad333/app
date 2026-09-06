import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/question.dart';
import '../../../services/tts_service.dart';
import 'question_widget.dart';

/// Audio listening: a big play button speaks the target word (via TTS), and
/// the learner picks the matching option.
class AudioListeningQuestion extends QuestionWidget {
  const AudioListeningQuestion({
    super.key,
    required super.question,
    required super.onAnswerChanged,
    required super.showResult,
    required super.enabled,
  });

  @override
  State<AudioListeningQuestion> createState() => _AudioListeningQuestionState();
}

class _AudioListeningQuestionState extends State<AudioListeningQuestion> {
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    // Auto-play the prompt once the question appears.
    WidgetsBinding.instance.addPostFrameCallback((_) => _play());
  }

  void _play() {
    final text = widget.question.audioText ?? '';
    TtsService.instance.speak(text);
  }

  void _select(QuestionOption option) {
    if (!widget.enabled) return;
    setState(() => _selectedId = option.id);
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
        const SizedBox(height: 28),
        Center(child: _playButton()),
        const SizedBox(height: 32),
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 1.05,
            physics: const NeverScrollableScrollPhysics(),
            children: q.options.map(_buildTile).toList(),
          ),
        ),
      ],
    );
  }

  Widget _playButton() {
    return GestureDetector(
      onTap: _play,
      child: Container(
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          color: AppColors.blue,
          borderRadius: BorderRadius.circular(24),
          border: const Border(
            bottom: BorderSide(color: AppColors.blueDark, width: 6),
          ),
        ),
        child: const Icon(Icons.volume_up_rounded,
            color: Colors.white, size: 56),
      ),
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
            if (option.emoji != null)
              Text(option.emoji!, style: const TextStyle(fontSize: 44)),
            const SizedBox(height: 6),
            Text(option.label, style: AppTextStyles.title),
          ],
        ),
      ),
    );
  }
}
