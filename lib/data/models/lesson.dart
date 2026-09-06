import 'package:equatable/equatable.dart';

import 'question.dart';

class Lesson extends Equatable {
  const Lesson({
    required this.id,
    required this.title,
    required this.icon,
    required this.xpReward,
    required this.questions,
  });

  final String id;
  final String title;

  /// Emoji shown on the skill-tree node.
  final String icon;

  /// XP awarded when the lesson is completed.
  final int xpReward;

  final List<Question> questions;

  int get questionCount => questions.length;

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as String,
      title: json['title'] as String,
      icon: json['icon'] as String? ?? '⭐',
      xpReward: json['xpReward'] as int? ?? 20,
      questions: (json['questions'] as List<dynamic>? ?? [])
          .map((e) => Question.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'icon': icon,
        'xpReward': xpReward,
        'questions': questions.map((e) => e.toJson()).toList(),
      };

  @override
  List<Object?> get props => [id, title, icon, xpReward, questions];
}
