import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lingokids/features/grammar/grammar_progress_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('best grammar score persists and never decreases', () async {
    final directory = await Directory.systemTemp.createTemp('grammar_scores_');
    Hive.init(directory.path);
    try {
      final box = await Hive.openBox('grammar_best_score_test');
      final store = GrammarProgressStore(box);
      expect(store.bestScore('Pronouns'), 0);
      await store.saveBestScore('Pronouns', 80);
      await store.saveBestScore('Pronouns', 50);
      expect(GrammarProgressStore(box).bestScore('Pronouns'), 80);
      expect(store.completedCount, 0);
      await store.markCompleted('Pronouns');
      expect(store.completedCount, 1);
      await store.saveBestScore('Pronouns', 100);
      expect(store.bestScore('Pronouns'), 100);
      await store.resetTopic('Pronouns');
      expect(store.bestScore('Pronouns'), 0);
      expect(store.completedCount, 0);
      await box.close();
    } finally {
      await directory.delete(recursive: true);
    }
  });
  test('invalid scores cannot be stored', () async {
    final directory = await Directory.systemTemp.createTemp('grammar_invalid_');
    Hive.init(directory.path);
    try {
      final box = await Hive.openBox('grammar_score_invalid_test');
      final store = GrammarProgressStore(box);
      await expectLater(store.saveBestScore('Pronouns', 101), throwsArgumentError);
      await expectLater(store.saveBestScore('Pronouns', -1), throwsArgumentError);
      await expectLater(store.saveBestScore('', 50), throwsArgumentError);
      await box.close();
    } finally {
      await directory.delete(recursive: true);
    }
  });
}
