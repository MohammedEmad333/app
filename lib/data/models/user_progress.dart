import 'package:equatable/equatable.dart';

/// Snapshot of the learner's persistent state: XP, streak, hearts and which
/// lessons have been completed. Kept as a plain immutable model so it can be
/// read/written through [StorageService] without codegen.
class UserProgress extends Equatable {
  const UserProgress({
    this.name = '',
    this.xp = 0,
    this.streak = 0,
    this.hearts = maxHearts,
    this.lastActiveDate,
    this.heartsRefilledAt,
    this.completedLessonIds = const {},
    this.dailyXp = 0,
    this.dailyXpDate,
    this.mistakeQuestionIds = const {},
    this.reviewSchedules = const {},
  });

  /// The learner's name, collected during onboarding. Empty until set.
  final String name;

  bool get hasOnboarded => name.trim().isNotEmpty;

  static const int maxHearts = 5;

  /// XP the learner aims to earn each day (drives the daily-goal ring).
  static const int dailyGoal = 30;

  final int xp;
  final int streak;
  final int hearts;

  /// Day of the last completed lesson (used to advance/reset the streak).
  final DateTime? lastActiveDate;

  /// When hearts were last topped up (drives passive regeneration).
  final DateTime? heartsRefilledAt;

  final Set<String> completedLessonIds;

  /// XP earned so far on [dailyXpDate]; resets when a new day starts.
  final int dailyXp;
  final DateTime? dailyXpDate;

  /// Question ids the learner has answered incorrectly and not yet re-mastered.
  /// Drives the "review your mistakes" flow.
  final Set<String> mistakeQuestionIds;

  /// Question id to spaced-review state (repetitions and next due ISO date).
  final Map<String, Map<String, dynamic>> reviewSchedules;

  /// Unresolved questions missed at least twice across attempts.
  int get difficultQuestionCount => mistakeQuestionIds.where((id) {
    final count = reviewSchedules[id]?['mistakeCount'];
    return count is int && count >= 2;
  }).length;

  /// Difficult questions that are actually due now; missing/invalid dates
  /// do not count as scheduled due reviews.
  int difficultQuestionsDueCount({DateTime? now}) {
    final time = now ?? DateTime.now();
    return mistakeQuestionIds.where((id) {
      final mistakes = reviewSchedules[id]?['mistakeCount'];
      if (mistakes is! int || mistakes < 2) return false;
      final due = DateTime.tryParse(
        reviewSchedules[id]?['dueAt']?.toString() ?? '',
      );
      return due != null && !due.isAfter(time);
    }).length;
  }

  /// Difficult unresolved questions, sorted by the existing review priority.
  List<String> prioritizedDifficultQuestionIds({DateTime? now}) =>
      prioritizedMistakeIds(now: now).where((id) {
        final count = reviewSchedules[id]?['mistakeCount'];
        return count is int && count >= 2;
      }).toList();

  bool get hasMistakes => mistakeQuestionIds.isNotEmpty;
  int get mistakeCount => mistakeQuestionIds.length;

  /// Orders practice questions by review urgency: due, unplanned, future.
  List<String> prioritizedMistakeIds({DateTime? now}) {
    final time = now ?? DateTime.now();
    DateTime? due(String id) => DateTime.tryParse(
      reviewSchedules[id]?['dueAt']?.toString() ?? '',
    );
    int bucket(String id) {
      final date = due(id);
      return date == null ? 1 : (date.isAfter(time) ? 2 : 0);
    }
    final sorted = mistakeQuestionIds.toList();
    sorted.sort((a, b) {
      final order = bucket(a).compareTo(bucket(b));
      if (order != 0) return order;
      // Within due reviews, help frequently missed items first. For
      // future reviews, preserve chronological scheduling order.
      final first = due(a);
      final second = due(b);
      if (bucket(a) == 2 && first != null && second != null) {
        final timeOrder = first.compareTo(second);
        if (timeOrder != 0) return timeOrder;
      }
      int count(String id) {
        final value = reviewSchedules[id]?['mistakeCount'];
        return value is int && value > 0 ? value : 0;
      }
      final frequency = count(b).compareTo(count(a));
      if (frequency != 0) return frequency;
      if (first != null && second != null) {
        final timeOrder = first.compareTo(second);
        if (timeOrder != 0) return timeOrder;
      }
      return a.compareTo(b);
    });
    return sorted;
  }

