import 'package:flutter/material.dart';

import '../../../data/models/question.dart';
import 'audio_listening_question.dart';
import 'image_matching_question.dart';
import 'speech_recognition_question.dart';
import 'word_jumble_question.dart';

/// Contract every question widget honours so the lesson runner can treat them
/// uniformly.
///
/// * [onAnswerChanged] fires with `true`/`false` once the learner has a
///   candidate answer, or `null` when the answer is cleared (disables Check).
/// * [showResult] flips to true after the learner presses Check, telling the
///   widget to reveal correct/incorrect styling.
/// * [enabled] locks input once the answer has been checked.
abstract class QuestionWidget extends StatefulWidget {
  const QuestionWidget({
    super.key,
    required this.question,
    required this.onAnswerChanged,
    required this.showResult,
    required this.enabled,
  });

  final Question question;
  final ValueChanged<bool?> onAnswerChanged;
  final bool showResult;
  final bool enabled;
}

/// Factory that maps a [Question] to its matching interactive widget.
Widget buildQuestionWidget({
  required Question question,
  required ValueChanged<bool?> onAnswerChanged,
  required bool showResult,
  required bool enabled,
}) {
  switch (question.type) {
    case QuestionType.imageMatching:
      return ImageMatchingQuestion(
        key: ValueKey('img_${question.id}'),
        question: question,
        onAnswerChanged: onAnswerChanged,
        showResult: showResult,
        enabled: enabled,
      );
    case QuestionType.wordJumble:
      return WordJumbleQuestion(
        key: ValueKey('jumble_${question.id}'),
        question: question,
        onAnswerChanged: onAnswerChanged,
        showResult: showResult,
        enabled: enabled,
      );
    case QuestionType.audioListening:
      return AudioListeningQuestion(
        key: ValueKey('audio_${question.id}'),
        question: question,
        onAnswerChanged: onAnswerChanged,
        showResult: showResult,
        enabled: enabled,
      );
    case QuestionType.speechRecognition:
      return SpeechRecognitionQuestion(
        key: ValueKey('speech_${question.id}'),
        question: question,
        onAnswerChanged: onAnswerChanged,
        showResult: showResult,
        enabled: enabled,
      );
  }
}
