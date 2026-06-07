import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/info_card.dart';
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';
import 'goal_setup_screen.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  static const String routeName = '/permissions';

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  bool _stepConnected = false;
  bool _sleepConnected = false;

  void _continueFlow() {
    Navigator.of(context).pushNamed(GoalSetupScreen.routeName);
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
                const SizedBox(height: 10),
                CircleAvatar(
                  radius: 56,
                  backgroundColor: const Color(0x1F2D7EEA),
                  child: Icon(
                    Icons.shield_rounded,
                    size: 64,
                    color: AppColors.primaryBlue.withValues(alpha: 0.86),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Connect Health Data',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 14),
                Text(
                  'To earn rewards, we use your steps and sleep data.\n'
                  'Your data stays private and secure on your device.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 24),
                _PermissionCard(
                  title: 'Step Count',
                  isConnected: _stepConnected,
                  icon: Icons.directions_walk_rounded,
                  actionLabel: _stepConnected
                      ? 'Connected'
                      : 'Allow Step Access',
                  onPressed: _stepConnected
                      ? null
                      : () {
                          setState(() => _stepConnected = true);
                        },
                ),
                const SizedBox(height: 14),
                _PermissionCard(
                  title: 'Sleep Data',
                  isConnected: _sleepConnected,
                  icon: Icons.bedtime_rounded,
                  actionLabel: _sleepConnected
                      ? 'Connected'
                      : 'Allow Sleep Access',
                  onPressed: _sleepConnected
                      ? null
                      : () {
                          setState(() => _sleepConnected = true);
                        },
                ),
                const SizedBox(height: 24),
                Divider(color: AppColors.divider.withValues(alpha: 0.7)),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.verified_user_rounded,
                      color: AppColors.primaryBlue.withValues(alpha: 0.75),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Your data is never shared and remains on your device.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                PrimaryButton(label: 'Continue', onPressed: _continueFlow),
                const SizedBox(height: 14),
                SecondaryButton(label: 'Not Now', onPressed: _continueFlow),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  const _PermissionCard({
    required this.title,
    required this.icon,
    required this.isConnected,
    required this.actionLabel,
    required this.onPressed,
  });

  final String title;
  final IconData icon;
  final bool isConnected;
  final String actionLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final Color statusColor = isConnected
        ? AppColors.success
        : AppColors.textSecondary;

    return InfoCard(
      child: Row(
        children: <Widget>[
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.14),
            child: Icon(icon, size: 30, color: AppColors.primaryBlueDark),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        isConnected ? 'Connected' : 'Not Connected',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(color: statusColor),
                      ),
                    ),
                    if (!isConnected) ...<Widget>[
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.error_rounded,
                        size: 18,
                        color: Color(0xFFDD8D87),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 136),
            child: FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                disabledBackgroundColor: AppColors.success,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              child: Text(
                actionLabel,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
