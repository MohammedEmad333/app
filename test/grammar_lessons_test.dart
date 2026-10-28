import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingokids/features/grammar/grammar_lessons_screen.dart';

void main() {
  test('grammar catalog covers core introductory topics', () {
    expect(grammarTopics.length, greaterThanOrEqualTo(16));
    expect(grammarTopics.map((t) => t.title).toSet().length, grammarTopics.length);
    expect(grammarTopics.any((t) => t.title == 'الماضي البسيط'), isTrue);
    expect(grammarTopics.any((t) => t.title == 'حروف الجر للمكان'), isTrue);
    for (final topic in grammarTopics) {
      expect(topic.rule, isNotEmpty);
      expect(topic.examples, isNotEmpty);
      expect(topic.question, isNotEmpty);
      expect(topic.options.length, greaterThanOrEqualTo(2));
      expect(topic.correctIndex, inInclusiveRange(0, topic.options.length - 1));
      expect(topic.reason, isNotEmpty);
    }
  });

  testWidgets('learner can open an independent grammar lesson', (tester) async {
    await tester.pumpWidget(MaterialApp(home: GrammarLessonsScreen(
      storeLoader: () async => throw StateError('Storage unavailable in test'),
    )));
    await tester.pump();
    expect(find.text('تعلّم القواعد الإنجليزية'), findsOneWidget);
    await tester.tap(find.text('الضمائر الشخصية'));
    await tester.pumpAndSettle();
    expect(find.text('شرح القاعدة'), findsOneWidget);
    expect(find.text('اختبر فهمك'), findsOneWidget);
  });
}
