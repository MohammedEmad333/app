import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Circular daily-XP goal indicator. Fills as the learner earns XP toward the
/// day's goal and shows a check once met.
class DailyGoalRing extends StatelessWidget {
  const DailyGoalRing({
    super.key,
    required this.dailyXp,
    required this.goal,
    this.size = 64,
  });

  final int dailyXp;
  final int goal;
  final double size;

  @override
  Widget build(BuildContext context) {
    final progress = goal == 0 ? 0.0 : (dailyXp / goal).clamp(0.0, 1.0);
    final met = dailyXp >= goal;
    final ringColor = met ? AppColors.primary : AppColors.yellow;

    return Semantics(
      label: 'Daily goal: $dailyXp of $goal XP',
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 6,
                backgroundColor: AppColors.trackGrey,
                valueColor: AlwaysStoppedAnimation<Color>(ringColor),
                strokeCap: StrokeCap.round,
              ),
            ),
            met
                ? Icon(Icons.check_rounded,
                    color: AppColors.primary, size: size * 0.4)
                : Text('⚡',
                    style: TextStyle(fontSize: size * 0.32)),
          ],
        ),
      ),
    );
  }
}

/// Compact daily-goal banner used on the map: ring + label + XP-to-go text.
class DailyGoalBanner extends StatelessWidget {
  const DailyGoalBanner({
    super.key,
    required this.dailyXp,
    required this.goal,
  });

  final int dailyXp;
  final int goal;

  @override
  Widget build(BuildContext context) {
    final met = dailyXp >= goal;
    final remaining = (goal - dailyXp).clamp(0, goal);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 2),
      ),
      child: Row(
        children: [
          DailyGoalRing(dailyXp: dailyXp, goal: goal, size: 46),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Daily Goal', style: AppTextStyles.title),
                const SizedBox(height: 2),
                Text(
                  met
                      ? 'Done for today — great work! 🎉'
                      : '$remaining XP to go ($dailyXp/$goal)',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
