import 'package:flutter_test/flutter_test.dart';
import 'package:lingokids/data/models/user_progress.dart';
import 'package:lingokids/features/progress/progress_cubit.dart';
import 'package:lingokids/services/storage_service.dart';

void main() {
  test('only scheduled reviews due now or earlier are offered', () async {
    final now = DateTime.utc(2026, 10, 16, 12);
    final progress = ProgressCubit(
      StorageService.instance,
      initialProgress: UserProgress(reviewSchedules: {
        'overdue': {'repetitions': 0, 'dueAt': now.subtract(const Duration(days: 1)).toIso8601String()},
        'now': {'repetitions': 1, 'dueAt': now.toIso8601String()},
        'future': {'repetitions': 2, 'dueAt': now.add(const Duration(days: 1)).toIso8601String()},
        'invalid': {'repetitions': 0, 'dueAt': 'invalid-date'},
      }),
    );
    expect(progress.reviewsDue(now: now), {'overdue', 'now'});
    expect(progress.reviewsDue(now: now.subtract(const Duration(days: 2))), isEmpty);
    await progress.close();
  });

  test('legacy progress without review schedule has no due questions', () async {
    final progress = ProgressCubit(
      StorageService.instance,
      initialProgress: const UserProgress(mistakeQuestionIds: {'old-mistake'}),
    );
    expect(progress.reviewsDue(now: DateTime.utc(2026, 10, 16)), isEmpty);
    await progress.close();
  });
  test('overdue reviews are prioritized chronologically', () async {
    final now = DateTime.utc(2026, 10, 17, 12);
    final progress = ProgressCubit(
      StorageService.instance,
      initialProgress: UserProgress(reviewSchedules: {
        'later': {'repetitions': 1, 'dueAt': now.subtract(const Duration(hours: 1)).toIso8601String()},
        'oldest': {'repetitions': 0, 'dueAt': now.subtract(const Duration(days: 3)).toIso8601String()},
        'upcoming': {'repetitions': 2, 'dueAt': now.add(const Duration(days: 1)).toIso8601String()},
        'same-b': {'repetitions': 1, 'dueAt': now.toIso8601String()},
        'same-a': {'repetitions': 1, 'dueAt': now.toIso8601String()},
        'broken': {'repetitions': 0, 'dueAt': 'bad-date'},
      }),
    );
    expect(progress.orderedReviewsDue(now: now),
        ['oldest', 'later', 'same-a', 'same-b']);
    await progress.close();
  });

  test('upcoming count ignores invalid dates and excludes due reviews', () async {
    final now = DateTime.utc(2026, 10, 19, 12);
    final progress = ProgressCubit(
      StorageService.instance,
      initialProgress: UserProgress(reviewSchedules: {
        'due': {'repetitions': 1, 'dueAt': now.toIso8601String()},
        'future': {
          'repetitions': 2,
          'dueAt': now.add(const Duration(days: 1)).toIso8601String(),
        },
        'invalid': {'repetitions': 1, 'dueAt': 'bad-date'},
        'missing': {'repetitions': 0},
      }),
    );
    expect(progress.reviewsDue(now: now), {'due'});
    expect(progress.upcomingReviewsCount(now: now), 1);
    expect(progress.upcomingReviewsCount(now: now.add(const Duration(days: 2))), 0);
    await progress.close();
  });

  test('timezone-offset review dates are compared by instant', () async {
    final now = DateTime.utc(2026, 10, 19, 12);
    final progress = ProgressCubit(
      StorageService.instance,
      initialProgress: UserProgress(reviewSchedules: {
        'due-offset': {'repetitions': 1, 'dueAt': '2026-10-19T15:00:00+03:00'},
        'future-offset': {'repetitions': 1, 'dueAt': '2026-10-19T16:00:00+03:00'},
      }),
    );
    expect(progress.orderedReviewsDue(now: now), ['due-offset']);
    expect(progress.upcomingReviewsCount(now: now), 1);
    await progress.close();
  });

}
