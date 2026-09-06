import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../services/speech_service.dart';
import '../../../services/tts_service.dart';
import 'question_widget.dart';

/// Speech recognition: the learner taps the mic, says the target word, and the
/// recognizer validates it. Degrades gracefully when the mic is unavailable.
class SpeechRecognitionQuestion extends QuestionWidget {
  const SpeechRecognitionQuestion({
    super.key,
    required super.question,
    required super.onAnswerChanged,
    required super.showResult,
    required super.enabled,
  });

  @override
  State<SpeechRecognitionQuestion> createState() =>
      _SpeechRecognitionQuestionState();
}

class _SpeechRecognitionQuestionState
    extends State<SpeechRecognitionQuestion> {
  final SpeechService _speech = SpeechService.instance;
  bool _listening = false;
  bool _unavailable = false;
  String _heard = '';

  Future<void> _toggleMic() async {
    if (!widget.enabled) return;
    if (_listening) {
      await _speech.stop();
      setState(() => _listening = false);
      return;
    }
    final started = await _speech.listen(
      onResult: (words, isFinal) {
        setState(() => _heard = words);
        final ok =
            SpeechService.matches(words, widget.question.answer ?? '');
        if (ok) {
          widget.onAnswerChanged(true);
        } else if (isFinal) {
          widget.onAnswerChanged(false);
        }
        if (isFinal) setState(() => _listening = false);
      },
    );
    if (!started) {
      setState(() => _unavailable = true);
    } else {
      setState(() {
        _listening = true;
        _heard = '';
      });
    }
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
        const SizedBox(height: 24),
        // The target word, tappable to hear it pronounced.
        Center(
          child: GestureDetector(
            onTap: () => TtsService.instance.speak(q.answer ?? ''),
            child: Column(
              children: [
                if (q.promptEmoji != null)
                  Text(q.promptEmoji!, style: const TextStyle(fontSize: 72)),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.volume_up_rounded,
                          color: AppColors.primaryDark),
                      const SizedBox(width: 8),
                      Text(q.answer ?? '', style: AppTextStyles.heading),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        if (_heard.isNotEmpty)
          Center(
            child: Text('“$_heard”',
                style: AppTextStyles.title
                    .copyWith(color: AppColors.inkLight)),
          ),
        const SizedBox(height: 16),
        Center(child: _micButton()),
        const SizedBox(height: 12),
        Center(
          child: Text(
            _listening ? 'Listening…' : 'Tap the mic and speak',
            style: AppTextStyles.caption,
          ),
        ),
        if (_unavailable) ...[
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: widget.enabled
                  ? () => widget.onAnswerChanged(true)
                  : null,
              child: Text(
                "Mic unavailable — tap here to say you said it",
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.blue),
              ),
            ),
          ),
        ],
        const Spacer(),
      ],
    );
  }

  Widget _micButton() {
    return GestureDetector(
      onTap: _toggleMic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: _listening ? 100 : 92,
        height: _listening ? 100 : 92,
        decoration: BoxDecoration(
          color: _listening ? AppColors.wrong : AppColors.blue,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (_listening ? AppColors.wrong : AppColors.blue)
                  .withValues(alpha: 0.4),
              blurRadius: _listening ? 24 : 8,
              spreadRadius: _listening ? 4 : 0,
            ),
          ],
        ),
        child: Icon(
          _listening ? Icons.stop_rounded : Icons.mic_rounded,
          color: Colors.white,
          size: 44,
        ),
      ),
    );
  }
}
