import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/lesson.dart';
import '../../../data/models/question.dart';
import '../../../data/models/user_progress.dart';
import '../../../services/audio_service.dart';
import '../../progress/progress_cubit.dart';

part 'lesson_state.dart';

/// Drives the step-by-step lesson runner: checking answers, deducting hearts,
/// advancing questions and finishing/failing the lesson. Persistent side
/// effects (heart loss, XP award) are delegated to [ProgressCubit].
class LessonCubit extends Cubit<LessonState> {
  LessonCubit({
    required Lesson lesson,
    required ProgressCubit progressCubit,
    AudioService? audio,
  })  : _progress = progressCubit,
        _audio = audio ?? AudioService.instance,
        super(LessonState(
          lesson: lesson,
          hearts: progressCubit.state.hearts,
        ));

  final ProgressCubit _progress;
  final AudioService _audio;

  /// Called by a question widget when the learner submits an answer.
  Future<void> submitAnswer({required bool isCorrect}) async {
    if (state.status == LessonStatus.answered) return;

    if (isCorrect) {
      _audio.correct();
      emit(state.copyWith(
        status: LessonStatus.answered,
        lastAnswerCorrect: true,
        correctCount: state.correctCount + 1,
      ));
    } else {
      _audio.wrong();
      await _progress.loseHeart();
      final hearts = _progress.state.hearts;
      emit(state.copyWith(
        status: LessonStatus.answered,
        lastAnswerCorrect: false,
        hearts: hearts,
      ));
    }
  }

  /// Called from the feedback sheet's "Continue" button.
  Future<void> next() async {
    // Out of hearts -> the lesson fails.
    if (state.lastAnswerCorrect == false && state.hearts <= 0) {
      emit(state.copyWith(status: LessonStatus.failed));
      return;
    }

    if (state.isLastQuestion) {
      await _finish();
      return;
    }

    emit(state.copyWith(
      currentIndex: state.currentIndex + 1,
      status: LessonStatus.inProgress,
      clearLastAnswer: true,
    ));
  }

  Future<void> _finish() async {
    _audio.celebrate();
    await _progress.completeLesson(state.lesson.id, state.lesson.xpReward);
    emit(state.copyWith(status: LessonStatus.finished));
  }
}
