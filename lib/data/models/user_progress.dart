import 'package:equatable/equatable.dart';

/// Snapshot of the learner's persistent state: XP, streak, hearts and which
/// lessons have been completed. Kept as a plain immutable model so it can be
/// read/written through [StorageService] without codegen.
class UserProgress extends Equatable {
  const UserProgress({
    this.xp = 0,
    this.streak = 0,
    this.hearts = maxHearts,
    this.lastActiveDate,
    this.heartsRefilledAt,
    this.completedLessonIds = const {},
  });

  static const int maxHearts = 5;

  final int xp;
  final int streak;
  final int hearts;

  /// Day of the last completed lesson (used to advance/reset the streak).
  final DateTime? lastActiveDate;

  /// When hearts were last topped up (drives passive regeneration).
  final DateTime? heartsRefilledAt;

  final Set<String> completedLessonIds;

  bool isLessonCompleted(String id) => completedLessonIds.contains(id);

  UserProgress copyWith({
    int? xp,
    int? streak,
    int? hearts,
    DateTime? lastActiveDate,
    DateTime? heartsRefilledAt,
    Set<String>? completedLessonIds,
  }) {
    return UserProgress(
      xp: xp ?? this.xp,
      streak: streak ?? this.streak,
      hearts: hearts ?? this.hearts,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      heartsRefilledAt: heartsRefilledAt ?? this.heartsRefilledAt,
      completedLessonIds: completedLessonIds ?? this.completedLessonIds,
    );
  }

  Map<String, dynamic> toMap() => {
        'xp': xp,
        'streak': streak,
        'hearts': hearts,
        'lastActiveDate': lastActiveDate?.toIso8601String(),
        'heartsRefilledAt': heartsRefilledAt?.toIso8601String(),
        'completedLessonIds': completedLessonIds.toList(),
      };

  factory UserProgress.fromMap(Map<dynamic, dynamic> map) {
    return UserProgress(
      xp: (map['xp'] as int?) ?? 0,
      streak: (map['streak'] as int?) ?? 0,
      hearts: (map['hearts'] as int?) ?? maxHearts,
      lastActiveDate: _parseDate(map['lastActiveDate']),
      heartsRefilledAt: _parseDate(map['heartsRefilledAt']),
      completedLessonIds: ((map['completedLessonIds'] as List<dynamic>?) ?? [])
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
        xp,
        streak,
        hearts,
        lastActiveDate,
        heartsRefilledAt,
        completedLessonIds,
      ];
}
