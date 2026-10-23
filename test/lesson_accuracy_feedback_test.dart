import 'package:flutter_test/flutter_test.dart';
import 'package:lingokids/features/lesson/lesson_complete_screen.dart';

void main() {
  test('completion feedback reflects lesson accuracy', () {
    expect(LessonCompleteScreen.accuracyFeedback(100),
        'ممتاز! أنت تتقن هذا الدرس!');
    expect(LessonCompleteScreen.accuracyFeedback(90),
        'ممتاز! أنت تتقن هذا الدرس!');
    expect(LessonCompleteScreen.accuracyFeedback(89),
        'عمل جيد! استمر في التدريب لتتحسن أكثر.');
    expect(LessonCompleteScreen.accuracyFeedback(60),
        'عمل جيد! استمر في التدريب لتتحسن أكثر.');
    expect(LessonCompleteScreen.accuracyFeedback(59),
        'كل محاولة تعلّمك شيئًا جديدًا. جرّب التدريب مجددًا!');
    expect(LessonCompleteScreen.accuracyFeedback(0),
        'كل محاولة تعلّمك شيئًا جديدًا. جرّب التدريب مجددًا!');
  });
}
