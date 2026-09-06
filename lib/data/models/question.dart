import 'package:equatable/equatable.dart';

/// The interactive widget type a question renders as inside the lesson runner.
enum QuestionType {
  imageMatching,
  wordJumble,
  audioListening,
  speechRecognition;

  static QuestionType fromString(String value) {
    return QuestionType.values.firstWhere(
      (t) => t.name == value,
      orElse: () => QuestionType.imageMatching,
    );
  }
}

/// A single selectable option, used by image-matching and audio-listening
/// question types. [emoji] stands in for a real image asset in this demo.
class QuestionOption extends Equatable {
  const QuestionOption({
    required this.id,
    required this.label,
    this.emoji,
    this.imageAsset,
    this.audioAsset,
  });

  final String id;
  final String label;
  final String? emoji;
  final String? imageAsset;
  final String? audioAsset;

  factory QuestionOption.fromJson(Map<String, dynamic> json) {
    return QuestionOption(
      id: json['id'] as String,
      label: json['label'] as String,
      emoji: json['emoji'] as String?,
      imageAsset: json['imageAsset'] as String?,
      audioAsset: json['audioAsset'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'emoji': emoji,
        'imageAsset': imageAsset,
        'audioAsset': audioAsset,
      };

  @override
  List<Object?> get props => [id, label, emoji, imageAsset, audioAsset];
}

/// A single question within a lesson. Fields are interpreted differently
/// depending on [type]:
///
/// * [imageMatching]  -> [prompt] + [options] (correctOptionId is the answer).
/// * [audioListening] -> [audioText]/[audioAsset] played back, pick [options].
/// * [wordJumble]     -> [wordBank] chips assembled to equal [answer].
/// * [speechRecognition] -> user must say [answer] (validated by STT).
class Question extends Equatable {
  const Question({
    required this.id,
    required this.type,
    required this.prompt,
    this.instruction,
    this.options = const [],
    this.correctOptionId,
    this.wordBank = const [],
    this.answer,
    this.audioText,
    this.audioAsset,
    this.promptEmoji,
    this.explanation,
  });

  final String id;
  final QuestionType type;

  /// Main question text shown to the learner.
  final String prompt;

  /// Optional secondary hint (e.g. "Tap the matching picture").
  final String? instruction;

  /// Selectable options (image matching / audio listening).
  final List<QuestionOption> options;
  final String? correctOptionId;

  /// Shuffled word chips for the sentence builder.
  final List<String> wordBank;

  /// Canonical answer string (word jumble & speech recognition).
  final String? answer;

  /// Spoken text for audio-listening questions.
  final String? audioText;
  final String? audioAsset;

  /// Emoji illustrating the prompt (demo stand-in for artwork).
  final String? promptEmoji;

  /// Shown in the red feedback sheet when the learner is wrong.
  final String? explanation;

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      type: QuestionType.fromString(json['type'] as String),
      prompt: json['prompt'] as String,
      instruction: json['instruction'] as String?,
      options: (json['options'] as List<dynamic>? ?? [])
          .map((e) => QuestionOption.fromJson(e as Map<String, dynamic>))
          .toList(),
      correctOptionId: json['correctOptionId'] as String?,
      wordBank: (json['wordBank'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
      answer: json['answer'] as String?,
      audioText: json['audioText'] as String?,
      audioAsset: json['audioAsset'] as String?,
      promptEmoji: json['promptEmoji'] as String?,
      explanation: json['explanation'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'prompt': prompt,
        'instruction': instruction,
        'options': options.map((e) => e.toJson()).toList(),
        'correctOptionId': correctOptionId,
        'wordBank': wordBank,
        'answer': answer,
        'audioText': audioText,
        'audioAsset': audioAsset,
        'promptEmoji': promptEmoji,
        'explanation': explanation,
      };

  @override
  List<Object?> get props => [
        id,
        type,
        prompt,
        instruction,
        options,
        correctOptionId,
        wordBank,
        answer,
        audioText,
        audioAsset,
        promptEmoji,
        explanation,
      ];
}
