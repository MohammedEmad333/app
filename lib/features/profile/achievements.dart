import '../../data/models/unit.dart';
import '../../data/models/user_progress.dart';

/// A single badge the learner can unlock. [unlocked] is computed from the
/// current [UserProgress]; achievements are derived, not separately stored.
class Achievement {
  const Achievement({
    required this.id,
    required this.title,
    required this.emoji,
    required this.description,
    required this.unlocked,
  });

  final String id;
  final String title;
  final String emoji;
  final String description;
  final bool unlocked;
}

/// Derives the full badge list (locked + unlocked) from progress and content.
List<Achievement> computeAchievements(UserProgress p, List<Unit> units) {
  final lessons = p.completedLessonIds.length;

  int unitsCleared = 0;
  for (final u in units) {
    if (u.lessons.isNotEmpty &&
        u.lessons.every((l) => p.isLessonCompleted(l.id))) {
      unitsCleared++;
    }
  }
  final allCleared = units.isNotEmpty && unitsCleared == units.length;

  return [
    Achievement(
      id: 'first_lesson',
      title: 'First Steps',
      emoji: '👣',
      description: 'Finish your first lesson',
      unlocked: lessons >= 1,
    ),
    Achievement(
      id: 'five_lessons',
      title: 'Getting Started',
      emoji: '⭐',
      description: 'Finish 5 lessons',
      unlocked: lessons >= 5,
    ),
    Achievement(
      id: 'ten_lessons',
      title: 'Bookworm',
      emoji: '📚',
      description: 'Finish 10 lessons',
      unlocked: lessons >= 10,
    ),
    Achievement(
      id: 'streak_3',
      title: 'On Fire',
      emoji: '🔥',
      description: 'Reach a 3-day streak',
      unlocked: p.streak >= 3,
    ),
    Achievement(
      id: 'streak_7',
      title: 'Week Warrior',
      emoji: '🗓️',
      description: 'Reach a 7-day streak',
      unlocked: p.streak >= 7,
    ),
    Achievement(
      id: 'xp_100',
      title: 'XP Hunter',
      emoji: '⚡',
      description: 'Earn 100 XP',
      unlocked: p.xp >= 100,
    ),
    Achievement(
      id: 'xp_500',
      title: 'XP Master',
      emoji: '💎',
      description: 'Earn 500 XP',
      unlocked: p.xp >= 500,
    ),
    Achievement(
      id: 'daily_goal',
      title: 'Goal Getter',
      emoji: '🎯',
      description: 'Hit your daily XP goal',
      unlocked: p.dailyGoalMet,
    ),
    Achievement(
      id: 'unit_cleared',
      title: 'Unit Cleared',
      emoji: '🏆',
      description: 'Complete a whole unit',
      unlocked: unitsCleared >= 1,
    ),
    Achievement(
      id: 'champion',
      title: 'Champion',
      emoji: '👑',
      description: 'Complete every unit',
      unlocked: allCleared,
    ),
  ];
}
