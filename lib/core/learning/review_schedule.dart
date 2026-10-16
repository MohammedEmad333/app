/// Deterministic, offline-friendly intervals for spaced question review.
///
/// This scheduler is deliberately independent of Flutter and persistence.
class ReviewSchedule {
  const ReviewSchedule({required this.repetitions, required this.dueAt});

  final int repetitions;
  final DateTime dueAt;

  bool isDue(DateTime now) => !dueAt.isAfter(now);

  /// Wrong answers return for review soon; repeated correct answers get longer
  /// intervals (1, 3, 7, 14, 30 days, capped at 30).
  static ReviewSchedule afterAnswer({
    required DateTime now,
    required bool correct,
    ReviewSchedule? previous,
  }) {
    if (!correct) {
      return ReviewSchedule(
        repetitions: 0,
        dueAt: now.add(const Duration(minutes: 10)),
      );
    }
    final count = (previous?.repetitions ?? 0) + 1;
    const days = <int>[1, 3, 7, 14, 30];
    final interval = days[(count - 1).clamp(0, days.length - 1)];
    return ReviewSchedule(
      repetitions: count,
      dueAt: now.add(Duration(days: interval)),
    );
  }
}
