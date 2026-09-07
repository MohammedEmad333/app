import 'package:flutter_test/flutter_test.dart';
import 'package:lingokids/data/models/lesson.dart';
import 'package:lingokids/data/models/question.dart';
import 'package:lingokids/data/models/user_progress.dart';
import 'package:lingokids/data/models/unit.dart';
import 'package:lingokids/features/profile/achievements.dart';
import 'package:lingokids/features/profile/profile_screen.dart';
import 'package:lingokids/services/speech_service.dart';

void main() {
  group('Question model', () {
    test('parses an image-matching question from JSON', () {
      final q = Question.fromJson({
        'id': 'q1',
        'type': 'imageMatching',
        'prompt': 'Which is a cow?',
        'correctOptionId': 'o1',
        'options': [
          {'id': 'o1', 'label': 'Cow', 'emoji': '🐄'},
          {'id': 'o2', 'label': 'Cat', 'emoji': '🐱'},
        ],
      });
      expect(q.type, QuestionType.imageMatching);
      expect(q.options.length, 2);
      expect(q.correctOptionId, 'o1');
    });

    test('unknown type falls back to imageMatching', () {
      final q = Question.fromJson({
        'id': 'q',
        'type': 'nonsense',
        'prompt': 'x',
      });
      expect(q.type, QuestionType.imageMatching);
    });
  });

  group('Unit difficulty', () {
    test('defaults to 1 and round-trips through JSON', () {
      final u = Unit.fromJson({
        'id': 'u',
        'title': 't',
        'colorValue': 0xFF000000,
        'lessons': [],
      });
      expect(u.difficulty, 1);

      final u2 = Unit.fromJson({
        'id': 'u2',
        'title': 't2',
        'colorValue': 0xFF000000,
        'difficulty': 4,
        'lessons': [],
      });
      expect(u2.difficulty, 4);
      expect(Unit.fromJson(u2.toJson()).difficulty, 4);
    });
  });

  group('Lesson model', () {
    test('reports question count', () {
      const lesson = Lesson(
        id: 'l1',
        title: 'Test',
        icon: '⭐',
        xpReward: 20,
        questions: [
          Question(id: 'a', type: QuestionType.wordJumble, prompt: 'p'),
          Question(id: 'b', type: QuestionType.wordJumble, prompt: 'p'),
        ],
      );
      expect(lesson.questionCount, 2);
    });
  });

  group('UserProgress', () {
    test('round-trips through map serialization', () {
      final p = UserProgress(
        xp: 40,
        streak: 3,
        hearts: 4,
        completedLessonIds: const {'u1_l1'},
        lastActiveDate: DateTime(2026, 1, 1),
      );
      final restored = UserProgress.fromMap(p.toMap());
      expect(restored.xp, 40);
      expect(restored.streak, 3);
      expect(restored.hearts, 4);
      expect(restored.isLessonCompleted('u1_l1'), isTrue);
      expect(restored.lastActiveDate, DateTime(2026, 1, 1));
    });
  });

  group('ProfileScreen leveling', () {
    test('level increments every 100 XP', () {
      expect(ProfileScreen.levelFor(0), 1);
      expect(ProfileScreen.levelFor(99), 1);
      expect(ProfileScreen.levelFor(100), 2);
      expect(ProfileScreen.levelFor(250), 3);
    });

    test('xpIntoLevel is the remainder toward the next level', () {
      expect(ProfileScreen.xpIntoLevel(0), 0);
      expect(ProfileScreen.xpIntoLevel(150), 50);
      expect(ProfileScreen.xpIntoLevel(295), 95);
    });
  });

  group('Daily goal', () {
    test('progress and met flag track dailyXp against the goal', () {
      const p = UserProgress(dailyXp: 15);
      expect(p.dailyGoalProgress, closeTo(15 / UserProgress.dailyGoal, 1e-9));
      expect(p.dailyGoalMet, isFalse);

      const done = UserProgress(dailyXp: UserProgress.dailyGoal + 5);
      expect(done.dailyGoalProgress, 1.0);
      expect(done.dailyGoalMet, isTrue);
    });

    test('daily fields survive serialization', () {
      final p = UserProgress(dailyXp: 20, dailyXpDate: DateTime(2026, 2, 3));
      final restored = UserProgress.fromMap(p.toMap());
      expect(restored.dailyXp, 20);
      expect(restored.dailyXpDate, DateTime(2026, 2, 3));
    });
  });

  group('Achievements', () {
    final units = [
      const Unit(
        id: 'u1',
        title: 'U1',
        subtitle: '',
        colorValue: 0xFF000000,
        lessons: [
          Lesson(id: 'a', title: 'A', icon: '', xpReward: 10, questions: []),
          Lesson(id: 'b', title: 'B', icon: '', xpReward: 10, questions: []),
        ],
      ),
    ];

    bool unlocked(List<Achievement> l, String id) =>
        l.firstWhere((a) => a.id == id).unlocked;

    test('first lesson and unit clear unlock as progress is made', () {
      final none = computeAchievements(const UserProgress(), units);
      expect(unlocked(none, 'first_lesson'), isFalse);
      expect(unlocked(none, 'unit_cleared'), isFalse);
      expect(unlocked(none, 'champion'), isFalse);

      const partial = UserProgress(completedLessonIds: {'a'});
      expect(unlocked(computeAchievements(partial, units), 'first_lesson'),
          isTrue);
      expect(unlocked(computeAchievements(partial, units), 'unit_cleared'),
          isFalse);

      const full = UserProgress(completedLessonIds: {'a', 'b'});
      final fa = computeAchievements(full, units);
      expect(unlocked(fa, 'unit_cleared'), isTrue);
      expect(unlocked(fa, 'champion'), isTrue);
    });

    test('streak and xp badges respond to thresholds', () {
      const p = UserProgress(xp: 120, streak: 3);
      final a = computeAchievements(p, units);
      expect(unlocked(a, 'streak_3'), isTrue);
      expect(unlocked(a, 'streak_7'), isFalse);
      expect(unlocked(a, 'xp_100'), isTrue);
      expect(unlocked(a, 'xp_500'), isFalse);
    });
  });

  group('SpeechService.matches', () {
    test('is case- and punctuation-insensitive', () {
      expect(SpeechService.matches('Thank you!', 'thank you'), isTrue);
      expect(SpeechService.matches('  HORSE ', 'Horse'), isTrue);
    });

    test('accepts containment', () {
      expect(SpeechService.matches('a tiger', 'Tiger'), isTrue);
    });

    test('rejects empty and mismatched speech', () {
      expect(SpeechService.matches('', 'Tiger'), isFalse);
      expect(SpeechService.matches('lion', 'Tiger'), isFalse);
    });
  });
}
