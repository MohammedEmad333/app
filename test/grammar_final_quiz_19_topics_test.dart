import 'package:flutter_test/flutter_test.dart';
import 'package:lingokids/features/grammar/grammar_lessons_screen.dart';
import 'package:lingokids/features/grammar/grammar_quiz_screen.dart';

void main() {
  test('all 19 grammar topics have three valid final questions', () {
    expect(grammarTopics.length, 19);
    for (final topic in grammarTopics) {
      final questions = questionsForTopic(topic);
      expect(questions.length, 3, reason: topic.title);
      for (final question in questions) {
        expect(question.prompt.trim(), isNotEmpty);
        expect(question.options.length, greaterThanOrEqualTo(2));
        expect(question.correctIndex,
            inInclusiveRange(0, question.options.length - 1));
      }
      expect(grammarQuizPercent(
        questions, questions.map((q) => q.correctIndex).toList()), 100);
    }
  });

  test('quiz grading rounds percentage and refuses partial answers', () {
    final questions = questionsForTopic(grammarTopics.first);
    final correct = questions.map((q) => q.correctIndex).toList();
    final wrong = questions[0].correctIndex == 0 ? 1 : 0;
    expect(grammarQuizPercent(questions, [wrong, correct[1], correct[2]]), 67);
    expect(() => grammarQuizPercent(questions, [correct[0]]),
        throwsArgumentError);
  });
}
