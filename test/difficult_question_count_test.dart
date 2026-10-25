import 'package:flutter_test/flutter_test.dart';
import 'package:lingokids/data/models/user_progress.dart';

void main() {
  test('counts only unresolved questions missed at least twice', () {
    const progress = UserProgress(
      mistakeQuestionIds: {'hard', 'easy', 'legacy'},
      reviewSchedules: {
        'hard': {'mistakeCount': 3},
        'easy': {'mistakeCount': 1},
        'resolved': {'mistakeCount': 9},
        'legacy': {'dueAt': '2026-10-26T08:00:00Z'},
      },
    );
    expect(progress.difficultQuestionCount, 1);
  });

  test('handles absent or malformed counters', () {
    const progress = UserProgress(
      mistakeQuestionIds: {'a', 'b', 'c'},
      reviewSchedules: {
        'a': {'mistakeCount': -3},
        'b': {'mistakeCount': 'many'},
        'c': {'mistakeCount': 2},
      },
    );
    expect(progress.difficultQuestionCount, 1);
    expect(const UserProgress().difficultQuestionCount, 0);
  });
}
