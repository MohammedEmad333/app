import 'package:flutter_test/flutter_test.dart';
import 'package:lingokids/data/models/user_progress.dart';

void main() {
  test('frequently missed unscheduled questions come first', () {
    const progress = UserProgress(
      mistakeQuestionIds: {'low', 'high', 'unknown'},
      reviewSchedules: {
        'low': {'mistakeCount': 1},
        'high': {'mistakeCount': 5},
      },
    );
    expect(progress.prioritizedMistakeIds(),
        ['high', 'low', 'unknown']);
  });

  test('review urgency stays ahead of frequency', () {
    final now = DateTime.utc(2026, 10, 25);
    final progress = UserProgress(
      mistakeQuestionIds: const {'due', 'future'},
      reviewSchedules: {
        'due': {
          'dueAt': now.subtract(const Duration(days: 1)).toIso8601String(),
          'mistakeCount': 1,
        },
        'future': {
          'dueAt': now.add(const Duration(days: 1)).toIso8601String(),
          'mistakeCount': 20,
        },
      },
    );
    expect(progress.prioritizedMistakeIds(now: now), ['due', 'future']);
  });
}
