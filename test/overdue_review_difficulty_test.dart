import 'package:flutter_test/flutter_test.dart';
import 'package:lingokids/data/models/user_progress.dart';

void main() {
  test('repeated mistakes come first among overdue reviews', () {
    final now = DateTime.utc(2026, 10, 26, 12);
    final p = UserProgress(
      mistakeQuestionIds: const {'older', 'harder', 'future'},
      reviewSchedules: {
        'older': {'dueAt': now.subtract(const Duration(days: 3)).toIso8601String(), 'mistakeCount': 1},
        'harder': {'dueAt': now.subtract(const Duration(days: 1)).toIso8601String(), 'mistakeCount': 5},
        'future': {'dueAt': now.add(const Duration(days: 1)).toIso8601String(), 'mistakeCount': 20},
      },
    );
    expect(p.prioritizedMistakeIds(now: now), ['harder', 'older', 'future']);
  });

  test('upcoming reviews remain ordered by due time', () {
    final now = DateTime.utc(2026, 10, 26);
    final p = UserProgress(
      mistakeQuestionIds: const {'soon', 'later'},
      reviewSchedules: {
        'soon': {'dueAt': now.add(const Duration(days: 1)).toIso8601String(), 'mistakeCount': 1},
        'later': {'dueAt': now.add(const Duration(days: 5)).toIso8601String(), 'mistakeCount': 10},
      },
    );
    expect(p.prioritizedMistakeIds(now: now), ['soon', 'later']);
  });
}
