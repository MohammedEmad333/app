import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/user_progress.dart';
import '../../progress/progress_cubit.dart';

/// Top bar showing the learner's streak, XP and hearts — always in sync with
/// [ProgressCubit].
class StatsHeader extends StatelessWidget {
  const StatsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProgressCubit, UserProgress>(
      builder: (context, p) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _stat('🔥', '${p.streak}', AppColors.orange),
              _stat('⚡', '${p.xp}', AppColors.yellowDark),
              _stat('❤️', '${p.hearts}', AppColors.heart),
            ],
          ),
        );
      },
    );
  }

  Widget _stat(String emoji, String value, Color color) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 6),
        Text(value, style: AppTextStyles.title.copyWith(color: color)),
      ],
    );
  }
}
