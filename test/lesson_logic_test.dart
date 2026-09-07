import 'package:flutter_test/flutter_test.dart';
import 'package:lingokids/data/models/lesson.dart';
import 'package:lingokids/data/models/question.dart';
import 'package:lingokids/data/models/user_progress.dart';
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
