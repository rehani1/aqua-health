import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/info_card.dart';
import '../widgets/primary_button.dart';

class DailySummaryScreen extends StatelessWidget {
  const DailySummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.pageGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'Daily Summary',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 26),
                const InfoCard(child: _SummaryCardContent()),
                const SizedBox(height: 38),
                PrimaryButton(
                  label: 'Done',
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

class _SummaryCardContent extends StatelessWidget {
  const _SummaryCardContent();

  @override
  Widget build(BuildContext context) {
    final TextStyle lineStyle = Theme.of(context).textTheme.headlineSmall!
        .copyWith(fontSize: 26, fontWeight: FontWeight.w700);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Today', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 14),
        Text('Steps: 8,450', style: lineStyle),
        const Divider(height: 28),
        Text('Sleep: 7.8 hrs', style: lineStyle),
        const Divider(height: 28),
        Text('Eggs earned: 1', style: lineStyle),
        const Divider(height: 28),
        Text(
          'Hatch progress gained: +35%',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 18),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.chipMuted,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            'You hit your step goal today.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}
