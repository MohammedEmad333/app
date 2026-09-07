import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/question.dart';
import '../../../services/tts_service.dart';
import 'question_widget.dart';

/// Sentence builder: the learner taps word chips from the bank to assemble the
/// target phrase, and can tap assembled chips to send them back.
class WordJumbleQuestion extends QuestionWidget {
  const WordJumbleQuestion({
    super.key,
    required super.question,
    required super.onAnswerChanged,
    required super.showResult,
    required super.enabled,
  });

  @override
  State<WordJumbleQuestion> createState() => _WordJumbleQuestionState();
}

class _Chip {
  _Chip(this.id, this.word);
  final int id; // stable id so duplicate words remain distinct
  final String word;
}

class _WordJumbleQuestionState extends State<WordJumbleQuestion> {
  late List<_Chip> _bank;
  final List<_Chip> _answer = [];

  @override
  void initState() {
    super.initState();
    var i = 0;
    _bank = widget.question.wordBank.map((w) => _Chip(i++, w)).toList();
  }

  String get _assembled => _answer.map((c) => c.word).join(' ');

  void _notify() {
    if (_answer.isEmpty) {
      widget.onAnswerChanged(null);
    } else {
      final correct = _assembled.trim().toLowerCase() ==
          (widget.question.answer ?? '').trim().toLowerCase();
      widget.onAnswerChanged(correct);
    }
  }

  void _pick(_Chip chip) {
    if (!widget.enabled) return;
    setState(() {
      _bank.remove(chip);
      _answer.add(chip);
    });
    TtsService.instance.speak(chip.word);
    _notify();
  }

  void _return(_Chip chip) {
    if (!widget.enabled) return;
    setState(() {
      _answer.remove(chip);
      _bank.add(chip);
    });
    _notify();
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.question;
    Color answerBorder = AppColors.border;
    if (widget.showResult && _answer.isNotEmpty) {
      final correct = _assembled.trim().toLowerCase() ==
          (q.answer ?? '').trim().toLowerCase();
      answerBorder = correct ? AppColors.correct : AppColors.wrong;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(q.prompt, style: AppTextStyles.heading),
        if (q.instruction != null) ...[
          const SizedBox(height: 6),
          Text(q.instruction!, style: AppTextStyles.caption),
        ],
        const SizedBox(height: 24),
        if (q.promptEmoji != null)
          Center(
            child: Text(q.promptEmoji!, style: const TextStyle(fontSize: 72)),
          ),
        const SizedBox(height: 24),
        // Answer construction area
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 78),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border(
              bottom: BorderSide(color: answerBorder, width: 2),
              top: BorderSide(color: AppColors.border, width: 2),
              left: BorderSide(color: AppColors.border, width: 2),
              right: BorderSide(color: AppColors.border, width: 2),
            ),
          ),
          // English sentence is assembled left-to-right even in the RTL UI.
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  _answer.map((c) => _wordChip(c, filled: true)).toList(),
            ),
          ),
        ),
        const SizedBox(height: 28),
        // Word bank
        Directionality(
          textDirection: TextDirection.ltr,
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _bank.map((c) => _wordChip(c, filled: false)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _wordChip(_Chip chip, {required bool filled}) {
    return GestureDetector(
      onTap: () => filled ? _return(chip) : _pick(chip),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border(
            bottom: BorderSide(
              color: filled ? AppColors.border : AppColors.borderDark,
              width: 3,
            ),
            top: const BorderSide(color: AppColors.border, width: 1.5),
            left: const BorderSide(color: AppColors.border, width: 1.5),
            right: const BorderSide(color: AppColors.border, width: 1.5),
          ),
        ),
        child: Text(chip.word, style: AppTextStyles.title),
      ),
    );
  }
}
