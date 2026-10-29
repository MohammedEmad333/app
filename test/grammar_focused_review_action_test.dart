import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lingokids/features/grammar/grammar_lessons_screen.dart';
import 'package:lingokids/features/grammar/grammar_progress_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  late Box box;
  late GrammarProgressStore store;

  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('grammar_review_action_');
    Hive.init(directory.path);
    box = await Hive.openBox('test_review_action');
    store = GrammarProgressStore(box);
    await store.markCompleted(grammarTopics[0].title);
    await store.recordAttempt(grammarTopics[0].title, 50);
  });

  tearDownAll(() async {
    await box.close();
    await directory.delete(recursive: true);
  });

  testWidgets('focused review opens weakest completed grammar topic', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: GrammarLessonsScreen(storeLoader: () async => store),
    ));
    await tester.pumpAndSettle();
    final button = find.text('ابدأ مراجعة أضعف قاعدة');
    expect(button, findsOneWidget);
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(find.text('اختبر فهمك'), findsOneWidget);
    expect(find.text(grammarTopics[0].title), findsOneWidget);
  });
}
