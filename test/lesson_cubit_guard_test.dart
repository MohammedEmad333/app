import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lingokids/data/models/lesson.dart';
import 'package:lingokids/data/models/question.dart';
import 'package:lingokids/data/models/user_progress.dart';
import 'package:lingokids/features/lesson/cubit/lesson_cubit.dart';
import 'package:lingokids/features/progress/progress_cubit.dart';
import 'package:lingokids/services/storage_service.dart';
import 'package:lingokids/services/audio_service.dart';

class SilentAudioService extends AudioService {
  @override
  Future<void> correct() async {}

  @override
  Future<void> wrong() async {}

  @override
  Future<void> celebrate() async {}
}

class FakeProgressCubit extends ProgressCubit {
  FakeProgressCubit()
      : super(StorageService.instance,
            initialProgress: const UserProgress());

  Future<void>? delayMistake;
  Future<void>? delayCompletion;
  int heartLosses = 0;
  int completions = 0;

  @override
  Future<void> recordReviewAnswer(String questionId, bool correct,
      {DateTime? now}) async {}

  @override
  Future<void> addMistake(String questionId) async {
    if (delayMistake != null) await delayMistake;
  }

  @override
  Future<void> clearMistake(String questionId) async {}

  @override
  Future<void> loseHeart() async {
    heartLosses++;
    emit(state.copyWith(hearts: state.hearts - 1));
  }

  @override
  Future<void> completeLesson(
    String lessonId,
    int xpReward, {
    bool markCompleted = true,
  }) async {
    if (delayCompletion != null) await delayCompletion;
    completions++;
  }
}

Lesson sampleLesson({int questions = 2}) => Lesson(
      id: 'lesson',
      title: 'Sample',
      icon: '',
      xpReward: 20,
      questions: [
        for (var i = 0; i < questions; i++)
          Question(
            id: 'question-$i',
            type: QuestionType.wordJumble,
            prompt: 'Translate',
          ),
      ],
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('next cannot skip unanswered questions', () async {
    final progress = FakeProgressCubit();
    final runner = LessonCubit(
      lesson: sampleLesson(),
      progressCubit: progress,
      audio: SilentAudioService(),
    );
    await runner.next();
    expect(runner.state.currentIndex, 0);
    expect(runner.state.status, LessonStatus.inProgress);
    await runner.close();
    await progress.close();
  });

  test('concurrent wrong submissions deduct only one heart', () async {
    final progress = FakeProgressCubit();
    final blocker = Completer<void>();
    progress.delayMistake = blocker.future;
    final runner = LessonCubit(
      lesson: sampleLesson(),
      progressCubit: progress,
      audio: SilentAudioService(),
    );
    final first = runner.submitAnswer(isCorrect: false);
    final second = runner.submitAnswer(isCorrect: false);
    blocker.complete();
    await Future.wait([first, second]);
    expect(progress.heartLosses, 1);
    expect(runner.state.hearts, UserProgress.maxHearts - 1);
    expect(runner.state.status, LessonStatus.answered);
    await runner.close();
    await progress.close();
  });

  test('concurrent continue taps only complete the lesson once', () async {
    final progress = FakeProgressCubit();
    final blocker = Completer<void>();
    progress.delayCompletion = blocker.future;
    final runner = LessonCubit(
      lesson: sampleLesson(questions: 1),
      progressCubit: progress,
      audio: SilentAudioService(),
    );
    await runner.submitAnswer(isCorrect: true);
    final first = runner.next();
    final second = runner.next();
    blocker.complete();
    await Future.wait([first, second]);
    expect(progress.completions, 1);
    expect(runner.state.status, LessonStatus.finished);
    await runner.close();
    await progress.close();
  });
}
