import 'dart:io';

import 'package:aqua_health/controller/backend.dart';
import 'package:aqua_health/health_service.dart';
import 'package:aqua_health/model/animal.dart';
import 'package:aqua_health/model/egg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;
  late FakeHealthService fakeHealthService;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('aqua_health_test_');
    Hive.init(tempDir.path);

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(AnimalAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(EggAdapter());
    }

    settingsBox = await Hive.openBox('settings');
    animalBox = await Hive.openBox<Animal>('aquarium');
    eggBox = await Hive.openBox<Egg?>('eggHolders');
    await eggBox.addAll(<Egg?>[null, null, null]);

    steps = 0;
    sleep = 0;
    stepsGoal = 1000;
    sleepGoal = 8;

    fakeHealthService = FakeHealthService();
    setHealthServiceForTesting(fakeHealthService);
  });

  tearDown(() async {
    disposeHealthPolling();
    resetHealthServiceForTesting();
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  test('real health refresh applies only new step totals once', () async {
    await eggBox.putAt(0, Egg(0, stepsGoal));

    fakeHealthService.steps = 400;
    await refresh(useRealData: true, syncedAt: DateTime(2026, 6, 6, 9));
    expect(eggBox.getAt(0)!.totalSteps, 400);

    await refresh(useRealData: true, syncedAt: DateTime(2026, 6, 6, 10));
    expect(eggBox.getAt(0)!.totalSteps, 400);

    fakeHealthService.steps = 650;
    await refresh(useRealData: true, syncedAt: DateTime(2026, 6, 6, 11));
    expect(eggBox.getAt(0)!.totalSteps, 650);

    fakeHealthService.steps = 500;
    await refresh(useRealData: true, syncedAt: DateTime(2026, 6, 6, 12));
    expect(eggBox.getAt(0)!.totalSteps, 650);

    fakeHealthService.steps = 700;
    await refresh(useRealData: true, syncedAt: DateTime(2026, 6, 6, 13));
    expect(eggBox.getAt(0)!.totalSteps, 700);
  });

  test('real sleep goal spawns at most one egg per date', () async {
    fakeHealthService.sleepHours = 8;

    await refresh(useRealData: true, syncedAt: DateTime(2026, 6, 6, 9));
    expect(_eggCount(), 1);

    await refresh(useRealData: true, syncedAt: DateTime(2026, 6, 6, 10));
    expect(_eggCount(), 1);

    await refresh(useRealData: true, syncedAt: DateTime(2026, 6, 7, 9));
    expect(_eggCount(), 2);
  });

  test('demo sleep refresh keeps existing repeatable demo behavior', () async {
    sleep = 8;

    await refresh(useRealData: false, syncedAt: DateTime(2026, 6, 6, 9));
    expect(_eggCount(), 1);

    await refresh(useRealData: false, syncedAt: DateTime(2026, 6, 6, 10));
    expect(_eggCount(), 2);
  });

  test('deleteEgg clears the matching egg slot', () async {
    final egg = Egg(0, stepsGoal);
    await eggBox.putAt(1, egg);

    expect(eggBox.getAt(1), isNotNull);
    expect(await deleteEgg(eggBox.getAt(1)!), isTrue);
    expect(eggBox.getAt(1), isNull);
    expect(eggBox.length, 3);
  });
}

int _eggCount() {
  return eggBox.values.whereType<Egg>().length;
}

class FakeHealthService extends HealthService {
  int steps = 0;
  double sleepHours = 0;

  @override
  Future<bool> requestPermissions() async => true;

  @override
  Future<int> getTodaySteps() async => steps;

  @override
  Future<double> getSleepHoursLast24Hours() async => sleepHours;
}
