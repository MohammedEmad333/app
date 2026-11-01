import 'package:flutter_test/flutter_test.dart';
import 'package:lingokids/features/grammar/grammar_lessons_screen.dart';

void main() {
  group('Grammar Academy content', () {
    test('has unique titles and valid assessment answers', () {
      expect(grammarTopics, isNotEmpty);
      expect(grammarTopics.map((topic) => topic.title).toSet().length,
          grammarTopics.length);
      for (final topic in grammarTopics) {
        expect(topic.examples, isNotEmpty);
        expect(topic.options.length, greaterThanOrEqualTo(2));
        expect(topic.correctIndex, inInclusiveRange(0, topic.options.length - 1));
        if (topic.secondQuestion != null) {
          expect(topic.secondOptions, isNotNull);
          expect(topic.secondCorrectIndex,
              inInclusiveRange(0, topic.secondOptions!.length - 1));
        }
      }
    });

    test('assessment scoring rewards two first-attempt answers', () {
      expect(GrammarAssessmentScore.fromAttempts(1, 1), 100);
      expect(GrammarAssessmentScore.fromAttempts(2, 1), 50);
      expect(GrammarAssessmentScore.fromAttempts(1, 2), 50);
    });
  });
}
