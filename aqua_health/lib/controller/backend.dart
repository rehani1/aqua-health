import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import '../model/egg.dart';
import '../model/animal.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../health_service.dart';

late Box<Animal> animalBox;
late Box<Egg?> eggBox;
late Box settingsBox;

int steps = 0;
double sleep = 0;
double sleepGoal = 8;
int stepsGoal = 10000;
Timer? _healthTimer;
HealthService _healthService = HealthService();

const String _lastSyncedStepDateKey = 'lastSyncedStepDate';
const String _lastSyncedStepCountKey = 'lastSyncedStepCount';
const String _lastSleepRewardDateKey = 'lastSleepRewardDate';

@visibleForTesting
void setHealthServiceForTesting(HealthService healthService) {
  _healthService = healthService;
}

@visibleForTesting
void resetHealthServiceForTesting() {
  _healthService = HealthService();
}

Future<void> initHive() async {
  await Hive.initFlutter();
  settingsBox = await Hive.openBox('settings');

  stepsGoal = (settingsBox.get('stepsGoal', defaultValue: stepsGoal) as num)
      .toInt();
  sleepGoal = (settingsBox.get('sleepGoal', defaultValue: sleepGoal) as num)
      .toDouble();

  // Register adapters generated in step 2
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(AnimalAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(EggAdapter());
  }

  animalBox = await Hive.openBox<Animal>('aquarium');
  eggBox = await Hive.openBox<Egg?>('eggHolders');

  if (eggBox.length < 3) {
    await eggBox.clear();
    await eggBox.addAll([null, null, null]);
  }
}

Future<void> initHealthData() async {
  await refresh();
}

Future<bool> requestHealthPermissions() {
  return _healthService.requestPermissions();
}

Future<int> getSteps() async {
  return _healthService.getTodaySteps();
}

Future<double> getSleep() {
  return _healthService.getSleepHoursLast24Hours();
}

void startHealthPolling() {
  _healthTimer?.cancel();

  _healthTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
    await refresh();
  });
}

void startStepsPolling() {
  startHealthPolling();
}

void disposeHealthPolling() {
  _healthTimer?.cancel();
  _healthTimer = null;
}

Future<void> _applyStepProgress(int diff) async {
  for (int i = 0; i < 3; i++) {
    Egg? egg = eggBox.getAt(i);

    if (egg != null) {
      egg.addSteps(diff);
      await egg.save();
    }
  }
}

Future<void> addDemoSteps(int amount) async {
  steps += amount;
  for (int i = 0; i < 3; i++) {
    Egg? egg = eggBox.getAt(i);
    if (egg != null) {
      egg.addSteps(amount);
      await egg.save();
    }
  }
}

void addDemoSleep(double hours) {
  sleep += hours;
}

Future<void> refresh({bool useRealData = true, DateTime? syncedAt}) async {
  final DateTime syncDate = syncedAt ?? DateTime.now();
  final int prevSteps = steps;

  if (useRealData) {
    final int syncedSteps = await getSteps();
    final double syncedSleep = await getSleep();
    final int stepDiff = _realStepDiff(syncedSteps, syncDate);

    steps = syncedSteps;
    sleep = syncedSleep;

    await _spawnSleepEggIfEligible(useRealData: true, syncedAt: syncDate);

    if (stepDiff > 0) {
      await _applyStepProgress(stepDiff);
    }

    await settingsBox.put(_lastSyncedStepDateKey, _dateKey(syncDate));
    await settingsBox.put(
      _lastSyncedStepCountKey,
      _stepCountToStore(syncedSteps, syncDate),
    );
    return;
  }

  await _spawnSleepEggIfEligible(useRealData: false, syncedAt: syncDate);

  if (steps > prevSteps) {
    await _applyStepProgress(steps - prevSteps);
  }
}

int _realStepDiff(int syncedSteps, DateTime syncedAt) {
  final String today = _dateKey(syncedAt);
  final Object? lastDate = settingsBox.get(_lastSyncedStepDateKey);

  if (lastDate != today) {
    return syncedSteps;
  }

  final int lastSteps =
      (settingsBox.get(_lastSyncedStepCountKey, defaultValue: 0) as num)
          .toInt();

  return max(0, syncedSteps - lastSteps);
}

int _stepCountToStore(int syncedSteps, DateTime syncedAt) {
  final String today = _dateKey(syncedAt);
  final Object? lastDate = settingsBox.get(_lastSyncedStepDateKey);

  if (lastDate != today) {
    return syncedSteps;
  }

  final int lastSteps =
      (settingsBox.get(_lastSyncedStepCountKey, defaultValue: 0) as num)
          .toInt();

  return max(lastSteps, syncedSteps);
}

Future<void> _spawnSleepEggIfEligible({
  required bool useRealData,
  required DateTime syncedAt,
}) async {
  if (sleep < sleepGoal) return;

  final String today = _dateKey(syncedAt);
  if (useRealData && settingsBox.get(_lastSleepRewardDateKey) == today) {
    return;
  }

  final bool spawned = await _spawnEgg();
  if (spawned && useRealData) {
    await settingsBox.put(_lastSleepRewardDateKey, today);
  }
}

Future<bool> _spawnEgg() async {
  for (int i = 0; i < 3; i++) {
    if (eggBox.getAt(i) == null) {
      var rarity = Random().nextInt(4);
      await eggBox.putAt(i, Egg(rarity, stepsGoal));
      return true;
    }
  }

  return false;
}

String _dateKey(DateTime date) {
  final String month = date.month.toString().padLeft(2, '0');
  final String day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

Future<Animal?> hatchEgg(Egg egg) async {
  if (!egg.isComplete) return null;

  final int eggIndex = _eggIndex(egg);
  if (eggIndex == -1) return null;

  final Animal animal = egg.hatch();
  await animalBox.add(animal);
  await eggBox.putAt(eggIndex, null);
  return animal;
}

bool isAnimalInAquarium(Animal animal) {
  return !animal.storedInPc;
}

Future<void> storeAnimalInPc(Animal animal) async {
  animal.storedInPc = true;
  await animal.save();
}

Future<void> withdrawAnimalFromPc(Animal animal) async {
  animal.storedInPc = false;
  await animal.save();
}

Future<bool> releaseAnimal(Animal animal) async {
  final dynamic animalKey = animal.key;
  if (animalKey == null) return false;

  await animalBox.delete(animalKey);
  return true;
}

Future<bool> deleteEgg(Egg egg) async {
  final int eggIndex = _eggIndex(egg);
  if (eggIndex == -1) return false;

  await eggBox.putAt(eggIndex, null);
  return true;
}

int _eggIndex(Egg egg) {
  for (int i = 0; i < eggBox.length; i++) {
    final Egg? currentEgg = eggBox.getAt(i);
    if (currentEgg == null) continue;
    if (identical(currentEgg, egg) || currentEgg.key == egg.key) {
      return i;
    }
  }

  return -1;
}
