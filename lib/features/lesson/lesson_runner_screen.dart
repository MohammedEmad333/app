import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/hearts_indicator.dart';
import '../../core/widgets/lesson_progress_bar.dart';
import '../../core/widgets/pop_button.dart';
import '../../data/models/lesson.dart';
import '../../data/models/question.dart';
import '../progress/progress_cubit.dart';
import 'cubit/lesson_cubit.dart';
import 'lesson_complete_screen.dart';
import 'widgets/feedback_sheet.dart';
import 'widgets/question_widget.dart';

class LessonRunnerScreen extends StatelessWidget {
  const LessonRunnerScreen({
    super.key,
    required this.lesson,
    this.practice = false,
  });

  final Lesson lesson;

  /// When true, runs the lesson as a no-stakes practice replay.
  final bool practice;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LessonCubit(
        lesson: lesson,
        practice: practice,
        progressCubit: context.read<ProgressCubit>(),
      ),
      child: _LessonRunnerView(practice: practice),
    );
  }
}

class _LessonRunnerView extends StatefulWidget {
  const _LessonRunnerView({required this.practice});

  final bool practice;

  @override
  State<_LessonRunnerView> createState() => _LessonRunnerViewState();
}

class _LessonRunnerViewState extends State<_LessonRunnerView> {
  /// Correctness of the current candidate answer (null = nothing selected).
  bool? _candidateCorrect;

  void _onCheck() {
    final cubit = context.read<LessonCubit>();
    cubit.submitAnswer(isCorrect: _candidateCorrect ?? false);
  }

  void _onContinue() {
    setState(() => _candidateCorrect = null);
    context.read<LessonCubit>().next();
  }

  Future<bool> _confirmQuit() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Quit lesson?', style: AppTextStyles.title),
        content: Text(
          "Your progress in this lesson won't be saved.",
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Stay', style: AppTextStyles.button
                .copyWith(color: AppColors.inkLight)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Quit', style: AppTextStyles.button
                .copyWith(color: AppColors.wrong)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LessonCubit, LessonState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == LessonStatus.finished) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => LessonCompleteScreen(
                xpEarned: widget.practice
                    ? LessonCubit.practiceXp
                    : state.lesson.xpReward,
                accuracyPercent: state.accuracyPercent,
                practice: widget.practice,
              ),
            ),
          );
        } else if (state.status == LessonStatus.failed) {
          _showOutOfHearts(context);
        }
      },
      builder: (context, state) {
        final answered = state.status == LessonStatus.answered;
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            if (await _confirmQuit() && context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  _header(context, state),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                      child: buildQuestionWidget(
                        question: state.currentQuestion,
                        showResult: answered,
                        enabled: !answered,
                        onAnswerChanged: (correct) =>
                            setState(() => _candidateCorrect = correct),
                      ),
                    ),
                  ),
                  if (!answered) _checkBar(),
                ],
              ),
            ),
            bottomSheet: answered
                ? FeedbackSheet(
                    isCorrect: state.lastAnswerCorrect ?? false,
                    correctAnswer: _correctAnswerText(state.currentQuestion),
                    explanation: state.currentQuestion.explanation,
                    onContinue: _onContinue,
                  )
                : null,
          ),
        );
      },
    );
  }

  Widget _header(BuildContext context, LessonState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close_rounded,
                color: AppColors.inkLight, size: 28),
            onPressed: () async {
              if (await _confirmQuit() && context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
          Expanded(
            child: LessonProgressBar(
              progress: state.progress,
              color: widget.practice ? AppColors.blue : AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          if (widget.practice)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.blue.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.fitness_center_rounded,
                      color: AppColors.blue, size: 18),
                  const SizedBox(width: 4),
                  Text('Practice',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.blue)),
                ],
              ),
            )
          else
            HeartsIndicator(hearts: state.hearts),
        ],
      ),
    );
  }

  Widget _checkBar() {
    final ready = _candidateCorrect != null;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: PopButton(
          label: 'Check',
          enabled: ready,
          onPressed: ready ? _onCheck : null,
        ),
      ),
    );
  }

  String _correctAnswerText(Question q) {
    switch (q.type) {
      case QuestionType.imageMatching:
      case QuestionType.audioListening:
        final opt = q.options.firstWhere(
          (o) => o.id == q.correctOptionId,
          orElse: () => q.options.first,
        );
        return opt.label;
      case QuestionType.wordJumble:
      case QuestionType.speechRecognition:
        return q.answer ?? '';
    }
  }

  void _showOutOfHearts(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.heart_broken_rounded, color: AppColors.heart),
            const SizedBox(width: 8),
            Text('Out of hearts!', style: AppTextStyles.title),
          ],
        ),
        content: Text(
          "You've run out of hearts. Refill to keep practicing!",
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // dialog
              Navigator.of(context).pop(); // lesson
            },
            child: Text('Leave',
                style: AppTextStyles.button
                    .copyWith(color: AppColors.inkLight)),
          ),
          TextButton(
            onPressed: () async {
              await context.read<ProgressCubit>().refillHearts();
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) Navigator.of(context).pop();
            },
            child: Text('Refill',
                style:
                    AppTextStyles.button.copyWith(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}
