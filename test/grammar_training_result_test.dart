import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingokids/features/grammar/grammar_lessons_screen.dart';

void main() {
  testWidgets('grammar training shows two-question completion result', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: GrammarDetailScreen(topic: grammarTopics[0],
        onComplete: (_) async {}),
    ));
    await tester.tap(find.text('She').last);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('السؤال الثاني'), 160);
    final choice = find.byType(RadioListTile<int>).at(3);
    await tester.ensureVisible(choice);
    await tester.drag(find.byType(ListView), const Offset(0, -240));
    await tester.pumpAndSettle();
    await tester.tap(choice);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('نتيجة التدريب: 2/2'), 160);
    expect(find.text('نتيجة التدريب: 2/2'), findsOneWidget);
  });
  test('new grammar lessons have separate second questions and valid answer keys', () {
    final topics = grammarTopics.where((topic) => topic.secondQuestion != null).toList();
    expect(topics.length, grammarTopics.length);
    for (final topic in topics) {
      expect(topic.secondQuestion, isNotEmpty);
      expect(topic.secondOptions, hasLength(3));
      expect(topic.secondCorrectIndex, inInclusiveRange(0, 2));
      expect(topic.secondQuestion, isNot(topic.question));
      expect(topic.secondOptions!.toSet().length, 3);
      expect(topic.secondOptions!.every((option) => option.trim().isNotEmpty), isTrue);
    }
  });
  test('grammar score reflects first-try accuracy', () {
    expect(GrammarAssessmentScore.fromAttempts(1, 1), 100);
    expect(GrammarAssessmentScore.fromAttempts(2, 1), 50);
    expect(GrammarAssessmentScore.fromAttempts(1, 2), 50);
    expect(GrammarAssessmentScore.fromAttempts(3, 4), 50);
  });

  testWidgets('second answer cannot record completion twice without a new session', (tester) async {
    var completions = 0;
    await tester.pumpWidget(MaterialApp(
      home: GrammarDetailScreen(
        topic: grammarTopics[0],
        onComplete: (_) async { completions++; },
      ),
    ));
    await tester.tap(find.text('She').last);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('السؤال الثاني'), 160);
    final answer = find.byType(RadioListTile<int>).at(3);
    await tester.ensureVisible(answer);
    await tester.tap(answer);
    await tester.pumpAndSettle();
    expect(completions, 1);
    expect(tester.widget<RadioListTile<int>>(answer).onChanged, isNull);
  });

}
