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
      title: 'الخطوة الأولى',
      emoji: '👣',
      description: 'أكمل أول درس',
      unlocked: lessons >= 1,
    ),
    Achievement(
      id: 'five_lessons',
      title: 'انطلاقة',
      emoji: '⭐',
      description: 'أكمل ٥ دروس',
      unlocked: lessons >= 5,
    ),
    Achievement(
      id: 'ten_lessons',
      title: 'محب للقراءة',
      emoji: '📚',
      description: 'أكمل ١٠ دروس',
      unlocked: lessons >= 10,
    ),
    Achievement(
      id: 'streak_3',
      title: 'متحمّس',
      emoji: '🔥',
      description: 'واظب ٣ أيام متتالية',
      unlocked: p.streak >= 3,
    ),
    Achievement(
      id: 'streak_7',
      title: 'بطل الأسبوع',
      emoji: '🗓️',
      description: 'واظب ٧ أيام متتالية',
      unlocked: p.streak >= 7,
    ),
    Achievement(
      id: 'xp_100',
      title: 'جامع النقاط',
      emoji: '⚡',
      description: 'اجمع ١٠٠ نقطة',
      unlocked: p.xp >= 100,
    ),
    Achievement(
      id: 'xp_500',
      title: 'خبير النقاط',
      emoji: '💎',
      description: 'اجمع ٥٠٠ نقطة',
      unlocked: p.xp >= 500,
    ),
    Achievement(
      id: 'daily_goal',
      title: 'محقّق الهدف',
      emoji: '🎯',
      description: 'حقّق هدفك اليومي',
      unlocked: p.dailyGoalMet,
    ),
    Achievement(
      id: 'unit_cleared',
      title: 'أنهى وحدة',
      emoji: '🏆',
      description: 'أكمل وحدة كاملة',
      unlocked: unitsCleared >= 1,
    ),
    Achievement(
      id: 'champion',
      title: 'البطل',
      emoji: '👑',
      description: 'أكمل كل الوحدات',
      unlocked: allCleared,
    ),
  ];
}
