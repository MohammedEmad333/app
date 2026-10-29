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
      box.keys.where((key) => !key.toString().startsWith('score:') && !key.toString().startsWith('attempts:') && !key.toString().startsWith('history:') && box.get(key) == true).length;

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

  /// A completed topic needs revision until its best score reaches 100%.
  bool needsReview(String topicTitle) =>
      isCompleted(topicTitle) && bestScore(topicTitle) < 100;

  int reviewNeededCount(Iterable<String> topicTitles) =>
      topicTitles.where(needsReview).length;

  int perfectScoreCount(Iterable<String> topicTitles) =>
      topicTitles.where((title) => isCompleted(title) && bestScore(title) == 100).length;

  /// Prioritizes completed topics with the weakest recent performance.
  List<String> prioritizedReviewTopics(Iterable<String> titles) {
    final pending = titles.where(needsReview).toList();
    pending.sort((a, b) {
      final latestA = latestScore(a) ?? bestScore(a);
      final latestB = latestScore(b) ?? bestScore(b);
      final byScore = latestA.compareTo(latestB);
      if (byScore != 0) return byScore;
      final byBest = bestScore(a).compareTo(bestScore(b));
      return byBest != 0 ? byBest : a.compareTo(b);
    });
    return pending;
  }

  /// The latest ten completed practice scores, oldest first.
  List<int> recentScores(String topicTitle) {
    final value = box.get('history:$topicTitle');
    if (value is! List) return <int>[];
    return value.whereType<int>().where((n) => n >= 0 && n <= 100).toList();
  }

  int? latestScore(String topicTitle) {
    final scores = recentScores(topicTitle);
    return scores.isEmpty ? null : scores.last;
  }

  /// Change between two most recent scores, or null if unavailable.
  int? recentScoreChange(String topicTitle) {
    final scores = recentScores(topicTitle);
    return scores.length < 2 ? null : scores.last - scores[scores.length - 2];
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
    final history = recentScores(topicTitle)..add(score);
    await box.put('history:$topicTitle', history.length <= 10
        ? history : history.sublist(history.length - 10));
  }

  Future<void> markCompleted(String topicTitle) async {
    if (topicTitle.isEmpty) return;
    await box.put(topicTitle, true);
  }

  Future<void> resetTopic(String topicTitle) async {
    await box.delete(topicTitle);
    await box.delete('score:$topicTitle');
    await box.delete('attempts:$topicTitle');
    await box.delete('history:$topicTitle');
  }
}
