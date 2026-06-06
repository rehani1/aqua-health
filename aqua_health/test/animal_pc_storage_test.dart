import 'dart:io';

import 'package:aqua_health/controller/backend.dart';
import 'package:aqua_health/model/animal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('aqua_health_pc_test_');
    Hive.init(tempDir.path);

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(AnimalAdapter());
    }

    animalBox = await Hive.openBox<Animal>('aquarium');
  });

  tearDown(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  test('animals default to aquarium and can be stored in PC locally', () async {
    final animal = Animal(
      name: 'Bubbles',
      type: 'Fish',
      sprite: 'sprite_4',
      isRare: false,
    );

    await animalBox.add(animal);

    expect(animalBox.getAt(0)!.storedInPc, isFalse);
    expect(isAnimalInAquarium(animalBox.getAt(0)!), isTrue);

    await storeAnimalInPc(animalBox.getAt(0)!);

    expect(animalBox.getAt(0)!.storedInPc, isTrue);
    expect(isAnimalInAquarium(animalBox.getAt(0)!), isFalse);

    await withdrawAnimalFromPc(animalBox.getAt(0)!);

    expect(animalBox.getAt(0)!.storedInPc, isFalse);
    expect(isAnimalInAquarium(animalBox.getAt(0)!), isTrue);
  });
}
