import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingokids/features/grammar/grammar_lessons_screen.dart';

void main() {
  testWidgets('correct first answer unlocks a second grammar question', (tester) async {
    await tester.pumpWidget(MaterialApp(home: GrammarDetailScreen(topic: grammarTopics[0])));
    expect(find.text('السؤال الثاني'), findsNothing);
    await tester.tap(find.text('She').last);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('السؤال الثاني'), 200);
    expect(find.text('السؤال الثاني'), findsOneWidget);
    expect(find.text('اختر الإجابة الصحيحة للسؤال الثاني:'), findsOneWidget);
  });
}
