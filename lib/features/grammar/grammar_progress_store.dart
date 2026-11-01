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

  /// Aggregate mastery across the current catalog (not stale Hive keys).
  GrammarMasterySummary masterySummary(Iterable<String> topicTitles) {
    final titles = topicTitles.toSet();
    final completed = titles.where(isCompleted).toList();
    final perfect = completed.where((title) => bestScore(title) == 100).length;
    final attempts = titles.fold<int>(0, (sum, title) => sum + attemptCount(title));
    final average = completed.isEmpty ? 0.0 :
        completed.map(bestScore).reduce((a, b) => a + b) / completed.length;
    return GrammarMasterySummary(
      totalTopics: titles.length,
      completedTopics: completed.length,
      perfectTopics: perfect,
      totalAttempts: attempts,
      averageBestScore: average,
    );
  }

  /// Recent score average for a single topic; null means no attempts recorded.
  double? recentAverageScore(String topicTitle) {
    final scores = recentScores(topicTitle);
    if (scores.isEmpty) return null;
    return scores.reduce((a, b) => a + b) / scores.length;
  }

  /// Average score across recent attempts for all known topics.
  /// Returns null when the learner has no recorded practice attempts.
  double? recentPracticeAverage(Iterable<String> topicTitles) {
    var sum = 0;
    var count = 0;
    for (final title in topicTitles.toSet()) {
      for (final score in recentScores(title)) {
        sum += score;
        count++;
      }
    }
    return count == 0 ? null : sum / count;
  }

  /// Topics completed at least once but with a latest score below mastery.
  /// Unlike best-score review, this catches performance regression.
  List<String> regressionReviewTopics(Iterable<String> topicTitles) {
    final titles = topicTitles.toSet().where(isCompleted).where((title) {
      final latest = latestScore(title);
      return latest != null && latest < bestScore(title);
    }).toList();
    titles.sort((a, b) {
      final scoreOrder = (latestScore(a) ?? 0).compareTo(latestScore(b) ?? 0);
      return scoreOrder != 0 ? scoreOrder : a.compareTo(b);
    });
    return titles;
  }

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

/// Immutable grammar analytics calculated from existing persisted scores.
class GrammarMasterySummary {
  const GrammarMasterySummary({
    required this.totalTopics,
    required this.completedTopics,
    required this.perfectTopics,
    required this.totalAttempts,
    required this.averageBestScore,
  });

  final int totalTopics;
  final int completedTopics;
  final int perfectTopics;
  final int totalAttempts;
  final double averageBestScore;

  int get reviewTopics => completedTopics - perfectTopics;
  double get completionRatio => totalTopics == 0 ? 0 : completedTopics / totalTopics;
}
