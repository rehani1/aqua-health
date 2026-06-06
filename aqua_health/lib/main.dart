import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'controller/backend.dart';
import 'model/egg.dart';
import 'model/animal.dart';
import 'model/animal_motion.dart';
import 'screens/hatch_reveal_screen.dart';

const bool _forceDemoHealthData = bool.fromEnvironment(
  'aquaHealth.useDemoHealthData',
);

bool get useDemoHealthData =>
    kIsWeb ||
    defaultTargetPlatform != TargetPlatform.android ||
    (kDebugMode && _forceDemoHealthData);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHive();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0277BD),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFF06365F),
        fontFamily: 'Roboto',
      ),
      home: const EggHatcherScreen(),
    );
  }
}

class EggHatcherScreen extends StatefulWidget {
  const EggHatcherScreen({super.key});

  @override
  State<EggHatcherScreen> createState() => _EggHatcherScreenState();
}

class _EggHatcherScreenState extends State<EggHatcherScreen> {
  final Set<Object> _revealingEggKeys = <Object>{};
  bool _isRevealingCompletedEggs = false;
  bool _isHatchDockCollapsed = true;
  bool _canUseRealHealth = false;

  Future<bool> _requestHealthPermissionsIfNeeded() async {
    if (useDemoHealthData) return false;
    return requestHealthPermissions();
  }

