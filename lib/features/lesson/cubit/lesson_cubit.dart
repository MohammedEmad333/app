import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
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
///
/// In [practice] mode the lesson is a replay of an already-completed lesson:
/// wrong answers cost no hearts, the lesson can never fail, and completion
/// grants a small fixed XP reward without re-marking the lesson as done.
class LessonCubit extends Cubit<LessonState> {
  LessonCubit({
    required Lesson lesson,
    required ProgressCubit progressCubit,
    this.practice = false,
    AudioService? audio,
  })  : _progress = progressCubit,
        _audio = audio ?? AudioService.instance,
        super(LessonState(
          lesson: lesson,
          hearts: progressCubit.state.hearts,
        ));

  final ProgressCubit _progress;
  final AudioService _audio;
  final bool practice;

  /// XP awarded for finishing a practice replay.
  static const int practiceXp = 10;

  /// Called by a question widget when the learner submits an answer.
  Future<void> submitAnswer({required bool isCorrect}) async {
    if (state.status == LessonStatus.answered) return;

    if (isCorrect) {
      _audio.correct();
      HapticFeedback.mediumImpact();
      emit(state.copyWith(
        status: LessonStatus.answered,
        lastAnswerCorrect: true,
        correctCount: state.correctCount + 1,
      ));
    } else {
      _audio.wrong();
      HapticFeedback.heavyImpact();
      if (!practice) {
        await _progress.loseHeart();
      }
      emit(state.copyWith(
        status: LessonStatus.answered,
        lastAnswerCorrect: false,
        hearts: practice ? state.hearts : _progress.state.hearts,
      ));
    }
  }

  /// Called from the feedback sheet's "Continue" button.
  Future<void> next() async {
    // Out of hearts -> the lesson fails (practice never fails).
    if (!practice && state.lastAnswerCorrect == false && state.hearts <= 0) {
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
    HapticFeedback.heavyImpact();
    final reward = practice ? practiceXp : state.lesson.xpReward;
    await _progress.completeLesson(
      state.lesson.id,
      reward,
      markCompleted: !practice,
    );
    emit(state.copyWith(status: LessonStatus.finished));
  }
}
