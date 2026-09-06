part of 'lesson_cubit.dart';

enum LessonStatus { inProgress, answered, finished, failed }

class LessonState extends Equatable {
  const LessonState({
    required this.lesson,
    this.currentIndex = 0,
    this.hearts = UserProgress.maxHearts,
    this.status = LessonStatus.inProgress,
    this.lastAnswerCorrect,
    this.correctCount = 0,
  });

  final Lesson lesson;
  final int currentIndex;
  final int hearts;
  final LessonStatus status;

  /// Set once a question has been checked (null while awaiting an answer).
  final bool? lastAnswerCorrect;

  /// Number of questions answered correctly (for the summary screen).
  final int correctCount;

  Question get currentQuestion => lesson.questions[currentIndex];

  int get totalQuestions => lesson.questions.length;

  /// Progress across the lesson, counting the current question as underway.
  double get progress =>
      totalQuestions == 0 ? 0 : currentIndex / totalQuestions;

  bool get isLastQuestion => currentIndex >= totalQuestions - 1;

  int get accuracyPercent =>
      totalQuestions == 0 ? 0 : ((correctCount / totalQuestions) * 100).round();

  LessonState copyWith({
    int? currentIndex,
    int? hearts,
    LessonStatus? status,
    bool? lastAnswerCorrect,
    bool clearLastAnswer = false,
    int? correctCount,
  }) {
    return LessonState(
      lesson: lesson,
      currentIndex: currentIndex ?? this.currentIndex,
      hearts: hearts ?? this.hearts,
      status: status ?? this.status,
      lastAnswerCorrect:
          clearLastAnswer ? null : (lastAnswerCorrect ?? this.lastAnswerCorrect),
      correctCount: correctCount ?? this.correctCount,
    );
  }

  @override
  List<Object?> get props => [
        lesson,
        currentIndex,
        hearts,
        status,
        lastAnswerCorrect,
        correctCount,
      ];
}
