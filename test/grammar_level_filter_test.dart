import 'package:flutter_test/flutter_test.dart';
import 'package:lingokids/features/grammar/grammar_lessons_screen.dart';

void main() {
  test('all grammar topics have supported learning levels', () {
    expect(grammarTopics, isNotEmpty);
    expect(grammarTopics.every((topic) => {'A1', 'A2', 'B1'}.contains(topic.level)), isTrue);
    expect(grammarTopics.where((topic) => topic.level == 'A1'), isNotEmpty);
    expect(grammarTopics.where((topic) => topic.level == 'A2'), isNotEmpty);
    expect(grammarTopics.where((topic) => topic.level == 'B1'), isNotEmpty);
  });

  test('levels do not change persisted topic titles', () {
    final topics = grammarTopics.map((topic) => topic.title).toSet();
    expect(topics.length, grammarTopics.length);
    expect(topics, contains('المضارع البسيط'));
    expect(topics, contains('المضارع التام Present Perfect'));
  });
}
