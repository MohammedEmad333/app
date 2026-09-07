import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/pop_button.dart';
import '../../data/models/user_progress.dart';
import '../progress/progress_cubit.dart';

/// Learner profile: level, lifetime stats, and a progress reset.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  /// Simple leveling curve: a new level every 100 XP.
  static int levelFor(int xp) => (xp ~/ 100) + 1;
  static int xpIntoLevel(int xp) => xp % 100;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(title: Text('My Profile', style: AppTextStyles.title)),
      body: BlocBuilder<ProgressCubit, UserProgress>(
        builder: (context, p) {
          final level = levelFor(p.xp);
          final into = xpIntoLevel(p.xp);
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _levelCard(level, into),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _statTile(
                        '🔥', '${p.streak}', 'Day streak', AppColors.orange),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _statTile('⚡', '${p.xp}', 'Total XP',
                        AppColors.yellowDark),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _statTile('❤️', '${p.hearts}/${UserProgress.maxHearts}',
                        'Hearts', AppColors.heart),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _statTile('🏅', '${p.completedLessonIds.length}',
                        'Lessons done', AppColors.blue),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              PopButton(
                label: 'Reset progress',
                color: AppColors.wrong,
                shadowColor: AppColors.wrongDark,
                icon: Icons.refresh_rounded,
                onPressed: () => _confirmReset(context),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _levelCard(int level, int xpIntoLevel) {
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
          const Text('🦉', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 8),
          Text('Level $level',
              style: AppTextStyles.display.copyWith(color: Colors.white)),
          const SizedBox(height: 12),
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
          const SizedBox(height: 8),
          Text('$xpIntoLevel / 100 XP to next level',
              style: AppTextStyles.caption.copyWith(color: Colors.white)),
        ],
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

  Future<void> _confirmReset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Reset progress?', style: AppTextStyles.title),
        content: Text(
          'This clears your XP, streak and completed lessons. This cannot be undone.',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: AppTextStyles.button
                    .copyWith(color: AppColors.inkLight)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Reset',
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
            content: Text('Progress reset. Fresh start! 🌱',
                style: AppTextStyles.body.copyWith(color: Colors.white)),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    }
  }
}
