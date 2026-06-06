import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../model/egg.dart';
import '../model/animal.dart';
import '../screens/aquarium_screen.dart';
import '../screens/daily_summary_screen.dart';
import '../screens/eggs_screen.dart';
import '../screens/hatch_reveal_screen.dart';
import '../screens/home_dashboard_screen.dart';
import '../theme/app_theme.dart';
import '../controller/backend.dart';

class BottomNavShell extends StatefulWidget {
  const BottomNavShell({super.key, this.initialTab = 0});

  static const String routeName = '/app';
  final int initialTab;

  @override
  State<BottomNavShell> createState() => _BottomNavShellState();
}

class _BottomNavShellState extends State<BottomNavShell> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTab.clamp(0, 3);
  }

  void _selectTab(int index) {
    setState(() => _selectedIndex = index);
  }

  Future<void> _openHatchRevealFromEgg(Egg egg) async {
    final String rarityLabel = egg.rarityLabel;
    final Animal? animal = await hatchEgg(egg);
    if (animal == null || !mounted) return;

    final String? animalName = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        fullscreenDialog: true,
        builder: (_) => HatchRevealScreen(
          animalName: animal.name,
          rarity: animal.isRare ? 'Rare find' : rarityLabel,
          animalSprite: animal.sprite,
        ),
      ),
    );

    final String? trimmedName = animalName?.trim();
    if (trimmedName != null && trimmedName.isNotEmpty) {
      animal.name = trimmedName;
      await animal.save();
    }

    if (animalName != null && mounted) {
      setState(() => _selectedIndex = 2);
    }
  }

  Future<void> _openDailySummary() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => const DailySummaryScreen(),
      ),
    );
  }

  void _showStubMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = <Widget>[
      HomeDashboardScreen(
        onViewEggs: () => _selectTab(1),
        onOpenAquarium: () => _selectTab(2),
        onDailySummary: _openDailySummary,
      ),
      ValueListenableBuilder<Box<Egg?>>(
        valueListenable: Hive.box<Egg?>('eggHolders').listenable(),
        builder: (context, box, _) {
          final eggs = List.generate(3, (i) => box.getAt(i));

          return EggsScreen(
            eggs: eggs.whereType<Egg>().toList(),
            onCompletedEggSelected: (egg) {
              _openHatchRevealFromEgg(egg);
            },
            onRefresh: refresh,
          );
        },
      ),

      ValueListenableBuilder<Box<Animal>>(
        valueListenable: Hive.box<Animal>('aquarium').listenable(),
        builder: (context, box, _) {
          final animals = box.values.toList();

          return AquariumScreen(
            animals: animals,
            onViewCollection: () =>
                _showStubMessage('Collection grid coming soon.'),
            onRenameAnimals: () => _showStubMessage('Rename flow coming soon.'),
          );
        },
      ),
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.pageGradient),
        child: SafeArea(
          bottom: false,
          child: IndexedStack(index: _selectedIndex, children: pages),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _selectTab,
        destinations: const <NavigationDestination>[
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.egg_alt_rounded),
            label: 'Eggs',
          ),
          NavigationDestination(
            icon: Icon(Icons.waves_rounded),
            label: 'Aquarium',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
