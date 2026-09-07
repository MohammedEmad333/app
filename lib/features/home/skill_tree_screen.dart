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
                          for (int u = 0; u < units.length; u++)
                            _UnitSection(
                              unit: units[u],
                              progress: progress,
                              // A unit is locked until the previous unit is
                              // fully completed, so difficulty is earned.
                              locked: u > 0 &&
                                  !units[u - 1].lessons.every((l) =>
                                      progress.isLessonCompleted(l.id)),
                              onTapLesson: (lesson) =>
                                  _openLesson(context, lesson, progress),
                              onLockedTap: () => _showLocked(context),
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
          Expanded(
            child: BlocBuilder<ProgressCubit, UserProgress>(
              buildWhen: (a, b) => a.name != b.name,
              builder: (context, p) => Text(
                p.hasOnboarded ? AppStrings.greeting(p.name) : AppStrings.appName,
                style: AppTextStyles.heading,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
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

  void _showLocked(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.unitLocked,
            style: AppTextStyles.body.copyWith(color: Colors.white)),
        backgroundColor: AppColors.inkLight,
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
    this.locked = false,
    required this.onLockedTap,
  });

  final Unit unit;
  final UserProgress progress;
  final bool locked;
  final ValueChanged<Lesson> onTapLesson;
  final VoidCallback onLockedTap;

  @override
  Widget build(BuildContext context) {
    final unitColor = Color(unit.colorValue);
    // The current lesson is the first not-yet-completed one in order.
    final currentIndex =
        unit.lessons.indexWhere((l) => !progress.isLessonCompleted(l.id));

    final completedInUnit =
        unit.lessons.where((l) => progress.isLessonCompleted(l.id)).length;

    final section = Column(
      children: [
        _banner(unitColor, completedInUnit, unit.lessons.length, locked),
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
              status: locked
                  ? NodeStatus.locked
                  : _statusFor(i, currentIndex),
              onTap: () =>
                  locked ? onLockedTap() : onTapLesson(unit.lessons[i]),
            ),
          ),
        const SizedBox(height: 12),
      ],
    );

    if (!locked) return section;
    // Dim the locked unit and make the whole area explain why it's locked.
    return GestureDetector(
      onTap: onLockedTap,
      child: Opacity(opacity: 0.55, child: section),
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

  Widget _banner(Color unitColor, int completed, int total, bool locked) {
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(
                      locked
                          ? Icons.lock_rounded
                          : (done
                              ? Icons.emoji_events_rounded
                              : Icons.school_rounded),
                      color: done && !locked ? AppColors.yellow : Colors.white,
                      size: 34),
                  const SizedBox(height: 8),
                  _difficultyPill(unit.difficulty),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (locked)
            Row(
              children: [
                const Icon(Icons.lock_rounded, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(AppStrings.unitLockedBanner,
                    style: AppTextStyles.caption
                        .copyWith(color: Colors.white, fontSize: 14)),
              ],
            )
          else
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

  /// Small pill showing the unit's difficulty as filled/empty dots plus an
  /// Arabic label (سهل / متوسط / صعب / متقدّم).
  Widget _difficultyPill(int difficulty) {
    const maxTier = 4;
    final tier = difficulty.clamp(1, maxTier);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < maxTier; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: Icon(
                i < tier ? Icons.circle : Icons.circle_outlined,
                size: 9,
                color: Colors.white,
              ),
            ),
          const SizedBox(width: 6),
          Text(AppStrings.difficultyLabel(tier),
              style: AppTextStyles.caption
                  .copyWith(color: Colors.white, fontSize: 12)),
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
