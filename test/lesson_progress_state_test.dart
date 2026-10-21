import 'package:flutter_test/flutter_test.dart';
import 'package:lingokids/data/models/lesson.dart';
import 'package:lingokids/data/models/question.dart';
import 'package:lingokids/features/lesson/cubit/lesson_cubit.dart';

void main() {
  const lesson = Lesson(
    id: 'progress-test',
    title: 'Progress',
    icon: '⭐',
    xpReward: 20,
    questions: [
      Question(id: 'q1', type: QuestionType.wordJumble, prompt: 'First'),
      Question(id: 'q2', type: QuestionType.wordJumble, prompt: 'Second'),
    ],
  );

  test('progress advances when an answer is checked', () {
    final initial = LessonState(lesson: lesson);
    expect(initial.progress, 0);
    final answered = initial.copyWith(status: LessonStatus.answered);
    expect(answered.progress, 0.5);
    final second = answered.copyWith(
      currentIndex: 1,
      status: LessonStatus.inProgress,
      clearLastAnswer: true,
    );
    expect(second.progress, 0.5);
    expect(second.copyWith(status: LessonStatus.answered).progress, 1);
  });

  test('final question reaches complete progress for finished and failed', () {
    final last = LessonState(lesson: lesson, currentIndex: 1);
    expect(last.copyWith(status: LessonStatus.finished).progress, 1);
    expect(last.copyWith(status: LessonStatus.failed).progress, 1);
  });

  test('empty lessons report zero progress', () {
    const empty = Lesson(
      id: 'empty', title: 'Empty', icon: '⭐', xpReward: 0, questions: [],
    );
    expect(const LessonState(lesson: empty).progress, 0);
  });
}
