import 'package:flutter_test/flutter_test.dart';
import 'package:lingokids/features/grammar/grammar_lessons_screen.dart';
import 'package:lingokids/features/grammar/grammar_quiz_screen.dart';

void main() {
  test('all grammar topics have 3 valid curated quiz questions', () {
    expect(grammarTopics.length, 16);
    for (final topic in grammarTopics) {
      final items = questionsForTopic(topic);
      expect(items.length, 3, reason: topic.title);
      for (final item in items) {
        expect(item.prompt, isNotEmpty);
        expect(item.options.length, greaterThanOrEqualTo(2));
        expect(item.correctIndex, inInclusiveRange(0, item.options.length - 1));
      }
    }
  });
  test('grade rounds correctly and rejects unfinished assessment', () {
    final questions = questionsForTopic(grammarTopics.first);
    expect(grammarQuizPercent(questions, [1, 1, 0]), 100);
    expect(grammarQuizPercent(questions, [0, 1, 0]), 67);
    expect(grammarQuizPercent(questions, [0, 0, 0]), 33);
    expect(() => grammarQuizPercent(questions, [1]), throwsArgumentError);
  });
}
