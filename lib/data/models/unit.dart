import 'package:equatable/equatable.dart';

import 'lesson.dart';

class Unit extends Equatable {
  const Unit({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.colorValue,
    required this.lessons,
    this.difficulty = 1,
  });

  final String id;
  final String title;
  final String subtitle;

  /// ARGB color used to theme the unit banner and its nodes.
  final int colorValue;

  /// Difficulty tier (1 = easiest). Later units carry higher tiers and longer,
  /// trickier content so the course ramps up as the child progresses.
  final int difficulty;

  final List<Lesson> lessons;

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String? ?? '',
      colorValue: json['colorValue'] as int? ?? 0xFF58CC02,
      difficulty: json['difficulty'] as int? ?? 1,
      lessons: (json['lessons'] as List<dynamic>? ?? [])
          .map((e) => Lesson.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'colorValue': colorValue,
        'difficulty': difficulty,
        'lessons': lessons.map((e) => e.toJson()).toList(),
      };

  @override
  List<Object?> get props =>
      [id, title, subtitle, colorValue, difficulty, lessons];
}
