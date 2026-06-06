import 'package:flutter/material.dart';

class EggEntry {
  const EggEntry({
    required this.eggType,
    required this.source,
    required this.dateLabel,
    required this.progress,
    required this.icon,
    required this.iconColor,
    required this.revealAnimalName,
    required this.revealRarity,
  });

  final String eggType;
  final String source;
  final String dateLabel;
  final double progress;
  final IconData icon;
  final Color iconColor;
  final String revealAnimalName;
  final String revealRarity;

  bool get isComplete => progress >= 1.0;
}

class AquariumAnimal {
  const AquariumAnimal({
    required this.name,
    required this.icon,
    required this.alignment,
    this.isRare = false,
  });

  final String name;
  final IconData icon;
  final Alignment alignment;
  final bool isRare;
}

const List<EggEntry> mockEggs = <EggEntry>[
  EggEntry(
    eggType: 'Common Egg',
    source: 'Earned from steps',
    dateLabel: 'May 1',
    progress: 0.65,
    icon: Icons.egg_alt_rounded,
    iconColor: Color(0xFFA9BFEA),
    revealAnimalName: 'Clownfish',
    revealRarity: 'Common',
  ),
  EggEntry(
    eggType: 'Rare Egg',
    source: 'Earned from steps',
    dateLabel: 'May 1',
    progress: 0.2,
    icon: Icons.auto_awesome,
    iconColor: Color(0xFF7585E8),
    revealAnimalName: 'Seahorse',
    revealRarity: 'Rare',
  ),
  EggEntry(
    eggType: 'Moon Egg',
    source: 'Earned from sleep',
    dateLabel: 'May 2',
    progress: 1.0,
    icon: Icons.nightlight_round,
    iconColor: Color(0xFF8FA8F9),
    revealAnimalName: 'Blue Tang',
    revealRarity: 'Rare',
  ),
];

const List<AquariumAnimal> mockAquariumAnimals = <AquariumAnimal>[
  AquariumAnimal(
    name: 'Blue Tang',
    icon: Icons.phishing_rounded,
    alignment: Alignment(0.0, -0.55),
    isRare: true,
  ),
  AquariumAnimal(
    name: 'Clownfish',
    icon: Icons.set_meal_rounded,
    alignment: Alignment(-0.68, -0.1),
  ),
  AquariumAnimal(
    name: 'Sea Turtle',
    icon: Icons.cruelty_free_rounded,
    alignment: Alignment(0.72, -0.05),
  ),
  AquariumAnimal(
    name: 'Yellow Tang',
    icon: Icons.assistant_photo_rounded,
    alignment: Alignment(-0.24, 0.28),
  ),
  AquariumAnimal(
    name: 'Seahorse',
    icon: Icons.flutter_dash_rounded,
    alignment: Alignment(0.42, 0.36),
    isRare: true,
  ),
];
