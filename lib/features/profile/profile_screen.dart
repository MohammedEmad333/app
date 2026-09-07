import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/daily_goal_ring.dart';
import '../../core/widgets/pop_button.dart';
import '../../data/models/lesson.dart';
import '../../data/models/unit.dart';
import '../../data/models/user_progress.dart';
import '../../data/repositories/content_repository.dart';
import '../lesson/lesson_runner_screen.dart';
import '../progress/progress_cubit.dart';
import 'achievements.dart';

/// Learner profile: level, daily goal, lifetime stats, achievement badges,
/// a practice shortcut, and a progress reset.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  /// Simple leveling curve: a new level every 100 XP.
  static int levelFor(int xp) => (xp ~/ 100) + 1;
  static int xpIntoLevel(int xp) => xp % 100;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final Future<List<Unit>> _unitsFuture;

  @override
  void initState() {
    super.initState();
    _unitsFuture = ContentRepository.instance.loadUnits();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar:
          AppBar(title: Text(AppStrings.profileTitle, style: AppTextStyles.title)),
      body: FutureBuilder<List<Unit>>(
        future: _unitsFuture,
        builder: (context, snapshot) {
          final units = snapshot.data ?? const <Unit>[];
          return BlocBuilder<ProgressCubit, UserProgress>(
            builder: (context, p) {
              final level = ProfileScreen.levelFor(p.xp);
              final into = ProfileScreen.xpIntoLevel(p.xp);
              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _levelCard(level, into, p),
                  const SizedBox(height: 20),
                  _statsGrid(p),
                  const SizedBox(height: 28),
                  _sectionTitle(AppStrings.achievements),
                  const SizedBox(height: 12),
                  _achievements(p, units),
                  const SizedBox(height: 28),
                  if (p.completedLessonIds.isNotEmpty) ...[
                    PopButton(
                      label: AppStrings.practiceALesson,
                      color: AppColors.blue,
                      shadowColor: AppColors.blueDark,
                      icon: Icons.fitness_center_rounded,
                      onPressed: () => _practiceRandom(context, units, p),
                    ),
                    const SizedBox(height: 14),
                  ],
                  PopButton(
                    label: AppStrings.resetProgress,
                    color: AppColors.wrong,
                    shadowColor: AppColors.wrongDark,
                    icon: Icons.refresh_rounded,
                    onPressed: () => _confirmReset(context),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _levelCard(int level, int xpIntoLevel, UserProgress p) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        border: const Border(
          bottom: BorderSide(color: AppColors.primaryDark, width: 6),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text('🦉', style: TextStyle(fontSize: 56)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppStrings.levelLabel(level),
                        style: AppTextStyles.display
                            .copyWith(color: Colors.white)),
                    Text(AppStrings.xpToNextLevel(xpIntoLevel),
                        style: AppTextStyles.caption
                            .copyWith(color: Colors.white)),
                  ],
                ),
              ),
              DailyGoalRing(
                dailyXp: p.dailyXp,
                goal: UserProgress.dailyGoal,
                size: 60,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: xpIntoLevel / 100,
              minHeight: 14,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.yellow),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statsGrid(UserProgress p) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: _statTile('🔥', AppStrings.arDigits(p.streak),
                    AppStrings.statStreak, AppColors.orange)),
            const SizedBox(width: 14),
            Expanded(
                child: _statTile('⚡', AppStrings.arDigits(p.xp),
                    AppStrings.statXp, AppColors.yellowDark)),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
                child: _statTile(
                    '❤️',
                    '${AppStrings.arDigits(p.hearts)}/${AppStrings.arDigits(UserProgress.maxHearts)}',
                    AppStrings.statHearts,
                    AppColors.heart)),
            const SizedBox(width: 14),
            Expanded(
                child: _statTile(
                    '🏅',
                    AppStrings.arDigits(p.completedLessonIds.length),
                    AppStrings.statLessons,
                    AppColors.blue)),
          ],
        ),
      ],
    );
  }

  Widget _sectionTitle(String text) =>
      Align(alignment: Alignment.centerLeft, child: Text(text, style: AppTextStyles.heading));

  Widget _achievements(UserProgress p, List<Unit> units) {
    final list = computeAchievements(p, units);
    final unlocked = list.where((a) => a.unlocked).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.achievementsUnlocked(unlocked, list.length),
            style: AppTextStyles.caption),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: list.map(_badge).toList(),
        ),
      ],
    );
  }

  Widget _badge(Achievement a) {
    return Semantics(
      label: '${a.title}، ${a.unlocked ? "مفتوح" : "مغلق"}: ${a.description}',
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: a.unlocked ? Colors.white : const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: a.unlocked ? AppColors.yellow : AppColors.border,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Opacity(
              opacity: a.unlocked ? 1 : 0.35,
              child: Text(a.emoji, style: const TextStyle(fontSize: 36)),
            ),
            const SizedBox(height: 6),
            Text(
              a.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(
                color: a.unlocked ? AppColors.ink : AppColors.disabledText,
              ),
            ),
            if (!a.unlocked)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Icon(Icons.lock_rounded,
                    size: 14, color: AppColors.disabledText),
              ),
          ],
        ),
      ),
    );
  }

  Widget _statTile(String emoji, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 2),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 30)),
          const SizedBox(height: 6),
          Text(value, style: AppTextStyles.heading.copyWith(color: color)),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }

  void _practiceRandom(
      BuildContext context, List<Unit> units, UserProgress p) {
    final completed = <Lesson>[
      for (final u in units)
        for (final l in u.lessons)
          if (p.isLessonCompleted(l.id)) l,
    ];
    if (completed.isEmpty) return;
    final lesson = completed[Random().nextInt(completed.length)];
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LessonRunnerScreen(lesson: lesson, practice: true),
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(AppStrings.resetTitle, style: AppTextStyles.title),
        content: Text(AppStrings.resetBody, style: AppTextStyles.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppStrings.cancel,
                style: AppTextStyles.button
                    .copyWith(color: AppColors.inkLight)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppStrings.reset,
                style:
                    AppTextStyles.button.copyWith(color: AppColors.wrong)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<ProgressCubit>().reset();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.resetDone,
                style: AppTextStyles.body.copyWith(color: Colors.white)),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    }
  }
}
