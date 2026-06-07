import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../model/egg.dart';
import '../widgets/egg_card.dart';

class EggsScreen extends StatelessWidget {
  const EggsScreen({
    super.key,
    required this.eggs,
    required this.onCompletedEggSelected,
    required this.onRefresh,
  });

  final List<Egg> eggs;
  final ValueChanged<Egg> onCompletedEggSelected;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('My Eggs', style: Theme.of(context).textTheme.headlineMedium),
          ElevatedButton(
            onPressed: () async {
              await onRefresh();
            },
            child: const Text('Refresh'),
          ),
          const SizedBox(height: 8),
          Text(
            'Sleep earns eggs. Walking hatches them.',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),

          for (final egg in eggs)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                EggCard(
                  title: egg.rarityLabel,
                  sourceLabel: 'Steps',
                  dateLabel: 'Today',
                  progress: egg.progress,
                  icon: Icons.egg,
                  iconColor: egg.isComplete ? Colors.green : Colors.orange,
                  onTap: egg.isComplete
                      ? () => onCompletedEggSelected(egg)
                      : null,
                ),

                if (egg.isComplete)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                    child: Text(
                      'Ready to hatch - tap to reveal.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.primaryBlueDark,
                        fontWeight: FontWeight.w600,
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
