import 'package:flutter_test/flutter_test.dart';
import 'package:lingokids/data/models/user_progress.dart';
import 'package:lingokids/services/speech_service.dart';

void main() {
  test('heart refill can be cleared', () {
    final progress = UserProgress(hearts: 2, heartsRefilledAt: DateTime(2026));
    final updated = progress.copyWith(hearts: 5, heartsRefilledAt: null);
    expect(updated.hearts, 5);
    expect(updated.heartsRefilledAt, isNull);
  });

  test('heart refill is preserved if omitted', () {
    final date = DateTime(2026);
    final progress = UserProgress(heartsRefilledAt: date);
    expect(progress.copyWith(xp: 10).heartsRefilledAt, date);
  });

  test('speech requires a full phrase', () {
    expect(SpeechService.matches('HELLO, world!', 'hello world'), isTrue);
    expect(SpeechService.matches('cat', 'the cat is sleeping'), isFalse);
    expect(SpeechService.matches('', 'hello'), isFalse);
  });
}
