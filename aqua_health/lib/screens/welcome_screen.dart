import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';
import 'permissions_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const String routeName = '/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.pageGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: <Color>[Color(0xFF5BA0F4), Color(0xFF2A66C6)],
                        ),
                      ),
                      child: const Icon(
                        Icons.egg_alt_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'App Logo',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Divider(color: Colors.white.withValues(alpha: 0.45)),
                const SizedBox(height: 12),
                Text(
                  'Build healthier habits with less screen time',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 42),
                const _IllustrationStrip(),
                const SizedBox(height: 42),
                Text(
                  'Walk. Sleep. Collect aquatic friends!',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(fontSize: 44),
                ),
                const SizedBox(height: 12),
                Text(
                  'Get healthier while having fun.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 34),
                PrimaryButton(
                  label: 'Get Started',
                  onPressed: () {
                    Navigator.of(
                      context,
                    ).pushNamed(PermissionsScreen.routeName);
                  },
                ),
                const SizedBox(height: 14),
                SecondaryButton(
                  label: 'Learn More',
                  onPressed: () {
                    showDialog<void>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('How it works'),
                        content: const Text(
                          'Meet your sleep goal to earn eggs, then walk to '
                          'hatch sea creatures and grow your aquarium.',
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 26),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IllustrationStrip extends StatelessWidget {
  const _IllustrationStrip();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const <Widget>[
        Expanded(
          child: _IllustrationPanel(
            icon: Icons.directions_walk_rounded,
            label: 'Walk',
            top: Color(0xFFCBE8FF),
            bottom: Color(0xFF9FD27A),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _IllustrationPanel(
            icon: Icons.nightlight_round,
            label: 'Sleep',
            top: Color(0xFF7CA4ED),
            bottom: Color(0xFF335EBD),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _IllustrationPanel(
            icon: Icons.set_meal_rounded,
            label: 'Collect',
            top: Color(0xFF9DDAFF),
            bottom: Color(0xFF4AA9E5),
          ),
        ),
      ],
    );
  }
}

class _IllustrationPanel extends StatelessWidget {
  const _IllustrationPanel({
    required this.icon,
    required this.label,
    required this.top,
    required this.bottom,
  });

  final IconData icon;
  final String label;
  final Color top;
  final Color bottom;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.85,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[top, bottom],
          ),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x1E1E467C),
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, color: Colors.white, size: 42),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
