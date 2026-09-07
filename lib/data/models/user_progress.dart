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

  bool get hasMistakes => mistakeQuestionIds.isNotEmpty;
  int get mistakeCount => mistakeQuestionIds.length;

  bool isLessonCompleted(String id) => completedLessonIds.contains(id);

  /// Fraction (0–1) of today's XP goal that has been reached.
  double get dailyGoalProgress => (dailyXp / dailyGoal).clamp(0.0, 1.0);
  bool get dailyGoalMet => dailyXp >= dailyGoal;

  UserProgress copyWith({
    String? name,
    int? xp,
    int? streak,
    int? hearts,
    DateTime? lastActiveDate,
    DateTime? heartsRefilledAt,
    Set<String>? completedLessonIds,
    int? dailyXp,
    DateTime? dailyXpDate,
    Set<String>? mistakeQuestionIds,
  }) {
    return UserProgress(
      name: name ?? this.name,
      xp: xp ?? this.xp,
      streak: streak ?? this.streak,
      hearts: hearts ?? this.hearts,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      heartsRefilledAt: heartsRefilledAt ?? this.heartsRefilledAt,
      completedLessonIds: completedLessonIds ?? this.completedLessonIds,
      dailyXp: dailyXp ?? this.dailyXp,
      dailyXpDate: dailyXpDate ?? this.dailyXpDate,
      mistakeQuestionIds: mistakeQuestionIds ?? this.mistakeQuestionIds,
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
      ];
}
