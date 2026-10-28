import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingokids/features/grammar/grammar_lessons_screen.dart';

void main() {
  testWidgets('wrong grammar answer can be retried and corrected', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: GrammarDetailScreen(topic: grammarTopics[0]),
    ));
    await tester.tap(find.text('He').last);
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(find.textContaining('حاول مرة أخرى.'), findsOneWidget);
    await tester.tap(find.text('جرّب من جديد'));
    await tester.pump();
    expect(find.textContaining('حاول مرة أخرى.'), findsNothing);
    await tester.ensureVisible(find.text('She').last);
    await tester.tap(find.text('She').last);
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -250));
    await tester.pumpAndSettle();
    expect(find.textContaining('أحسنت! أتقنت هذا التدريب.'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('عدد المحاولات: 2'), 180);
    expect(find.text('عدد المحاولات: 2'), findsOneWidget);
    expect(find.text('أعد التدريب'), findsOneWidget);
  });
}
