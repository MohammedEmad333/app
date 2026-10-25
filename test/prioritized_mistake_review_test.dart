import 'package:flutter_test/flutter_test.dart';
import 'package:lingokids/data/models/user_progress.dart';

void main() {
  test('prioritizes due mistakes before unscheduled and upcoming', () {
    final now = DateTime.utc(2026, 10, 25, 12);
    final progress = UserProgress(
      mistakeQuestionIds: const {'future', 'missing', 'late', 'older'},
      reviewSchedules: {
        'future': {'dueAt': now.add(const Duration(days: 1)).toIso8601String()},
        'late': {'dueAt': now.subtract(const Duration(hours: 1)).toIso8601String()},
        'older': {'dueAt': now.subtract(const Duration(days: 2)).toIso8601String()},
      },
    );
    expect(progress.prioritizedMistakeIds(now: now),
        ['older', 'late', 'missing', 'future']);
  });

  test('invalid schedule remains reviewable and ties are deterministic', () {
    final progress = UserProgress(
      mistakeQuestionIds: const {'b', 'a'},
      reviewSchedules: const {
        'b': {'dueAt': 'invalid'},
      },
    );
    expect(progress.prioritizedMistakeIds(), ['a', 'b']);
    expect(progress.mistakeQuestionIds, {'a', 'b'});
  });
}
