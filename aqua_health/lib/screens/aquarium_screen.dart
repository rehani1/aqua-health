import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../model/animal.dart';
import '../widgets/secondary_button.dart';

class AquariumScreen extends StatelessWidget {
  const AquariumScreen({
    super.key,
    required this.animals,
    required this.onViewCollection,
    required this.onRenameAnimals,
  });

  final List<Animal> animals;
  final VoidCallback onViewCollection;
  final VoidCallback onRenameAnimals;

  @override
  Widget build(BuildContext context) {
    final int rareCount = animals
        .where((Animal animal) => animal.isRare)
        .length;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'My Aquarium',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          Container(
            height: 430,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Color(0xFFB9E1FF),
                  Color(0xFF89C9F5),
                  Color(0xFFC8E7FF),
                ],
              ),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x1F204B87),
                  blurRadius: 22,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: <Widget>[
                Align(
                  alignment: const Alignment(0, -0.98),
                  child: Container(
                    height: 20,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.34),
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                ),
                for (final Animal animal in animals)
                  Align(
                    alignment: _alignmentForAnimal(animal),
                    child: _AnimalBadge(animal: animal),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Collection: ${animals.length} animals  Rare: $rareCount',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Expanded(
                child: SecondaryButton(
                  label: 'View Collection Grid',
                  onPressed: onViewCollection,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SecondaryButton(
                  label: 'Rename Animals',
                  onPressed: onRenameAnimals,
                ),
              ),
            ],
          ),
        ],
      ),
    );
    
  }
    Alignment _alignmentForAnimal(Animal animal) {
    final int hash = animal.name.hashCode;
    final double x = ((hash % 200) - 100) / 100;
    final double y = (((hash ~/ 200) % 200) - 100) / 100;
    return Alignment(x, y);
  }
}

class _AnimalBadge extends StatelessWidget {
  const _AnimalBadge({required this.animal});

  final Animal animal;

  @override
  Widget build(BuildContext context) {
    final bool rare = animal.type.toLowerCase().contains('rare');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: rare
                ? const Color(0xFFFBEBC5).withValues(alpha: 0.95)
                : Colors.white.withValues(alpha: 0.78),
            border: Border.all(color: Colors.white, width: 1.2),
          ),
          child: Image.asset(
            animal.sprite, // assuming this is an asset path
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          animal.name,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: AppColors.textPrimary),
        ),
      ],
    );
  }
}