import 'package:flutter_test/flutter_test.dart';
import 'package:lingokids/core/learning/review_schedule.dart';

void main() {
  final now = DateTime.utc(2026, 10, 16, 12);

  test('incorrect answers become due in ten minutes', () {
    final schedule = ReviewSchedule.afterAnswer(now: now, correct: false);
    expect(schedule.repetitions, 0);
    expect(schedule.isDue(now.add(const Duration(minutes: 9))), false);
    expect(schedule.isDue(now.add(const Duration(minutes: 10))), true);
  });

  test('correct answers move through increasing review intervals', () {
    ReviewSchedule? schedule;
    for (final days in [1, 3, 7, 14, 30, 30]) {
      schedule = ReviewSchedule.afterAnswer(
        now: now, correct: true, previous: schedule,
      );
      expect(schedule.dueAt, now.add(Duration(days: days)));
    }
    expect(schedule!.repetitions, 6);
  });

  test('wrong answer resets repetition count', () {
    final previous = ReviewSchedule.afterAnswer(now: now, correct: true);
    final retry = ReviewSchedule.afterAnswer(
      now: now, correct: false, previous: previous,
    );
    expect(retry.repetitions, 0);
    final next = ReviewSchedule.afterAnswer(
      now: now, correct: true, previous: retry,
    );
    expect(next.dueAt, now.add(const Duration(days: 1)));
  });
}
