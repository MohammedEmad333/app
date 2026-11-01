import 'package:flutter_test/flutter_test.dart';
import 'package:lingokids/features/grammar/grammar_progress_store.dart';

void main() {
  test('mastery summary calculates completion and review safely', () {
    const summary = GrammarMasterySummary(
      totalTopics: 20,
      completedTopics: 8,
      perfectTopics: 3,
      totalAttempts: 15,
      averageBestScore: 75,
    );
    expect(summary.reviewTopics, 5);
    expect(summary.completionRatio, 0.4);
    expect(summary.totalAttempts, 15);
  });

  test('empty catalog does not divide by zero', () {
    const summary = GrammarMasterySummary(
      totalTopics: 0,
      completedTopics: 0,
      perfectTopics: 0,
      totalAttempts: 0,
      averageBestScore: 0,
    );
    expect(summary.completionRatio, 0);
    expect(summary.reviewTopics, 0);
  });
}
