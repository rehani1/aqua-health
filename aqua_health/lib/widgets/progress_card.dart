import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'info_card.dart';

class ProgressCard extends StatelessWidget {
  const ProgressCard({
    super.key,
    required this.title,
    required this.headline,
    required this.goalLabel,
    required this.helperText,
    required this.progressWidget,
    this.trailing,
  });

  final String title;
  final String headline;
  final String goalLabel;
  final String helperText;
  final Widget progressWidget;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(title, style: textTheme.titleLarge),
                    const SizedBox(height: 14),
                    RichText(
                      text: TextSpan(
                        text: headline,
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        children: <InlineSpan>[
                          TextSpan(
                            text: ' $goalLabel',
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...<Widget>[
                const SizedBox(width: 16),
                trailing!,
              ],
            ],
          ),
          const SizedBox(height: 18),
          progressWidget,
          const SizedBox(height: 14),
          Text(
            helperText,
            style: textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
