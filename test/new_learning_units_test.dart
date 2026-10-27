import 'package:flutter_test/flutter_test.dart';
import 'package:lingokids/data/repositories/content_repository.dart';
import 'package:lingokids/data/models/question.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('new school and safety course units have valid exercise data', () async {
    final units = await ContentRepository.instance.loadUnits();
    final additions = units.where((u) => u.id == 'unit_25' || u.id == 'unit_26').toList();
    expect(additions.length, 2);
    final all = units.expand((u) => u.lessons).expand((l) => l.questions).toList();
    expect(all.map((q) => q.id).toSet().length, all.length);
    for (final unit in additions) {
      expect(unit.lessons.length, 3);
      for (final lesson in unit.lessons) {
        expect(lesson.questions.length, 4);
        for (final q in lesson.questions) {
          if (q.type == QuestionType.imageMatching || q.type == QuestionType.audioListening) {
            expect(q.options.any((o) => o.id == q.correctOptionId), isTrue);
          }
          if (q.type == QuestionType.wordJumble) {
            final remaining = q.wordBank.toList();
            for (final word in q.answer!.split(' ')) {
              expect(remaining.remove(word), isTrue);
            }
          }
          if (q.type == QuestionType.speechRecognition) {
            expect(q.answer, isNotEmpty);
          }
        }
      }
    }
  });
}
