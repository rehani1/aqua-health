import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/info_card.dart';
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';

class HatchRevealScreen extends StatefulWidget {
  const HatchRevealScreen({
    super.key,
    required this.animalName,
    required this.rarity,
    this.animalSprite,
  });

  final String animalName;
  final String rarity;
  final String? animalSprite;

  @override
  State<HatchRevealScreen> createState() => _HatchRevealScreenState();
}

class _HatchRevealScreenState extends State<HatchRevealScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final TextEditingController _nameController;

  String? get _animalAssetPath {
    final String? sprite = widget.animalSprite;
    if (sprite == null || sprite.isEmpty) return null;
    if (sprite.contains('/')) return sprite;
    return 'assets/OceanAssetPack/$sprite.png';
  }

  String get _trimmedName => _nameController.text.trim();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.animalName);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..forward();
  }

  void _placeInAquarium() {
    final String name = _trimmedName;
    if (name.isEmpty) return;
    Navigator.of(context).pop(name);
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    super.dispose();
  }

  double _interval(double begin, double end, Curve curve) {
    final double value = ((_controller.value - begin) / (end - begin))
        .clamp(0.0, 1.0)
        .toDouble();
    return curve.transform(value).clamp(0.0, 1.0).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Color(0xFFD8E8FF),
              Color(0xFFB8DBFF),
              Color(0xFFDDEBFF),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'Your Egg Is Hatching',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 18),
                Container(
                  height: 360,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        Color(0xFFBCE5FF),
                        Color(0xFF87C7F7),
                        Color(0xFFC7E4FF),
                      ],
                    ),
                  ),
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      final double reveal = _interval(
                        0.58,
                        0.9,
                        Curves.easeOutBack,
                      );
                      final double eggExit = _interval(
                        0.48,
                        0.64,
                        Curves.easeIn,
                      );
                      final double pulse = math.sin(
                        _controller.value * math.pi * 16,
                      );
                      final double shake =
                          math.sin(_controller.value * math.pi * 28) *
                          (1 - eggExit) *
                          8;
                      final double flash =
                          _interval(0.52, 0.6, Curves.easeOut) *
                          (1 - _interval(0.6, 0.72, Curves.easeIn));

                      return Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          for (int i = 0; i < 3; i++)
                            Transform.scale(
                              scale: 0.82 + (i * 0.28) + reveal * 0.25,
                              child: Opacity(
                                opacity: (0.22 - i * 0.045) * (1 - flash),
                                child: Container(
                                  width: 220,
                                  height: 220,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 3,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          Opacity(
                            opacity: 1 - eggExit,
                            child: Transform.translate(
                              offset: Offset(shake, 0),
                              child: Transform.scale(
                                scale: 1 + (pulse.abs() * 0.08),
                                child: const Icon(
                                  Icons.egg_alt_rounded,
                                  size: 154,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Opacity(
                            opacity: reveal,
                            child: Transform.scale(
                              scale: 0.42 + (reveal * 0.76),
                              child: _animalAssetPath == null
                                  ? const Icon(
                                      Icons.set_meal_rounded,
                                      size: 142,
                                      color: Color(0xFF215FB7),
                                    )
                                  : Image.asset(
                                      _animalAssetPath!,
                                      width: 190,
                                      height: 190,
                                      fit: BoxFit.contain,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return const Icon(
                                              Icons.set_meal_rounded,
                                              size: 142,
                                              color: Color(0xFF215FB7),
                                            );
                                          },
                                    ),
                            ),
                          ),
                          IgnorePointer(
                            child: Opacity(
                              opacity: flash,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(28),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'It hatched into:',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                InfoCard(
                  child: Column(
                    children: <Widget>[
                      Text(
                        widget.animalName,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Text(
                          widget.rarity,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: AppColors.primaryBlueDark,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _nameController,
                        textAlign: TextAlign.center,
                        textCapitalization: TextCapitalization.words,
                        maxLength: 18,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          hintText: 'Name your ${widget.animalName}',
                          counterText: '',
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.78),
                          prefixIcon: const Icon(Icons.edit_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (_) => setState(() {}),
                        onSubmitted: (_) => _placeInAquarium(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: 'Place in Aquarium',
                  icon: Icons.waves_rounded,
                  onPressed: _trimmedName.isEmpty ? null : _placeInAquarium,
                ),
                const SizedBox(height: 12),
                SecondaryButton(
                  label: 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
