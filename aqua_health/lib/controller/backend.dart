import 'dart:async';
import 'dart:math';

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
Timer? _stepsTimer;

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
  // run once on app start
  steps = await getSteps();
  sleep = await getSleep();

  // optional: immediately process eggs on startup
  await refresh(useRealData: false);
}

Future<int> getSteps() async {
  return HealthService().getTodaySteps();
}

Future<double> getSleep() {
  return HealthService().getSleepHoursLast24Hours();
}

void startStepsPolling() {
  _stepsTimer?.cancel();

  _stepsTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
    int prevSteps = steps;

    steps = await getSteps();

    int diff = steps - prevSteps;
    if (diff > 0) {
      await _applyStepProgress(diff);
    }
  });
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

void disposeHealthPolling() {
  _stepsTimer?.cancel();
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

Future<void> refresh({bool useRealData = true}) async {
  final int prevSteps = steps;

  if (useRealData) {
    steps = await getSteps();
    sleep = await getSleep();
  }

  // egg spawning based on sleep
  if (sleep >= sleepGoal) {
    for (int i = 0; i < 3; i++) {
      if (eggBox.getAt(i) == null) {
        var rarity = Random().nextInt(4);
        await eggBox.putAt(i, Egg(rarity, stepsGoal));
        break;
      }
    }
  }

  if (steps > prevSteps) {
    await _applyStepProgress(steps - prevSteps);
  }
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
