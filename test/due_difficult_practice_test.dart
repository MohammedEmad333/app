import 'package:flutter_test/flutter_test.dart';
import 'package:lingokids/data/models/user_progress.dart';

void main() {
  test('focused due practice excludes future and unscheduled difficulties', () {
    final now = DateTime.utc(2026, 10, 26, 12);
    final p = UserProgress(
      mistakeQuestionIds: const {'due', 'future', 'invalid', 'easy'},
      reviewSchedules: {
        'due': {'mistakeCount': 3, 'dueAt': now.toIso8601String()},
        'future': {'mistakeCount': 9, 'dueAt': now.add(const Duration(days: 1)).toIso8601String()},
        'invalid': {'mistakeCount': 3, 'dueAt': 'invalid'},
        'easy': {'mistakeCount': 1, 'dueAt': now.toIso8601String()},
      },
    );
    expect(p.prioritizedDifficultQuestionsDue(now: now), ['due']);
    expect(p.difficultQuestionsDueCount(now: now), 1);
  });
}
