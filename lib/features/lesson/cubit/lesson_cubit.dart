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
/// In [practice] mode the lesson is a replay of an already-completed lesson;
/// in [review] mode it is a set of previously-missed questions. Both are
/// "no-stakes": wrong answers cost no hearts, the lesson can never fail, and
/// completion grants a small fixed XP reward without re-marking a lesson done.
///
/// In every mode, a wrong answer flags the question for review and a correct
/// answer clears it, so mastery removes a word from the review list.
class LessonCubit extends Cubit<LessonState> {
  LessonCubit({
    required Lesson lesson,
    required ProgressCubit progressCubit,
    this.practice = false,
    this.review = false,
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
  final bool review;

  /// Whether this run has no hearts/failure stakes.
  bool get _noStakes => practice || review;

  /// XP awarded for finishing a no-stakes (practice/review) run.
  static const int practiceXp = 10;

  /// Called by a question widget when the learner submits an answer.
  Future<void> submitAnswer({required bool isCorrect}) async {
    if (state.status == LessonStatus.answered) return;

    final qid = state.currentQuestion.id;
    if (isCorrect) {
      _audio.correct();
      HapticFeedback.mediumImpact();
      await _progress.clearMistake(qid);
      emit(state.copyWith(
        status: LessonStatus.answered,
        lastAnswerCorrect: true,
        correctCount: state.correctCount + 1,
      ));
    } else {
      _audio.wrong();
      HapticFeedback.heavyImpact();
      await _progress.addMistake(qid);
      if (!_noStakes) {
        await _progress.loseHeart();
      }
      emit(state.copyWith(
        status: LessonStatus.answered,
        lastAnswerCorrect: false,
        hearts: _noStakes ? state.hearts : _progress.state.hearts,
      ));
    }
  }

  /// Called from the feedback sheet's "Continue" button.
  Future<void> next() async {
    // Out of hearts -> the lesson fails (no-stakes runs never fail).
    if (!_noStakes && state.lastAnswerCorrect == false && state.hearts <= 0) {
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
    final reward = _noStakes ? practiceXp : state.lesson.xpReward;
    await _progress.completeLesson(
      state.lesson.id,
      reward,
      markCompleted: !_noStakes,
    );
    emit(state.copyWith(status: LessonStatus.finished));
  }
}
