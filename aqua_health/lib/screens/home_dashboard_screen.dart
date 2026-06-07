import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/info_card.dart';
import '../widgets/progress_card.dart';
import '../widgets/secondary_button.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({
    super.key,
    required this.onViewEggs,
    required this.onOpenAquarium,
    required this.onDailySummary,
  });

  final VoidCallback onViewEggs;
  final VoidCallback onOpenAquarium;
  final VoidCallback onDailySummary;

  @override
  Widget build(BuildContext context) {
    const int currentSteps = 5200;
    const int stepGoal = 8000;
    const double currentSleep = 6.5;
    const double sleepGoal = 8.0;

    final double stepsRatio = currentSteps / stepGoal;
    final double sleepRatio = currentSleep / sleepGoal;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Good Morning',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              TextButton.icon(
                onPressed: onDailySummary,
                icon: const Icon(Icons.summarize_rounded),
                label: const Text('Summary'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            "Today's Progress",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 14),
          ProgressCard(
            title: 'Steps',
            headline: '$currentSteps',
            goalLabel: '/$stepGoal steps',
            helperText: 'More steps will hatch your active eggs',
            trailing: _StepCircle(progress: stepsRatio),
            progressWidget: const SizedBox.shrink(),
          ),
          const SizedBox(height: 14),
          ProgressCard(
            title: 'Sleep',
            headline: currentSleep.toStringAsFixed(1),
            goalLabel: '/ ${sleepGoal.toStringAsFixed(1)} hrs',
            helperText: "Tonight's sleep can add a new egg",
            progressWidget: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: LinearProgressIndicator(
                minHeight: 24,
                value: sleepRatio.clamp(0, 1),
                backgroundColor: const Color(0xFFDCE5FB),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primaryBlue,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Rewards Snapshot',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          InfoCard(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: const <Widget>[
                Expanded(
                  child: _StatChip(
                    label: 'Eggs ready',
                    value: '2',
                    valueColor: AppColors.warning,
                  ),
                ),
                Expanded(
                  child: _StatChip(
                    label: 'Hatching',
                    value: '1',
                    valueColor: AppColors.primaryBlue,
                  ),
                ),
                Expanded(
                  child: _StatChip(
                    label: 'New',
                    value: '0',
                    valueColor: Color(0xFF92A7CF),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: <Widget>[
              Expanded(
                child: SecondaryButton(
                  label: 'View Eggs',
                  onPressed: onViewEggs,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SecondaryButton(
                  label: 'Open Aquarium',
                  onPressed: onOpenAquarium,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepCircle extends StatelessWidget {
  const _StepCircle({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 112,
      height: 112,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          CircularProgressIndicator(
            value: progress.clamp(0, 1),
            strokeWidth: 12,
            backgroundColor: const Color(0xFFDCE6FA),
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppColors.primaryBlue,
            ),
          ),
          Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFDCEBFF),
              border: Border.all(color: Colors.white.withValues(alpha: 0.75)),
            ),
            child: const Icon(
              Icons.water_drop_rounded,
              color: AppColors.primaryBlue,
              size: 38,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      child: Text.rich(
        TextSpan(
          text: '$label: ',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary),
          children: <InlineSpan>[
            TextSpan(
              text: value,
              style: TextStyle(color: valueColor, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
