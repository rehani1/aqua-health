import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'info_card.dart';

class EggCard extends StatelessWidget {
  const EggCard({
    super.key,
    required this.title,
    required this.sourceLabel,
    required this.dateLabel,
    required this.progress,
    required this.icon,
    required this.iconColor,
    this.onTap,
  });

  final String title;
  final String sourceLabel;
  final String dateLabel;
  final double progress;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final double clampedProgress = progress.clamp(0, 1).toDouble();
    final int percent = (clampedProgress * 100).round();

    return InfoCard(
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: <Color>[
                        iconColor.withValues(alpha: 0.25),
                        iconColor.withValues(alpha: 0.55),
                      ],
                    ),
                  ),
                  child: Icon(icon, size: 48, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(fontSize: 28),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$sourceLabel   $dateLabel',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: LinearProgressIndicator(
                                minHeight: 18,
                                value: clampedProgress,
                                backgroundColor: const Color(0xFFE3E8FC),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.primaryBlue,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '$percent%',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Hatch progress: $percent%',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
