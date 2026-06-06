import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/bottom_nav_shell.dart';
import '../widgets/info_card.dart';
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';

class GoalSetupScreen extends StatefulWidget {
  const GoalSetupScreen({super.key});

  static const String routeName = '/goal-setup';

  @override
  State<GoalSetupScreen> createState() => _GoalSetupScreenState();
}

class _GoalSetupScreenState extends State<GoalSetupScreen> {
  int _stepGoal = 8000;
  double _sleepGoal = 8.0;

  void _updateStepGoal(int delta) {
    setState(() {
      _stepGoal = (_stepGoal + delta).clamp(4000, 16000);
    });
  }

  void _updateSleepGoal(double delta) {
    setState(() {
      _sleepGoal = (_sleepGoal + delta).clamp(5.0, 10.0);
    });
  }

  void _goToDashboard() {
    // TODO(health-data): Persist selected goals once real health sync is enabled.
    Navigator.of(context).pushNamedAndRemoveUntil(
      BottomNavShell.routeName,
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.pageGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 8),
                CircleAvatar(
                  radius: 54,
                  backgroundColor: const Color(0x1F2D7EEA),
                  child: Icon(
                    Icons.gps_fixed_rounded,
                    size: 60,
                    color: AppColors.primaryBlue.withValues(alpha: 0.82),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Set Your Goals',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Divider(color: AppColors.divider.withValues(alpha: 0.75)),
                const SizedBox(height: 12),
                Text(
                  'To earn rewards, we use your steps and sleep data.\n'
                  'Your data stays private and secure on your device.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 22),
                _GoalCard(
                  icon: Icons.directions_walk_rounded,
                  title: 'Daily Step Goal',
                  helperText: 'Reaching your step goal earns eggs!',
                  valueLabel: '${_stepGoal.toStringAsFixed(0)} steps',
                  onMinus: () => _updateStepGoal(-500),
                  onPlus: () => _updateStepGoal(500),
                ),
                const SizedBox(height: 14),
                _GoalCard(
                  icon: Icons.bedtime_rounded,
                  title: 'Sleep Goal',
                  helperText: 'Reaching your sleep goal adds hatch progress.',
                  valueLabel: '${_sleepGoal.toStringAsFixed(1)} hrs',
                  onMinus: () => _updateSleepGoal(-0.5),
                  onPlus: () => _updateSleepGoal(0.5),
                ),
                const SizedBox(height: 28),
                PrimaryButton(label: 'Save Goals', onPressed: _goToDashboard),
                const SizedBox(height: 14),
                SecondaryButton(label: 'Not Now', onPressed: _goToDashboard),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.icon,
    required this.title,
    required this.helperText,
    required this.valueLabel,
    required this.onMinus,
    required this.onPlus,
  });

  final IconData icon;
  final String title;
  final String helperText;
  final String valueLabel;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.15),
                child: Icon(icon, color: AppColors.primaryBlueDark, size: 34),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              _GoalStepper(
                valueLabel: valueLabel,
                onMinus: onMinus,
                onPlus: onPlus,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(width: 12),
              const Icon(
                Icons.egg_alt_rounded,
                color: Color(0xFFA4A8B9),
                size: 24,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  helperText,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GoalStepper extends StatelessWidget {
  const _GoalStepper({
    required this.valueLabel,
    required this.onMinus,
    required this.onPlus,
  });

  final String valueLabel;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF8AA8DC), width: 2),
        borderRadius: BorderRadius.circular(28),
        color: Colors.white.withValues(alpha: 0.7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            onPressed: onMinus,
            icon: const Icon(Icons.remove_rounded),
            color: AppColors.primaryBlue,
          ),
          Container(
            constraints: const BoxConstraints(minWidth: 130),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              valueLabel,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            onPressed: onPlus,
            icon: const Icon(Icons.add_rounded),
            color: AppColors.primaryBlue,
          ),
        ],
      ),
    );
  }
}
