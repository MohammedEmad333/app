import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lingokids/features/grammar/grammar_progress_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('grammar completion persists independently across store instances', () async {
    final directory = await Directory.systemTemp.createTemp('grammar_progress_');
    Hive.init(directory.path);
    try {
      final box = await Hive.openBox('test_grammar_progress');
      final first = GrammarProgressStore(box);
      expect(first.isCompleted('Present simple'), isFalse);
      await first.markCompleted('Present simple');
      await first.markCompleted('Present simple');
      final second = GrammarProgressStore(box);
      expect(second.isCompleted('Present simple'), isTrue);
      expect(second.completedCount, 1);
      await second.resetTopic('Present simple');
      expect(first.isCompleted('Present simple'), isFalse);
      await box.close();
    } finally {
      await directory.delete(recursive: true);
    }
  });
  test('best grammar score persists, never decreases, and resets independently', () async {
    final directory = await Directory.systemTemp.createTemp('grammar_scores_');
    Hive.init(directory.path);
    try {
      final box = await Hive.openBox('test_grammar_scores');
      final first = GrammarProgressStore(box);
      expect(first.bestScore('Present perfect'), 0);
      await first.markCompleted('Present perfect');
      await first.saveBestScore('Present perfect', 80);
      await first.saveBestScore('Present perfect', 45);
      await first.saveBestScore('Present perfect', 100);
      final reopened = GrammarProgressStore(box);
      expect(reopened.bestScore('Present perfect'), 100);
      expect(reopened.completedCount, 1);
      await reopened.resetTopic('Present perfect');
      expect(first.isCompleted('Present perfect'), isFalse);
      expect(first.bestScore('Present perfect'), 0);
      expect(first.completedCount, 0);
      await box.close();
    } finally {
      await directory.delete(recursive: true);
    }
  });

  test('grammar score rejects out of range values and empty topic', () async {
    final directory = await Directory.systemTemp.createTemp('grammar_validation_');
    Hive.init(directory.path);
    try {
      final box = await Hive.openBox('test_grammar_validation');
      final store = GrammarProgressStore(box);
      await expectLater(store.saveBestScore('Present simple', -1), throwsArgumentError);
      await expectLater(store.saveBestScore('Present simple', 101), throwsArgumentError);
      await expectLater(store.saveBestScore('', 50), throwsArgumentError);
      expect(store.bestScore('Present simple'), 0);
      expect(store.completedCount, 0);
      await box.close();
    } finally {
      await directory.delete(recursive: true);
    }
  });

  test('practice attempts persist separately from completion and best score', () async {
    final directory = await Directory.systemTemp.createTemp('grammar_attempts_');
    Hive.init(directory.path);
    try {
      final box = await Hive.openBox('test_grammar_attempts');
      final store = GrammarProgressStore(box);
      await store.recordAttempt('Present simple', 50);
      await store.recordAttempt('Present simple', 100);
      await store.recordAttempt('Present simple', 50);
      final reopened = GrammarProgressStore(box);
      expect(reopened.attemptCount('Present simple'), 3);
      expect(reopened.bestScore('Present simple'), 100);
      expect(reopened.completedCount, 0);
      await reopened.markCompleted('Present simple');
      expect(reopened.completedCount, 1);
      await reopened.resetTopic('Present simple');
      expect(reopened.attemptCount('Present simple'), 0);
      expect(reopened.bestScore('Present simple'), 0);
      expect(reopened.completedCount, 0);
      await box.close();
    } finally {
      await directory.delete(recursive: true);
    }
  });

  test('review dashboard reports mastered and weak completed topics', () async {
    final directory = await Directory.systemTemp.createTemp('grammar_review_');
    Hive.init(directory.path);
    try {
      final box = await Hive.openBox('test_grammar_review');
      final store = GrammarProgressStore(box);
      const topics = ['One', 'Two', 'Three'];
      await store.markCompleted('One');
      await store.recordAttempt('One', 50);
      await store.markCompleted('Two');
      await store.recordAttempt('Two', 100);
      expect(store.needsReview('One'), isTrue);
      expect(store.needsReview('Two'), isFalse);
      expect(store.needsReview('Three'), isFalse);
      expect(store.reviewNeededCount(topics), 1);
      expect(store.perfectScoreCount(topics), 1);
      await store.recordAttempt('One', 100);
      expect(store.reviewNeededCount(topics), 0);
      expect(store.perfectScoreCount(topics), 2);
      await store.resetTopic('Two');
      expect(store.perfectScoreCount(topics), 1);
      await box.close();
    } finally {
      await directory.delete(recursive: true);
    }
  });

  test('recent grammar scores are bounded, ordered, and resettable', () async {
    final directory = await Directory.systemTemp.createTemp('grammar_history_');
    Hive.init(directory.path);
    try {
      final box = await Hive.openBox('test_grammar_history');
      final store = GrammarProgressStore(box);
      expect(store.latestScore('Grammar'), isNull);
      for (var i = 0; i < 12; i++) {
        await store.recordAttempt('Grammar', i.isEven ? 50 : 100);
      }
      final second = GrammarProgressStore(box);
      expect(second.recentScores('Grammar'), hasLength(10));
      expect(second.recentScores('Grammar').first, 50);
      expect(second.latestScore('Grammar'), 100);
      expect(second.attemptCount('Grammar'), 12);
      expect(second.bestScore('Grammar'), 100);
      expect(second.completedCount, 0);
      await second.resetTopic('Grammar');
      expect(second.recentScores('Grammar'), isEmpty);
      expect(second.latestScore('Grammar'), isNull);
      await box.close();
    } finally {
      await directory.delete(recursive: true);
    }
  });

  test('grammar review prioritizes weakest latest performance', () async {
    final directory = await Directory.systemTemp.createTemp('grammar_priority_');
    Hive.init(directory.path);
    try {
      final box = await Hive.openBox('test_grammar_priority');
      final store = GrammarProgressStore(box);
      for (final title in ['Alpha', 'Beta', 'Gamma']) {
        await store.markCompleted(title);
      }
      await store.recordAttempt('Alpha', 50);
      await store.recordAttempt('Beta', 75);
      await store.recordAttempt('Gamma', 100);
      expect(store.prioritizedReviewTopics(['Beta', 'Gamma', 'Alpha']),
          ['Alpha', 'Beta']);
      await store.recordAttempt('Alpha', 100);
      expect(store.prioritizedReviewTopics(['Beta', 'Gamma', 'Alpha']),
          ['Beta']);
      await box.close();
    } finally {
      await directory.delete(recursive: true);
    }
  });

  test('grammar trend follows recent scores and reset', () async {
    final directory = await Directory.systemTemp.createTemp('grammar_trend_');
    Hive.init(directory.path);
    try {
      final box = await Hive.openBox('test_grammar_trend');
      final store = GrammarProgressStore(box);
      expect(store.recentScoreChange('Grammar'), isNull);
      await store.recordAttempt('Grammar', 50);
      expect(store.recentScoreChange('Grammar'), isNull);
      await store.recordAttempt('Grammar', 100);
      expect(store.recentScoreChange('Grammar'), 50);
      await store.recordAttempt('Grammar', 50);
      expect(store.recentScoreChange('Grammar'), -50);
      await store.resetTopic('Grammar');
      expect(store.recentScoreChange('Grammar'), isNull);
      await box.close();
    } finally {
      await directory.delete(recursive: true);
    }
  });

}
