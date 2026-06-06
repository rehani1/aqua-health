import 'dart:math';

import 'package:hive/hive.dart';
import 'animal.dart';

part 'egg.g.dart';

@HiveType(typeId: 1) // Ensure this ID is different from Animal (which was 0)
class Egg extends HiveObject {
  @HiveField(0)
  final int rarity;

  @HiveField(1)
  final int stepsNeeded;

  @HiveField(2)
  int totalSteps = 0;

  Egg(this.rarity, this.stepsNeeded);

  bool addSteps(int steps) {
    totalSteps += steps;
    return totalSteps >= stepsNeeded;
  }

  bool get isComplete => totalSteps >= stepsNeeded;

  double get progress {
    if (stepsNeeded == 0) return 0;
    return totalSteps / stepsNeeded;
  }

  String get rarityLabel {
    switch (rarity) {
      case 0:
        return 'Common Egg';
      case 1:
        return 'Rare Egg';
      case 2:
        return 'Epic Egg';
      default:
        return 'Mystery Egg';
    }
  }

  Animal hatch() {
    var fishDecider = Random().nextInt(100);
    if (fishDecider < 10) {
      return Animal(
        name: 'Crab',
        type: 'Crab',
        sprite: 'sprite_2',
        isRare: false,
      );
    } else if (fishDecider < 20) {
      return Animal(
        name: 'Fish',
        type: 'Fish',
        sprite: 'sprite_4',
        isRare: false,
      );
    } else if (fishDecider < 30) {
      return Animal(
        name: 'Starfish',
        type: 'Starfish',
        sprite: 'sprite_45',
        isRare: false,
      );
    } else if (fishDecider < 40) {
      return Animal(
        name: 'Seahorse',
        type: 'Seahorse',
        sprite: 'sprite_6',
        isRare: false,
      );
    } else if (fishDecider < 50) {
      return Animal(
        name: 'Gator',
        type: 'Gator',
        sprite: 'sprite_29',
        isRare: false,
      );
    } else if (fishDecider < 60) {
      return Animal(
        name: 'Seagull',
        type: 'Seagull',
        sprite: 'sprite_53',
        isRare: false,
      );
    } else if (fishDecider < 70) {
      return Animal(
        name: 'Fish',
        type: 'Fish',
        sprite: 'sprite_4',
        isRare: false,
      );
    } else if (fishDecider < 80) {
      return Animal(
        name: 'Clownfish',
        type: 'Clownfish',
        sprite: 'sprite_17',
        isRare: false,
      );
    } else if (fishDecider < 85) {
      return Animal(
        name: 'Shark',
        type: 'Shark',
        sprite: 'sprite_25',
        isRare: true,
      );
    } else if (fishDecider < 90) {
      return Animal(
        name: 'Turtle',
        type: 'Turtle',
        sprite: 'sprite_9',
        isRare: true,
      );
    } else if (fishDecider < 95) {
      return Animal(
        name: 'Octopus',
        type: 'Octopus',
        sprite: 'sprite_47',
        isRare: true,
      );
    } else {
      return Animal(
        name: 'Whale',
        type: 'Whale',
        sprite: 'sprite_49',
        isRare: true,
      );
    }
  }
}
