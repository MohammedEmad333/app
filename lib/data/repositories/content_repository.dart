import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/lesson.dart';
import '../models/question.dart';
import '../models/unit.dart';

/// Loads course content (units → lessons → questions) from the bundled seed
/// JSON. Cached after the first read.
class ContentRepository {
  ContentRepository._();
  static final ContentRepository instance = ContentRepository._();

  static const String _assetPath = 'assets/data/units.json';

  List<Unit>? _cache;

  Future<List<Unit>> loadUnits() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString(_assetPath);
    final decoded = json.decode(raw) as List<dynamic>;
    _cache = decoded
        .map((e) => Unit.fromJson(e as Map<String, dynamic>))
        .toList();
    return _cache!;
  }

  /// All questions across every unit/lesson, keyed by question id.
  Future<Map<String, Question>> questionIndex() async {
    final units = await loadUnits();
    return {
      for (final u in units)
        for (final l in u.lessons)
          for (final q in l.questions) q.id: q,
    };
  }

  /// Builds a synthetic [Lesson] from the given question ids (e.g. the
  /// learner's mistakes) for the review flow. Ignores ids no longer present.
  Future<Lesson> buildReviewLesson(
    Iterable<String> questionIds, {
    int max = 12,
  }) async {
    final index = await questionIndex();
    final questions = <Question>[
      for (final id in questionIds)
        if (index[id] != null) index[id]!,
    ];
    questions.shuffle();
    final selected =
        questions.length > max ? questions.sublist(0, max) : questions;
    return Lesson(
      id: 'review',
      title: 'مراجعة الأخطاء',
      icon: '🔁',
      xpReward: 15,
      questions: selected,
    );
  }
}
