import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lingokids/data/models/question.dart';
import 'package:lingokids/data/models/unit.dart';

/// Guards the bundled course content in `assets/data/units.json`.
///
/// The seed JSON is hand-authored, so these tests assert the invariants the
/// lesson runner relies on: every unit/lesson/question parses, ids are unique,
/// and each question type carries the fields its widget needs (a resolvable
/// correct option, a jumble whose answer words all live in the word bank, a
/// speech/jumble answer, …). A malformed question would otherwise only surface
/// at runtime as a stuck or unanswerable lesson.
void main() {
  late List<Unit> units;

  setUpAll(() {
    final raw = File('assets/data/units.json').readAsStringSync();
    final decoded = json.decode(raw) as List<dynamic>;
    units = decoded
        .map((e) => Unit.fromJson(e as Map<String, dynamic>))
        .toList();
  });

  test('units.json parses into at least the seeded units', () {
    expect(units.length, greaterThanOrEqualTo(12));
  });

  test('unit ids are unique and units have lessons', () {
    final ids = <String>{};
    for (final u in units) {
      expect(u.id, isNotEmpty);
      expect(ids.add(u.id), isTrue, reason: 'duplicate unit id: ${u.id}');
      expect(u.lessons, isNotEmpty, reason: '${u.id} has no lessons');
      expect(u.difficulty, greaterThanOrEqualTo(1));
    }
  });

  test('lesson ids are unique and every lesson has questions', () {
    final ids = <String>{};
    for (final u in units) {
      for (final l in u.lessons) {
        expect(l.id, isNotEmpty);
        expect(ids.add(l.id), isTrue, reason: 'duplicate lesson id: ${l.id}');
        expect(l.questions, isNotEmpty, reason: '${l.id} has no questions');
        expect(l.xpReward, greaterThan(0));
      }
    }
  });

  test('question ids are globally unique', () {
    final ids = <String>{};
    for (final u in units) {
      for (final l in u.lessons) {
        for (final q in l.questions) {
          expect(ids.add(q.id), isTrue, reason: 'duplicate question id: ${q.id}');
        }
      }
    }
  });

  test('every question is answerable for its type', () {
    for (final u in units) {
      for (final l in u.lessons) {
        for (final q in l.questions) {
          expect(q.prompt, isNotEmpty, reason: '${q.id} has an empty prompt');
          switch (q.type) {
            case QuestionType.imageMatching:
            case QuestionType.audioListening:
              expect(q.options.length, greaterThanOrEqualTo(2),
                  reason: '${q.id} needs at least two options');
              final optionIds = q.options.map((o) => o.id).toSet();
              expect(optionIds.length, q.options.length,
                  reason: '${q.id} has duplicate option ids');
              expect(optionIds.contains(q.correctOptionId), isTrue,
                  reason: '${q.id} correctOptionId does not match any option');
              break;
            case QuestionType.wordJumble:
              expect(q.answer, isNotNull, reason: '${q.id} has no answer');
              expect(q.wordBank, isNotEmpty, reason: '${q.id} has no word bank');
              for (final word in q.answer!.split(' ')) {
                expect(q.wordBank, contains(word),
                    reason: '${q.id} answer word "$word" is missing from wordBank');
              }
              break;
            case QuestionType.speechRecognition:
              expect(q.answer, isNotNull, reason: '${q.id} has no answer');
              expect(q.answer, isNotEmpty);
              break;
          }
        }
      }
    }
  });
}