  Future<bool> _ensureHealthSyncReady() async {
    if (useDemoHealthData) return false;
    if (_canUseRealHealth) return true;

    _canUseRealHealth = await _requestHealthPermissionsIfNeeded();
    if (_canUseRealHealth) {
      startHealthPolling();
    }

    return _canUseRealHealth;
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _ensureHealthSyncReady();
      await refresh(useRealData: _canUseRealHealth);

      if (mounted) {
        setState(() {});
        await _revealCompletedEggs();
      }
    });
  }

  @override
  void dispose() {
    disposeHealthPolling();
    super.dispose();
  }

  Future<void> _refresh() async {
    await _ensureHealthSyncReady();
    await refresh(useRealData: _canUseRealHealth);
    if (!mounted) return;
    setState(() {});
    await _revealCompletedEggs();
  }

  Object _eggRevealKey(Egg egg) {
    return egg.key ?? identityHashCode(egg);
  }

  void _queueHatchReveal(Egg egg) {
    final Object revealKey = _eggRevealKey(egg);
    if (!_revealingEggKeys.add(revealKey)) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        _revealingEggKeys.remove(revealKey);
        return;
      }

      _openHatchRevealFromEgg(egg, alreadyQueued: true);
    });
  }

  Future<void> _revealCompletedEggs() async {
    if (_isRevealingCompletedEggs) return;

    _isRevealingCompletedEggs = true;
    try {
      while (mounted) {
        Egg? completedEgg;
        for (int i = 0; i < eggBox.length; i++) {
          final Egg? egg = eggBox.getAt(i);
          if (egg != null &&
              egg.isComplete &&
              !_revealingEggKeys.contains(_eggRevealKey(egg))) {
            completedEgg = egg;
            break;
          }
        }

        if (completedEgg == null) break;
        await _openHatchRevealFromEgg(completedEgg);
      }
    } finally {
      _isRevealingCompletedEggs = false;
    }
  }

  Future<void> _openHatchRevealFromEgg(
    Egg egg, {
    bool alreadyQueued = false,
  }) async {
    final Object revealKey = _eggRevealKey(egg);
    if (!alreadyQueued && !_revealingEggKeys.add(revealKey)) return;

    final String rarityLabel = egg.rarityLabel;

    try {
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

      if (mounted) setState(() {});
    } finally {
      _revealingEggKeys.remove(revealKey);
    }
  }

  Future<void> _showGoalPopup({
    required String title,
    required int currentGoal,
    required String currentValueText,
    required String unit,
    required Future<void> Function(int) onSave,
  }) async {
    final controller = TextEditingController(text: currentGoal.toString());

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                currentValueText,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Goal",
                  suffixText: unit,
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final value = int.tryParse(controller.text);

                if (value != null && value > 0) {
                  await onSave(value);
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  String _hoursLabel(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(1);
  }

  Widget _buildHatchDock({
    required double height,
    required double bottomPadding,
  }) {
    final double collapsedHeight = 64 + bottomPadding;
    final double activeHeight = _isHatchDockCollapsed
        ? collapsedHeight
        : height;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      height: activeHeight,
      padding: EdgeInsets.fromLTRB(16, 12, 16, 10 + bottomPadding),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FCFF).withValues(alpha: 0.72),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.42),
            width: 2,
          ),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF012A4A).withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: ValueListenableBuilder<Box<Egg?>>(
        valueListenable: eggBox.listenable(),
        builder: (context, Box<Egg?> box, _) {
          for (final Egg egg in box.values.whereType<Egg>()) {
            if (egg.isComplete &&
                !_revealingEggKeys.contains(_eggRevealKey(egg))) {
              _queueHatchReveal(egg);
              break;
            }
          }

          final List<Egg?> eggs = List<Egg?>.generate(
            3,
            (index) => index < box.length ? box.getAt(index) : null,
          );
          final int readyCount = eggs
              .where((Egg? egg) => egg != null && egg.isComplete)
              .length;

          final Widget dockHeader = Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _isHatchDockCollapsed = !_isHatchDockCollapsed;
                });
              },
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Color(0x99E3F3FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.egg_alt_rounded,
                        color: Color(0xFF0277BD),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Egg Hatcher',
                        style: TextStyle(
                          color: Color(0xFF103B5D),
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    _ReadyBadge(count: readyCount),
                    const SizedBox(width: 6),
                    Icon(
                      _isHatchDockCollapsed
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: const Color(0xFF1C5D83),
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              dockHeader,
              Expanded(
                child: ClipRect(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: _isHatchDockCollapsed
                        ? const SizedBox.shrink(
                            key: ValueKey<String>('dock-collapsed'),
                          )
                        : SingleChildScrollView(
                            key: const ValueKey<String>('dock-expanded'),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                const SizedBox(height: 9),
                                Row(
                                  children: List<Widget>.generate(3, (
                                    int index,
                                  ) {
                                    final Egg? egg = eggs[index];

                                    return Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          right: index == 2 ? 0 : 8,
                                        ),
                                        child: EggWidget(
                                          egg: egg,
                                          slotNumber: index + 1,
                                          onTap: () async {
                                            if (egg != null && egg.isComplete) {
                                              await _openHatchRevealFromEgg(
                                                egg,
                                              );
                                            } else {
                                              await _refresh();
                                            }
                                          },
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                                if (useDemoHealthData) ...<Widget>[
                                  const SizedBox(height: 9),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    alignment: WrapAlignment.center,
                                    children: <Widget>[
                                      _QuickActionButton(
                                        icon: Icons.directions_walk_rounded,
                                        label: '+200',
                                        onPressed: () async {
                                          await addDemoSteps(200);
                                          if (!mounted) return;
                                          setState(() {});
                                          await _revealCompletedEggs();
                                        },
                                      ),
                                      _QuickActionButton(
                                        icon: Icons.directions_run_rounded,
                                        label: '+500',
                                        onPressed: () async {
                                          await addDemoSteps(500);
                                          if (!mounted) return;
                                          setState(() {});
                                          await _revealCompletedEggs();
                                        },
                                      ),
                                      _QuickActionButton(
                                        icon: Icons.bedtime_rounded,
                                        label: '+2h',
                                        onPressed: () async {
                                          addDemoSleep(2);
                                          await refresh(useRealData: false);
                                          if (!mounted) return;
                                          setState(() {});
                                        },
                                      ),
                                      _QuickActionButton(
                                        icon: Icons.calendar_today_rounded,
                                        label: 'Day',
                                        onPressed: () async {
                                          steps = 0;
                                          sleep = 0;
                                          await refresh(useRealData: false);
                                          if (!mounted) return;
                                          setState(() {});
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final EdgeInsets safePadding = MediaQuery.paddingOf(context);
          final double expandedDockBaseHeight = constraints.maxHeight < 700
              ? 246
              : 268;
          final double collapsedDockBaseHeight = 64;
          final double dockBaseHeight = _isHatchDockCollapsed
              ? collapsedDockBaseHeight
              : expandedDockBaseHeight;
          final double dockHeight = dockBaseHeight + safePadding.bottom;
          final double arenaTop = safePadding.top + 106;
          final double arenaBottom = dockHeight - 16;

          return Stack(
            children: <Widget>[
              const Positioned.fill(child: _AquariumBackdrop()),
              Positioned(
                top: safePadding.top + 14,
                left: 16,
                right: 16,
                child: ValueListenableBuilder<Box<Animal>>(
                  valueListenable: animalBox.listenable(),
                  builder: (context, Box<Animal> box, _) {
                    final int collectionCount = box.length;
                    final int rareCount = box.values
                        .where((Animal animal) => animal.isRare)
                        .length;
                    final int reefLevel = max(1, collectionCount ~/ 3 + 1);

                    return Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: ProgressBar(
                                icon: Icons.directions_walk_rounded,
                                label: 'Steps',
                                valueLabel: '$steps / $stepsGoal',
                                value: stepsGoal == 0 ? 0 : steps / stepsGoal,
                                onTap: () {
                                  _showGoalPopup(
                                    title: 'Set Step Goal',
                                    currentGoal: stepsGoal,
                                    currentValueText: 'Current steps: $steps',
                                    unit: 'steps',
                                    onSave: (value) async {
                                      setState(() {
                                        stepsGoal = value;
                                      });
                                      await settingsBox.put(
                                        'stepsGoal',
                                        stepsGoal,
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ProgressBar(
                                icon: Icons.bedtime_rounded,
                                label: 'Sleep',
                                valueLabel:
                                    '${sleep.toStringAsFixed(1)} / ${_hoursLabel(sleepGoal)}h',
                                value: sleepGoal == 0 ? 0 : sleep / sleepGoal,
                                onTap: () {
                                  _showGoalPopup(
                                    title: 'Set Sleep Goal',
                                    currentGoal: sleepGoal.toInt(),
                                    currentValueText:
                                        'Current sleep: ${sleep.toStringAsFixed(1)} hours',
                                    unit: 'hours',
                                    onSave: (value) async {
                                      setState(() {
                                        sleepGoal = value.toDouble();
                                      });
                                      await settingsBox.put(
                                        'sleepGoal',
                                        sleepGoal,
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _ReefScoreBar(
                          level: reefLevel,
                          animals: collectionCount,
                          rare: rareCount,
                        ),
                      ],
                    );
                  },
                ),
              ),
              Positioned(
                top: arenaTop,
                left: 0,
                right: 0,
                bottom: arenaBottom,
                child: const AnimalArena(),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildHatchDock(
                  height: dockHeight,
                  bottomPadding: safePadding.bottom,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AquariumBackdrop extends StatelessWidget {
  const _AquariumBackdrop();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0xFF9BE7FF),
            Color(0xFF2A9FD6),
            Color(0xFF076191),
          ],
        ),
      ),
      child: CustomPaint(painter: _AquariumBackdropPainter()),
    );
  }
}

class _AquariumBackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint rayPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.13);
    final List<double> rayStarts = <double>[
      size.width * 0.04,
      size.width * 0.38,
      size.width * 0.72,
    ];

    for (final double start in rayStarts) {
      final Path ray = Path()
        ..moveTo(start, 0)
        ..lineTo(start + size.width * 0.18, 0)
        ..lineTo(start + size.width * 0.04, size.height * 0.72)
        ..lineTo(start - size.width * 0.13, size.height * 0.72)
        ..close();
      canvas.drawPath(ray, rayPaint);
    }

    final Paint bubblePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.white.withValues(alpha: 0.45);
    const List<Offset> bubbles = <Offset>[
      Offset(0.14, 0.22),
      Offset(0.21, 0.42),
      Offset(0.78, 0.18),
      Offset(0.84, 0.38),
      Offset(0.68, 0.57),
      Offset(0.31, 0.66),
    ];

    for (int i = 0; i < bubbles.length; i++) {
      final Offset bubble = bubbles[i];
      canvas.drawCircle(
        Offset(bubble.dx * size.width, bubble.dy * size.height),
        5 + (i % 3) * 3,
        bubblePaint,
      );
    }

    final Paint sandPaint = Paint()..color = const Color(0xFFF4D28B);
    final Path sand = Path()
      ..moveTo(0, size.height * 0.82)
      ..quadraticBezierTo(
        size.width * 0.24,
        size.height * 0.78,
        size.width * 0.50,
        size.height * 0.84,
      )
      ..quadraticBezierTo(
        size.width * 0.76,
        size.height * 0.90,
        size.width,
        size.height * 0.82,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(sand, sandPaint);

    final Paint pebblePaint = Paint()
      ..color = const Color(0xFFE8B85D).withValues(alpha: 0.65);
    for (int i = 0; i < 12; i++) {
      final double x = size.width * (0.05 + i * 0.083);
      final double y = size.height * (0.88 + (i % 4) * 0.018);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: 10, height: 5),
        pebblePaint,
      );
    }

    final Paint seaweedPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5
      ..color = const Color(0xFF1B9A78);
    final Paint coralPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5
      ..color = const Color(0xFFFF7B7B);

    _drawPlant(canvas, size, size.width * 0.10, seaweedPaint, 54);
    _drawPlant(canvas, size, size.width * 0.17, seaweedPaint, 38);
    _drawPlant(canvas, size, size.width * 0.88, seaweedPaint, 48);
    _drawPlant(canvas, size, size.width * 0.78, coralPaint, 36);
  }

  void _drawPlant(
    Canvas canvas,
    Size size,
    double x,
    Paint paint,
    double height,
  ) {
    final double base = size.height * 0.91;
    final Path stem = Path()
      ..moveTo(x, base)
      ..quadraticBezierTo(x - 12, base - height * 0.45, x + 4, base - height);
    canvas.drawPath(stem, paint);

    canvas.drawLine(
      Offset(x, base - height * 0.34),
      Offset(x - 16, base - height * 0.58),
      paint,
    );
    canvas.drawLine(
      Offset(x + 2, base - height * 0.52),
      Offset(x + 17, base - height * 0.77),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ReefScoreBar extends StatelessWidget {
  const _ReefScoreBar({
    required this.level,
    required this.animals,
    required this.rare,
  });

  final int level;
  final int animals;
  final int rare;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: Colors.white.withValues(alpha: 0.32)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _ScoreItem(
              icon: Icons.military_tech_rounded,
              label: 'Lvl $level',
            ),
          ),
          Expanded(
            child: _ScoreItem(
              icon: Icons.water_rounded,
              label: '$animals pets',
            ),
          ),
          Expanded(
            child: _ScoreItem(
              icon: Icons.auto_awesome_rounded,
              label: '$rare rare',
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreItem extends StatelessWidget {
  const _ScoreItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 15, color: const Color(0xFF026DA8)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF13425F),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class ProgressBar extends StatelessWidget {
  const ProgressBar({
    super.key,
    required this.icon,
    required this.label,
    required this.valueLabel,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String valueLabel;
  final double value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.46),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 62,
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(icon, size: 17, color: const Color(0xFF026DA8)),
                  const SizedBox(width: 5),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFF164866),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        valueLabel,
                        style: const TextStyle(
                          color: Color(0xFF406A84),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  minHeight: 6,
                  value: value.clamp(0, 1),
                  backgroundColor: const Color(0x88D8F0FF),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF06A3C9),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReadyBadge extends StatelessWidget {
  const _ReadyBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: count > 0 ? const Color(0x99FFE8A3) : const Color(0x99E6F2FA),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        'Ready $count',
        style: const TextStyle(
          color: Color(0xFF17425D),
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: FilledButton.tonalIcon(
        onPressed: onPressed,
        icon: Icon(icon, size: 15),
        label: Text(label),
        style: FilledButton.styleFrom(
          foregroundColor: const Color(0xFF06496A),
          backgroundColor: const Color(0x78E3F3FF),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class EggWidget extends StatelessWidget {
  const EggWidget({
    super.key,
    required this.egg,
    required this.onTap,
    required this.slotNumber,
  });

  final Egg? egg;
  final VoidCallback onTap;
  final int slotNumber;

  @override
  Widget build(BuildContext context) {
    final Egg? currentEgg = egg;

    if (currentEgg == null) {
      return Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 92,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0x99EAF6FD),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0x88C7E5F7)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(
                  Icons.add_circle_outline_rounded,
                  color: Color(0xFF5C92AF),
                  size: 23,
                ),
                const SizedBox(height: 5),
                Text(
                  'Slot $slotNumber',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF47728B),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                const Text(
                  'Empty',
                  style: TextStyle(
                    color: Color(0xFF7B9CAF),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final double progress = currentEgg.progress.clamp(0, 1).toDouble();
    final int percent = (progress * 100).round();
    final bool ready = currentEgg.isComplete;
    final List<Color> rarityColors = _colorsFromRarity(currentEgg.rarity);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 92,
          padding: const EdgeInsets.fromLTRB(7, 7, 7, 7),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.62),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: ready ? const Color(0xAAFFC857) : const Color(0x88D4EAF6),
              width: 1,
            ),
            boxShadow: ready
                ? <BoxShadow>[
                    BoxShadow(
                      color: const Color(0xFFFFC857).withValues(alpha: 0.20),
                      blurRadius: 10,
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                width: 40,
                height: 46,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: rarityColors,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.72),
                    width: 1,
                  ),
                ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 6,
                    margin: const EdgeInsets.fromLTRB(7, 0, 7, 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                ready ? 'Ready' : '$percent%',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: ready
                      ? const Color(0xFF9B6200)
                      : const Color(0xFF315D75),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              SizedBox(
                height: 4,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    minHeight: 4,
                    value: progress,
                    backgroundColor: const Color(0x99E3F1F8),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      rarityColors.last,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Color> _colorsFromRarity(int rarity) {
    switch (rarity) {
      case 0:
        return const <Color>[Color(0xFFF4F8FB), Color(0xFFAFCCDA)];
      case 1:
        return const <Color>[Color(0xFFAEEBFF), Color(0xFF37A8D8)];
      case 2:
        return const <Color>[Color(0xFFE7C8FF), Color(0xFF8F69E8)];
      default:
        return const <Color>[Color(0xFFFFE3A3), Color(0xFFFF9F1C)];
    }
  }
}

class AnimalArena extends StatefulWidget {
  const AnimalArena({super.key});

  @override
  State<AnimalArena> createState() => _AnimalArenaState();
}

class _AnimalArenaState extends State<AnimalArena> {
  static const double _animalWidth = 92;
  static const double _animalHeight = 98;

  final Random random = Random();
  late final Box<Animal> animalBox;
  final Map<dynamic, AnimalMotion> motionMap = <dynamic, AnimalMotion>{};
  Timer? _movementTimer;
  Size _arenaSize = Size.zero;

  @override
  void initState() {
    super.initState();
    animalBox = Hive.box<Animal>('aquarium');
    _startLoop();
  }

  Offset _randomPos(Size size) {
    const double padding = 12;
    final double maxX = max(padding, size.width - _animalWidth - padding);
    final double maxY = max(padding, size.height - _animalHeight - padding);

    return Offset(
      padding + random.nextDouble() * (maxX - padding),
      padding + random.nextDouble() * (maxY - padding),
    );
  }

  Offset _randomVelocity() {
    final double angle = random.nextDouble() * 2 * pi;
    final double speed = 0.75 + random.nextDouble() * 0.95;

    return Offset(cos(angle) * speed, sin(angle) * speed);
  }

  void _startLoop() {
    _movementTimer = Timer.periodic(const Duration(milliseconds: 33), (_) {
      if (!mounted || _arenaSize == Size.zero) return;

      setState(() {
        for (final AnimalMotion motion in motionMap.values) {
          motion.position += motion.velocity;
          _handleBounds(motion, _arenaSize);
          _randomlyChangeDirection(motion);
        }
      });
    });
  }

  @override
  void dispose() {
    _movementTimer?.cancel();
    super.dispose();
  }

  void _syncMotion(List<dynamic> keys, Size size) {
    final Set<dynamic> liveKeys = keys.toSet();
    motionMap.removeWhere((dynamic key, _) => !liveKeys.contains(key));

    for (final dynamic key in keys) {
      motionMap.putIfAbsent(
        key,
        () => AnimalMotion(
          position: _randomPos(size),
          velocity: _randomVelocity(),
        ),
      );
    }
  }

  void _handleBounds(AnimalMotion motion, Size size) {
    const double margin = 8;
    final double maxX = max(margin, size.width - _animalWidth - margin);
    final double maxY = max(margin, size.height - _animalHeight - margin);

    if (motion.position.dx < margin) {
      motion.position = Offset(margin, motion.position.dy);
      motion.velocity = Offset(motion.velocity.dx.abs(), motion.velocity.dy);
    }

    if (motion.position.dx > maxX) {
      motion.position = Offset(maxX, motion.position.dy);
      motion.velocity = Offset(-motion.velocity.dx.abs(), motion.velocity.dy);
    }

    if (motion.position.dy < margin) {
      motion.position = Offset(motion.position.dx, margin);
      motion.velocity = Offset(motion.velocity.dx, motion.velocity.dy.abs());
    }

    if (motion.position.dy > maxY) {
      motion.position = Offset(motion.position.dx, maxY);
      motion.velocity = Offset(motion.velocity.dx, -motion.velocity.dy.abs());
    }
  }

  void _randomlyChangeDirection(AnimalMotion motion) {
    if (random.nextDouble() < 0.012) {
      motion.velocity = _randomVelocity();
    }
  }

  Future<void> _renameAnimal(Animal animal) async {
    final TextEditingController controller = TextEditingController(
      text: animal.name,
    );
    controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: controller.text.length,
    );

    final String? newName = await showDialog<String>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final bool canSave = controller.text.trim().isNotEmpty;

            return AlertDialog(
              title: Text('Rename ${animal.type}'),
              content: TextField(
                controller: controller,
                autofocus: true,
                maxLength: 18,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  counterText: '',
                  prefixIcon: Icon(Icons.edit_rounded),
                ),
                onChanged: (_) => setDialogState(() {}),
                onSubmitted: (_) {
                  if (controller.text.trim().isNotEmpty) {
                    Navigator.of(context).pop(controller.text.trim());
                  }
                },
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: canSave
                      ? () => Navigator.of(context).pop(controller.text.trim())
                      : null,
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();

    final String? trimmedName = newName?.trim();
    if (trimmedName == null ||
        trimmedName.isEmpty ||
        trimmedName == animal.name) {
      return;
    }

    animal.name = trimmedName;
    await animal.save();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final Size size = Size(
          max(1, constraints.maxWidth),
          max(1, constraints.maxHeight),
        );
        _arenaSize = size;

        return ValueListenableBuilder<Box<Animal>>(
          valueListenable: animalBox.listenable(),
          builder: (context, Box<Animal> box, _) {
            final List<dynamic> keys = box.keys.toList();
            _syncMotion(keys, size);

            if (keys.isEmpty) {
              return const Center(child: _EmptyReefMessage());
            }

            return Stack(
              clipBehavior: Clip.none,
              children: keys.map((dynamic key) {
                final Animal? animal = box.get(key);
                if (animal == null) return const SizedBox.shrink();

                final AnimalMotion motion = motionMap[key]!;

                return AnimatedPositioned(
                  duration: const Duration(milliseconds: 120),
                  curve: Curves.linear,
                  left: motion.position.dx,
                  top: motion.position.dy,
                  child: _AnimalWidget(
                    animal: animal,
                    facingLeft: motion.velocity.dx < 0,
                    onTap: () => _renameAnimal(animal),
                  ),
                );
              }).toList(),
            );
          },
        );
      },
    );
  }
}

class _EmptyReefMessage extends StatelessWidget {
  const _EmptyReefMessage();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.24),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.36)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.waves_rounded, color: Colors.white, size: 22),
          SizedBox(width: 8),
          Text(
            'No pets yet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimalWidget extends StatelessWidget {
  const _AnimalWidget({
    required this.animal,
    required this.facingLeft,
    required this.onTap,
  });

  final Animal animal;
  final bool facingLeft;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double spriteSize = animal.isRare ? 56 : 50;

    return Semantics(
      button: true,
      label: 'Rename ${animal.name}',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: _AnimalArenaState._animalWidth,
          height: _AnimalArenaState._animalHeight,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: spriteSize + 12,
                height: spriteSize + 6,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: animal.isRare
                      ? <BoxShadow>[
                          BoxShadow(
                            color: const Color(
                              0xFFFFD166,
                            ).withValues(alpha: 0.55),
                            blurRadius: 18,
                            spreadRadius: 1,
                          ),
                        ]
                      : <BoxShadow>[
                          BoxShadow(
                            color: const Color(
                              0xFF003049,
                            ).withValues(alpha: 0.12),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                ),
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.diagonal3Values(
                    facingLeft ? -1.0 : 1.0,
                    1.0,
                    1.0,
                  ),
                  child: Image.asset(
                    _spriteAssetPath(animal.sprite),
                    width: spriteSize,
                    height: spriteSize,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.set_meal_rounded,
                        color: Colors.white,
                        size: 42,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 1),
              Container(
                constraints: const BoxConstraints(maxWidth: 82),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF03344F).withValues(alpha: 0.52),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  animal.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _spriteAssetPath(String sprite) {
  if (sprite.startsWith('assets/')) return sprite;
  if (sprite.endsWith('.png')) return 'assets/OceanAssetPack/$sprite';
  return 'assets/OceanAssetPack/$sprite.png';
}
