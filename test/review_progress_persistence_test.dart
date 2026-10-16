import 'package:flutter_test/flutter_test.dart';
import 'package:lingokids/data/models/user_progress.dart';

void main() {
  test('spaced review schedules survive progress serialization', () {
    final date = DateTime.utc(2026, 10, 16);
    final original = UserProgress(
      name: 'Learner',
      reviewSchedules: {
        'q1': {'repetitions': 2, 'dueAt': date.toIso8601String()},
      },
    );
    final restored = UserProgress.fromMap(original.toMap());
    expect(restored.reviewSchedules['q1']?['repetitions'], 2);
    expect(restored.reviewSchedules['q1']?['dueAt'], date.toIso8601String());
  });

  test('older saved progress loads with no review schedules', () {
    final restored = UserProgress.fromMap({'xp': 12});
    expect(restored.xp, 12);
    expect(restored.reviewSchedules, isEmpty);
  });

  test('copyWith preserves or replaces review schedules', () {
    const initial = UserProgress(reviewSchedules: {
      'q1': {'repetitions': 0, 'dueAt': '2026-10-16T12:00:00.000Z'},
    });
    expect(initial.copyWith(xp: 10).reviewSchedules, initial.reviewSchedules);
    expect(initial.copyWith(reviewSchedules: const {}).reviewSchedules, isEmpty);
  });
}