  bool isLessonCompleted(String id) => completedLessonIds.contains(id);

  /// Fraction (0–1) of today's XP goal that has been reached.
  double get dailyGoalProgress => (dailyXp / dailyGoal).clamp(0.0, 1.0);
  bool get dailyGoalMet => dailyXp >= dailyGoal;

  static const Object _unset = Object();

  UserProgress copyWith({
    String? name,
    int? xp,
    int? streak,
    int? hearts,
    DateTime? lastActiveDate,
    Object? heartsRefilledAt = _unset,
    Set<String>? completedLessonIds,
    int? dailyXp,
    DateTime? dailyXpDate,
    Set<String>? mistakeQuestionIds,
    Map<String, Map<String, dynamic>>? reviewSchedules,
  }) {
    return UserProgress(
      name: name ?? this.name,
      xp: xp ?? this.xp,
      streak: streak ?? this.streak,
      hearts: hearts ?? this.hearts,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      heartsRefilledAt: identical(heartsRefilledAt, _unset)
          ? this.heartsRefilledAt
          : heartsRefilledAt as DateTime?,
      completedLessonIds: completedLessonIds ?? this.completedLessonIds,
      dailyXp: dailyXp ?? this.dailyXp,
      dailyXpDate: dailyXpDate ?? this.dailyXpDate,
      mistakeQuestionIds: mistakeQuestionIds ?? this.mistakeQuestionIds,
      reviewSchedules: reviewSchedules ?? this.reviewSchedules,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'xp': xp,
        'streak': streak,
        'hearts': hearts,
        'lastActiveDate': lastActiveDate?.toIso8601String(),
        'heartsRefilledAt': heartsRefilledAt?.toIso8601String(),
        'completedLessonIds': completedLessonIds.toList(),
        'dailyXp': dailyXp,
        'dailyXpDate': dailyXpDate?.toIso8601String(),
        'mistakeQuestionIds': mistakeQuestionIds.toList(),
        'reviewSchedules': reviewSchedules,
      };

  factory UserProgress.fromMap(Map<dynamic, dynamic> map) {
    return UserProgress(
      name: (map['name'] as String?) ?? '',
      xp: (map['xp'] as int?) ?? 0,
      streak: (map['streak'] as int?) ?? 0,
      hearts: (map['hearts'] as int?) ?? maxHearts,
      lastActiveDate: _parseDate(map['lastActiveDate']),
      heartsRefilledAt: _parseDate(map['heartsRefilledAt']),
      completedLessonIds: ((map['completedLessonIds'] as List<dynamic>?) ?? [])
          .map((e) => e.toString())
          .toSet(),
      dailyXp: (map['dailyXp'] as int?) ?? 0,
      dailyXpDate: _parseDate(map['dailyXpDate']),
      mistakeQuestionIds:
          ((map['mistakeQuestionIds'] as List<dynamic>?) ?? [])
              .map((e) => e.toString())
              .toSet(),
      reviewSchedules: (map['reviewSchedules'] is Map)
          ? (map['reviewSchedules'] as Map).map((key, value) => MapEntry(
              key.toString(), Map<String, dynamic>.from(value as Map)))
          : const {},
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
    return null;
  }

  @override
  List<Object?> get props => [
        name,
        xp,
        streak,
        hearts,
        lastActiveDate,
        heartsRefilledAt,
        completedLessonIds,
        dailyXp,
        dailyXpDate,
        mistakeQuestionIds,
        reviewSchedules,
      ];
}
