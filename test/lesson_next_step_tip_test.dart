import 'package:flutter_test/flutter_test.dart';
import 'package:lingokids/features/lesson/lesson_complete_screen.dart';

void main() {
  test('next learning step matches accuracy boundaries', () {
    expect(LessonCompleteScreen.nextStepTip(0),
        'راجع إجاباتك الخاطئة ثم أعد التدريب.');
    expect(LessonCompleteScreen.nextStepTip(59),
        'راجع إجاباتك الخاطئة ثم أعد التدريب.');
    expect(LessonCompleteScreen.nextStepTip(60),
        'أعد التدريب لتتقن الكلمات الصعبة.');
    expect(LessonCompleteScreen.nextStepTip(89),
        'أعد التدريب لتتقن الكلمات الصعبة.');
    expect(LessonCompleteScreen.nextStepTip(90),
        'أحسنت! أنت مستعد للدرس التالي.');
    expect(LessonCompleteScreen.nextStepTip(100),
        'أحسنت! أنت مستعد للدرس التالي.');
  });
}
