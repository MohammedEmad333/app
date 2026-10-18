import 'package:flutter_test/flutter_test.dart';
import 'package:lingokids/core/learning/review_schedule.dart';

void main() {
  final now = DateTime.utc(2026, 10, 19, 12);

  test('correct answers increase intervals then cap at 30 days', () {
    ReviewSchedule? schedule;
    const intervals = [1, 3, 7, 14, 30, 30, 30];
    for (var i = 0; i < intervals.length; i++) {
      schedule = ReviewSchedule.afterAnswer(
        now: now,
        correct: true,
        previous: schedule,
      );
      expect(schedule.repetitions, i + 1);
      expect(schedule.dueAt, now.add(Duration(days: intervals[i])));
    }
  });

  test('wrong answer resets repetitions and schedules a retry in 10 minutes', () {
    final advanced = ReviewSchedule(
      repetitions: 5,
      dueAt: now.add(const Duration(days: 30)),
    );
    final retry = ReviewSchedule.afterAnswer(
      now: now,
      correct: false,
      previous: advanced,
    );
    expect(retry.repetitions, 0);
    expect(retry.dueAt, now.add(const Duration(minutes: 10)));
    final recovered = ReviewSchedule.afterAnswer(
      now: now,
      correct: true,
      previous: retry,
    );
    expect(recovered.repetitions, 1);
    expect(recovered.dueAt, now.add(const Duration(days: 1)));
  });

  test('due boundary includes exact instant and excludes earlier instants', () {
    final schedule = ReviewSchedule(
      repetitions: 1,
      dueAt: now,
    );
    expect(schedule.isDue(now.subtract(const Duration(microseconds: 1))), isFalse);
    expect(schedule.isDue(now), isTrue);
    expect(schedule.isDue(now.add(const Duration(seconds: 1))), isTrue);
  });
}
