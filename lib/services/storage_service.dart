import 'package:hive_flutter/hive_flutter.dart';

import '../data/models/user_progress.dart';

/// Persists [UserProgress] to a Hive box as a plain map (no generated
/// adapters needed). Also owns the streak + hearts business rules.
class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  static const String _boxName = 'user_progress';
  static const String _key = 'current';

  /// One heart regenerates passively every 30 minutes (demo-friendly).
  static const Duration heartRefillInterval = Duration(minutes: 30);

  late Box _box;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
  }

  UserProgress load() {
    final raw = _box.get(_key);
    if (raw is Map) {
      return _applyPassiveRules(UserProgress.fromMap(raw));
    }
    return const UserProgress();
  }

  Future<void> save(UserProgress progress) async {
    await _box.put(_key, progress.toMap());
  }

  Future<void> reset() async {
    await _box.delete(_key);
  }

  /// Applies time-based hearts regeneration on load.
  UserProgress _applyPassiveRules(UserProgress p) {
    if (p.hearts >= UserProgress.maxHearts) return p;
    final since = p.heartsRefilledAt;
    if (since == null) return p;

    final elapsed = DateTime.now().difference(since);
    final regained = elapsed.inMinutes ~/ heartRefillInterval.inMinutes;
    if (regained <= 0) return p;

    final newHearts =
        (p.hearts + regained).clamp(0, UserProgress.maxHearts).toInt();
    final refilledAt = newHearts >= UserProgress.maxHearts
        ? null
        : since.add(heartRefillInterval * regained);
    return p.copyWith(hearts: newHearts, heartsRefilledAt: refilledAt);
  }

  /// Records a completed lesson: awards XP, advances the daily streak and
  /// marks the lesson done. Returns the updated progress.
  Future<UserProgress> completeLesson({
    required UserProgress current,
    required String lessonId,
    required int xpReward,
  }) async {
    final today = _dateOnly(DateTime.now());
    final last = current.lastActiveDate == null
        ? null
        : _dateOnly(current.lastActiveDate!);

    int streak = current.streak;
    if (last == null) {
      streak = 1;
    } else {
      final diff = today.difference(last).inDays;
      if (diff == 0) {
        streak = current.streak == 0 ? 1 : current.streak;
      } else if (diff == 1) {
        streak = current.streak + 1;
      } else {
        streak = 1; // streak broken
      }
    }

    final updated = current.copyWith(
      xp: current.xp + xpReward,
      streak: streak,
      lastActiveDate: today,
      completedLessonIds: {...current.completedLessonIds, lessonId},
    );
    await save(updated);
    return updated;
  }

  /// Deducts a heart when the learner answers incorrectly.
  Future<UserProgress> loseHeart(UserProgress current) async {
    if (current.hearts <= 0) return current;
    final updated = current.copyWith(
      hearts: current.hearts - 1,
      heartsRefilledAt: current.heartsRefilledAt ?? DateTime.now(),
    );
    await save(updated);
    return updated;
  }

  /// Fully refills hearts (e.g. from the "out of hearts" dialog).
  Future<UserProgress> refillHearts(UserProgress current) async {
    final updated = current.copyWith(
      hearts: UserProgress.maxHearts,
      heartsRefilledAt: null,
    );
    await save(updated);
    return updated;
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}
