import 'package:hive_flutter/hive_flutter.dart';

/// Stores grammar learning progress separately from vocabulary units and XP.
class GrammarProgressService {
  GrammarProgressService._();
  static final GrammarProgressService instance = GrammarProgressService._();

  static const boxName = 'grammar_progress';
  Box? _box;

  Future<Box> _open() async {
    final current = _box;
    if (current != null && current.isOpen) return current;
    return _box = await Hive.openBox(boxName);
  }

  /// Returns the highest number of questions answered correctly for this
  /// grammar topic. Legacy and malformed values safely resolve to zero.
  Future<int> bestScore(String topicTitle) async {
    final raw = (await _open()).get(topicTitle);
    return raw is int && raw >= 0 ? raw : 0;
  }

  /// Records the best score, never replacing a higher score with a lower one.
  Future<int> recordScore(String topicTitle, int correctAnswers) async {
    if (topicTitle.trim().isEmpty) {
      throw ArgumentError.value(topicTitle, 'topicTitle', 'Required');
    }
    if (correctAnswers < 0) {
      throw RangeError.value(correctAnswers, 'correctAnswers');
    }
    final box = await _open();
    final previous = await bestScore(topicTitle);
    final updated = correctAnswers > previous ? correctAnswers : previous;
    await box.put(topicTitle, updated);
    return updated;
  }

  Future<void> reset() async => (await _open()).clear();
}
