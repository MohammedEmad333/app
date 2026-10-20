import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/user_progress.dart';
import '../../core/learning/review_schedule.dart';
import '../../services/storage_service.dart';

/// Holds the learner's global state (XP, streak, hearts, completed lessons)
/// and mediates every persistent mutation through [StorageService].
class ProgressCubit extends Cubit<UserProgress> {
  ProgressCubit(this._storage, {UserProgress? initialProgress})
      : super(initialProgress ?? _storage.load());

  final StorageService _storage;

  void refresh() => emit(_storage.load());

  Future<void> setName(String name) async {
    final updated = state.copyWith(name: name.trim());
    await _storage.save(updated);
    emit(updated);
  }

  Future<void> completeLesson(
    String lessonId,
    int xpReward, {
    bool markCompleted = true,
  }) async {
    final updated = await _storage.completeLesson(
      current: state,
      lessonId: lessonId,
      xpReward: xpReward,
      markCompleted: markCompleted,
    );
    emit(updated);
  }

  Future<void> loseHeart() async {
    emit(await _storage.loseHeart(state));
  }

  /// Flags a question the learner answered incorrectly for later review.
  Future<void> addMistake(String questionId) async {
    if (state.mistakeQuestionIds.contains(questionId)) return;
    final updated = state.copyWith(
      mistakeQuestionIds: {...state.mistakeQuestionIds, questionId},
    );
    await _storage.save(updated);
    emit(updated);
  }

  /// Clears a question from the review list once it's answered correctly.
  Future<void> clearMistake(String questionId) async {
    if (!state.mistakeQuestionIds.contains(questionId)) return;
    final updated = state.copyWith(
      mistakeQuestionIds: {...state.mistakeQuestionIds}..remove(questionId),
    );
    await _storage.save(updated);
    emit(updated);
  }

  /// Record the answer and persist its next spaced-review due date.
  Future<void> recordReviewAnswer(String questionId, bool correct,
      {DateTime? now}) async {
    final current = state.reviewSchedules[questionId];
    ReviewSchedule? previous;
    if (current != null) {
      final dueAt = DateTime.tryParse(current['dueAt']?.toString() ?? '');
      final repetitions = current['repetitions'];
      if (dueAt != null && repetitions is int && repetitions >= 0) {
        previous = ReviewSchedule(repetitions: repetitions, dueAt: dueAt);
      }
    }
    final schedule = ReviewSchedule.afterAnswer(
      now: now ?? DateTime.now(),
      correct: correct,
      previous: previous,
    );
    final updated = state.copyWith(
      reviewSchedules: {
        ...state.reviewSchedules,
        questionId: {
          'repetitions': schedule.repetitions,
          'dueAt': schedule.dueAt.toIso8601String(),
        },
      },
    );
    await _storage.save(updated);
    emit(updated);
  }

  /// All question IDs with review dates at or before [now].
  Set<String> reviewsDue({DateTime? now}) {
    final time = now ?? DateTime.now();
    return state.reviewSchedules.entries.where((entry) {
      final due = DateTime.tryParse(entry.value['dueAt']?.toString() ?? '');
      return due != null && !due.isAfter(time);
    }).map((entry) => entry.key).toSet();
  }

  /// Count future reviews with valid due timestamps; ignore corrupt records.
  int upcomingReviewsCount({DateTime? now}) {
    final time = now ?? DateTime.now();
    return state.reviewSchedules.values.where((entry) {
      final due = DateTime.tryParse(entry['dueAt']?.toString() ?? '');
      return due != null && due.isAfter(time);
    }).length;
  }

  /// Nearest valid future review date, or null if none are scheduled.
  DateTime? nextReviewAt({DateTime? now}) {
    final time = now ?? DateTime.now();
    DateTime? nearest;
    for (final schedule in state.reviewSchedules.values) {
      final due = DateTime.tryParse(schedule['dueAt']?.toString() ?? '');
      if (due == null || !due.isAfter(time)) continue;
      if (nearest == null || due.isBefore(nearest)) nearest = due;
    }
    return nearest;
  }

  /// Due question IDs ordered oldest-first so missed reviews are not starved.
  List<String> orderedReviewsDue({DateTime? now}) {
    final time = now ?? DateTime.now();
    final entries = state.reviewSchedules.entries.where((entry) {
      final due = DateTime.tryParse(entry.value['dueAt']?.toString() ?? '');
      return due != null && !due.isAfter(time);
    }).toList();
    entries.sort((a, b) {
      final first = DateTime.parse(a.value['dueAt'].toString());
      final second = DateTime.parse(b.value['dueAt'].toString());
      final order = first.compareTo(second);
      return order != 0 ? order : a.key.compareTo(b.key);
    });
    return entries.map((entry) => entry.key).toList();
  }

  Future<void> refillHearts() async {
    emit(await _storage.refillHearts(state));
  }

  Future<void> reset() async {
    // Keep the learner's name; only clear their learning progress.
    final kept = UserProgress(name: state.name);
    await _storage.save(kept);
    emit(kept);
  }
}
