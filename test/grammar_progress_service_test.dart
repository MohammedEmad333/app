import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lingokids/features/grammar/grammar_progress_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory folder;
  setUpAll(() async {
    folder = await Directory.systemTemp.createTemp('grammar-progress-test-');
    Hive.init(folder.path);
  });
  tearDownAll(() async {
    await Hive.close();
    await folder.delete(recursive: true);
  });

  test('saves grammar scores independently and preserves the highest', () async {
    final service = GrammarProgressService.instance;
    await service.reset();
    expect(await service.bestScore('الضمائر الشخصية'), 0);
    expect(await service.recordScore('الضمائر الشخصية', 2), 2);
    expect(await service.recordScore('الضمائر الشخصية', 1), 2);
    expect(await service.bestScore('الضمائر الشخصية'), 2);
    expect(await service.bestScore('الماضي البسيط'), 0);
  });

  test('rejects invalid grammar progress', () async {
    final service = GrammarProgressService.instance;
    await expectLater(service.recordScore('', 1), throwsArgumentError);
    await expectLater(service.recordScore('الماضي البسيط', -1), throwsRangeError);
  });
}
