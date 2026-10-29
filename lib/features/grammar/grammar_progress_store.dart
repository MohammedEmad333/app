import 'package:hive_flutter/hive_flutter.dart';

/// Grammar mastery is stored separately from vocabulary-unit progress.
class GrammarProgressStore {
  GrammarProgressStore(this.box);

  static const boxName = 'grammar_progress';
  final Box box;

  static Future<GrammarProgressStore> open() async =>
      GrammarProgressStore(await Hive.openBox(boxName));

  bool isCompleted(String topicTitle) =>
      box.get(topicTitle, defaultValue: false) == true;

  int get completedCount =>
      box.keys.where((key) => !key.toString().startsWith('score:') && !key.toString().startsWith('attempts:') && box.get(key) == true).length;

  int bestScore(String topicTitle) {
    final value = box.get('score:$topicTitle');
    return value is int && value >= 0 ? value : 0;
  }

  /// Saves the highest score only. Scores are percentages from 0 to 100.
  Future<void> saveBestScore(String topicTitle, int score) async {
    if (topicTitle.isEmpty || score < 0 || score > 100) {
      throw ArgumentError('Topic and score (0–100) are required');
    }
    if (score > bestScore(topicTitle)) {
      await box.put('score:$topicTitle', score);
    }
  }

  int attemptCount(String topicTitle) {
    final value = box.get('attempts:$topicTitle');
    return value is int && value >= 0 ? value : 0;
  }

  /// Records a completed two-question practice session.
  Future<void> recordAttempt(String topicTitle, int score) async {
    if (topicTitle.trim().isEmpty || score < 0 || score > 100) {
      throw ArgumentError('Valid topic and score (0–100) required');
    }
    await box.put('attempts:$topicTitle', attemptCount(topicTitle) + 1);
    await saveBestScore(topicTitle, score);
  }

  Future<void> markCompleted(String topicTitle) async {
    if (topicTitle.isEmpty) return;
    await box.put(topicTitle, true);
  }

  Future<void> resetTopic(String topicTitle) async {
    await box.delete(topicTitle);
    await box.delete('score:$topicTitle');
    await box.delete('attempts:$topicTitle');
  }
}
