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
    expect(topics.length, 3);
    for (final topic in topics) {
      expect(topic.secondQuestion, isNotEmpty);
      expect(topic.secondOptions, hasLength(3));
      expect(topic.secondCorrectIndex, inInclusiveRange(0, 2));
      expect(topic.secondQuestion, isNot(topic.question));
    }
  });
}
