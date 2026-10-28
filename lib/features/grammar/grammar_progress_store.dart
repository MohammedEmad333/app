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
      box.keys.where((key) => box.get(key) == true).length;

  Future<void> markCompleted(String topicTitle) async {
    if (topicTitle.isEmpty) return;
    await box.put(topicTitle, true);
  }

  Future<void> resetTopic(String topicTitle) => box.delete(topicTitle);
}
