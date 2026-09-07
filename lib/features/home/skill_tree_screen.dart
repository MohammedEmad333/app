import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/daily_goal_ring.dart';
import '../../data/models/lesson.dart';
import '../../data/models/unit.dart';
import '../../data/models/user_progress.dart';
import '../../data/repositories/content_repository.dart';
import '../lesson/lesson_runner_screen.dart';
import '../profile/profile_screen.dart';
import '../progress/progress_cubit.dart';
import 'widgets/lesson_node.dart';
import 'widgets/stats_header.dart';

/// The map / skill-tree home screen: a winding path of lesson nodes grouped
/// under units, with live locked / current / completed status.
class SkillTreeScreen extends StatefulWidget {
  const SkillTreeScreen({super.key});

  @override
  State<SkillTreeScreen> createState() => _SkillTreeScreenState();
}

class _SkillTreeScreenState extends State<SkillTreeScreen> {
  late Future<List<Unit>> _unitsFuture;

  @override
  void initState() {
    super.initState();
    _unitsFuture = ContentRepository.instance.loadUnits();
    // Regenerate hearts based on elapsed time when returning to the map.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<ProgressCubit>().refresh(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: FutureBuilder<List<Unit>>(
          future: _unitsFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final units = snapshot.data!;
            return Column(
              children: [
                _topBar(context),
                const StatsHeader(),
                const Divider(height: 1, color: AppColors.border),
                Expanded(
                  child: BlocBuilder<ProgressCubit, UserProgress>(
                    builder: (context, progress) {
                      return ListView(
                        padding: const EdgeInsets.only(top: 8, bottom: 40),
                        children: [
                          DailyGoalBanner(
                            dailyXp: progress.dailyXp,
                            goal: UserProgress.dailyGoal,
                          ),
                          for (final unit in units)
                            _UnitSection(
                              unit: unit,
                              progress: progress,
                              onTapLesson: (lesson) =>
                                  _openLesson(context, lesson, progress),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 12, 0),
      child: Row(
        children: [
          const Text('🦉', style: TextStyle(fontSize: 26)),
          const SizedBox(width: 8),
          Text(AppStrings.appName, style: AppTextStyles.heading),
          const Spacer(),
          IconButton(
            tooltip: AppStrings.profileTooltip,
            icon: const Icon(Icons.account_circle_rounded,
                color: AppColors.blue, size: 32),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
          ),
        ],
      ),
    );
  }

  void _openLesson(
      BuildContext context, Lesson lesson, UserProgress progress) {
    // A completed lesson re-opens as a no-stakes practice replay.
    final isPractice = progress.isLessonCompleted(lesson.id);

    if (!isPractice && progress.hearts <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.noHeartsLeft,
              style: AppTextStyles.body.copyWith(color: Colors.white)),
          backgroundColor: AppColors.wrong,
        ),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LessonRunnerScreen(lesson: lesson, practice: isPractice),
      ),
    );
  }
}

class _UnitSection extends StatelessWidget {
  const _UnitSection({
    required this.unit,
    required this.progress,
    required this.onTapLesson,
  });

  final Unit unit;
  final UserProgress progress;
  final ValueChanged<Lesson> onTapLesson;

  @override
  Widget build(BuildContext context) {
    final unitColor = Color(unit.colorValue);
    // The current lesson is the first not-yet-completed one in order.
    final currentIndex =
        unit.lessons.indexWhere((l) => !progress.isLessonCompleted(l.id));

    final completedInUnit =
        unit.lessons.where((l) => progress.isLessonCompleted(l.id)).length;

    return Column(
      children: [
        _banner(unitColor, completedInUnit, unit.lessons.length),
        const SizedBox(height: 8),
        for (int i = 0; i < unit.lessons.length; i++)
          Padding(
            padding: EdgeInsets.only(
              top: i == 0 ? 8 : 20,
              // Alternate left/right to create a winding path.
              left: i.isEven ? 0 : 90,
              right: i.isEven ? 90 : 0,
            ),
            child: LessonNode(
              title: unit.lessons[i].title,
              icon: unit.lessons[i].icon,
              color: unitColor,
              status: _statusFor(i, currentIndex),
              onTap: () => onTapLesson(unit.lessons[i]),
            ),
          ),
        const SizedBox(height: 12),
      ],
    );
  }

  NodeStatus _statusFor(int index, int currentIndex) {
    if (progress.isLessonCompleted(unit.lessons[index].id)) {
      return NodeStatus.completed;
    }
    // All lessons done -> currentIndex == -1, nothing is "current".
    if (index == currentIndex) return NodeStatus.current;
    if (currentIndex == -1) return NodeStatus.completed;
    return index < currentIndex ? NodeStatus.completed : NodeStatus.locked;
  }

  Widget _banner(Color unitColor, int completed, int total) {
    final done = total > 0 && completed >= total;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: unitColor,
        borderRadius: BorderRadius.circular(20),
        border: Border(
          bottom: BorderSide(color: _darken(unitColor), width: 5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(unit.title,
                        style: AppTextStyles.heading
                            .copyWith(color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(unit.subtitle,
                        style: AppTextStyles.body.copyWith(
                            color: Colors.white.withValues(alpha: 0.9))),
                  ],
                ),
              ),
              Icon(done ? Icons.emoji_events_rounded : Icons.school_rounded,
                  color: done ? AppColors.yellow : Colors.white, size: 34),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: total == 0 ? 0 : completed / total,
                    minHeight: 10,
                    backgroundColor: Colors.white.withValues(alpha: 0.35),
                    valueColor: AlwaysStoppedAnimation<Color>(
                        done ? AppColors.yellow : Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Row(
                children: [
                  const Icon(Icons.emoji_events_rounded,
                      color: AppColors.yellow, size: 18),
                  const SizedBox(width: 4),
                  Text(
                      '${AppStrings.arDigits(completed)}/${AppStrings.arDigits(total)}',
                      style: AppTextStyles.caption
                          .copyWith(color: Colors.white, fontSize: 14)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Color _darken(Color c, [double amount = 0.18]) {
    final hsl = HSLColor.fromColor(c);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }
}
