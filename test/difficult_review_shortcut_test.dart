import 'package:flutter_test/flutter_test.dart';
import 'package:lingokids/data/models/user_progress.dart';

void main() {
  test('focused practice includes only unresolved difficult questions', () {
    const p = UserProgress(
      mistakeQuestionIds: {'hard', 'easy', 'older', 'legacy'},
      reviewSchedules: {
        'hard': {'mistakeCount': 4},
        'easy': {'mistakeCount': 1},
        'older': {'mistakeCount': 2},
        'resolved': {'mistakeCount': 20},
      },
    );
    expect(p.prioritizedDifficultQuestionIds(), ['hard', 'older']);
  });

  test('empty and malformed counts do not launch focused practice', () {
    const p = UserProgress(
      mistakeQuestionIds: {'a', 'b'},
      reviewSchedules: {
        'a': {'mistakeCount': 'invalid'},
        'b': {'mistakeCount': -2},
      },
    );
    expect(p.prioritizedDifficultQuestionIds(), isEmpty);
  });
}
