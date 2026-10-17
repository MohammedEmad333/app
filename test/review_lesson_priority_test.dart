import 'package:flutter_test/flutter_test.dart';
import 'package:lingokids/data/repositories/content_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('scheduled review keeps oldest questions first and caps at 12', () async {
    final repository = ContentRepository.instance;
    final index = await repository.questionIndex();
    final ids = index.keys.take(15).toList();
    expect(ids.length, 15);

    final lesson = await repository.buildReviewLesson(
      ids,
      shuffle: false,
      title: 'مراجعة الكلمات المستحقة',
    );
    expect(lesson.questions.map((q) => q.id).toList(), ids.take(12).toList());
    expect(lesson.title, 'مراجعة الكلمات المستحقة');
    expect(lesson.id, 'review');
  });

  test('missing questions are skipped without changing remaining order', () async {
    final repository = ContentRepository.instance;
    final index = await repository.questionIndex();
    final ids = index.keys.take(2).toList();
    final lesson = await repository.buildReviewLesson(
      ['missing-question', ...ids],
      shuffle: false,
    );
    expect(lesson.questions.map((q) => q.id).toList(), ids);
    expect(lesson.title, 'مراجعة الأخطاء');
  });
}
