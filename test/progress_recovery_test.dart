import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:lingokids/data/models/user_progress.dart';
import 'package:lingokids/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory directory;
  late Box box;
  late DateTime clock;
  late StorageService storage;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('lingokids-recovery-');
    Hive.init(directory.path);
    box = await Hive.openBox('progress_recovery');
    clock = DateTime(2026, 10, 13, 12);
    storage = StorageService.forTesting(box, now: () => clock);
  });

  tearDown(() async {
    await box.close();
    await Hive.deleteBoxFromDisk('progress_recovery');
    await directory.delete(recursive: true);
  });

  test('completed lessons, identity, mistakes and XP survive reopening', () async {
    final saved = UserProgress(
      name: 'Mariam',
      xp: 90,
      hearts: 3,
      completedLessonIds: const {'unit1_lesson1'},
      mistakeQuestionIds: const {'q5'},
      dailyXp: 20,
      dailyXpDate: clock,
    );
    await storage.save(saved);
    await box.close();
    box = await Hive.openBox('progress_recovery');
    storage = StorageService.forTesting(box, now: () => clock);
    final restored = storage.load();
    expect(restored.name, 'Mariam');
    expect(restored.xp, 90);
    expect(restored.hearts, 3);
    expect(restored.completedLessonIds, {'unit1_lesson1'});
    expect(restored.mistakeQuestionIds, {'q5'});
    expect(restored.dailyXp, 20);
  });

  test('refilled hearts survive reopening without double regeneration', () async {
    final start = clock;
    await storage.save(UserProgress(
      hearts: 1,
      heartsRefilledAt: start,
    ));
    clock = clock.add(const Duration(minutes: 65));
    final updated = storage.load();
    expect(updated.hearts, 3);
    expect(updated.heartsRefilledAt, start.add(const Duration(minutes: 60)));
    await box.flush();
    await box.close();
    box = await Hive.openBox('progress_recovery');
    storage = StorageService.forTesting(box, now: () => clock);
    expect(storage.load().hearts, 3);
    clock = clock.add(const Duration(minutes: 25));
    expect(storage.load().hearts, 4);
  });

  test('reaching maximum hearts clears regeneration timestamp', () async {
    await storage.save(UserProgress(
      hearts: 4,
      heartsRefilledAt: clock,
    ));
    clock = clock.add(const Duration(minutes: 31));
    final restored = storage.load();
    expect(restored.hearts, UserProgress.maxHearts);
    expect(restored.heartsRefilledAt, isNull);
  });

  test('refill and spending first heart create a fresh refill timer', () async {
    final initial = UserProgress(
      hearts: 1,
      heartsRefilledAt: clock,
    );
    final full = await storage.refillHearts(initial);
    expect(full.heartsRefilledAt, isNull);
    final spent = await storage.loseHeart(full);
    expect(spent.hearts, UserProgress.maxHearts - 1);
    expect(spent.heartsRefilledAt, clock);
  });

  test('clock moving backward never adds hearts', () async {
    await storage.save(UserProgress(
      hearts: 2,
      heartsRefilledAt: clock,
    ));
    clock = clock.subtract(const Duration(minutes: 60));
    expect(storage.load().hearts, 2);
  });
}
