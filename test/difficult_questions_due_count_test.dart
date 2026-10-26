import 'package:flutter_test/flutter_test.dart';
import 'package:lingokids/data/models/user_progress.dart';

void main() {
  test('counts only unresolved difficult questions due now', () {
    final now = DateTime.utc(2026, 10, 26, 12);
    final p = UserProgress(
      mistakeQuestionIds: const {'due', 'future', 'easy', 'invalid'},
      reviewSchedules: {
        'due': {'mistakeCount': 3, 'dueAt': now.toIso8601String()},
        'future': {'mistakeCount': 5, 'dueAt': now.add(const Duration(days: 1)).toIso8601String()},
        'easy': {'mistakeCount': 1, 'dueAt': now.subtract(const Duration(days: 1)).toIso8601String()},
        'invalid': {'mistakeCount': 3, 'dueAt': 'bad-date'},
        'resolved': {'mistakeCount': 6, 'dueAt': now.toIso8601String()},
      },
    );
    expect(p.difficultQuestionsDueCount(now: now), 1);
    expect(p.difficultQuestionCount, 3);
  });

  test('empty review record counts zero due difficult questions', () {
    expect(const UserProgress().difficultQuestionsDueCount(), 0);
  });
}
