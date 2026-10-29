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

}
