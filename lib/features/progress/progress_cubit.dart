import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/user_progress.dart';
import '../../services/storage_service.dart';

/// Holds the learner's global state (XP, streak, hearts, completed lessons)
/// and mediates every persistent mutation through [StorageService].
class ProgressCubit extends Cubit<UserProgress> {
  ProgressCubit(this._storage) : super(_storage.load());

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
