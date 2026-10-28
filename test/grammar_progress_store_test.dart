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
}
