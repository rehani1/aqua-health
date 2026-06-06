import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final BorderRadius borderRadius = BorderRadius.circular(32);
    final Color disabledOverlay = AppColors.primaryBlue.withValues(alpha: 0.45);

    final Widget buttonChild = icon == null
        ? Text(label)
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Text(label),
            ],
          );

    return SizedBox(
      width: expand ? double.infinity : null,
      height: 58,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          gradient: onPressed == null
              ? null
              : const LinearGradient(
                  colors: <Color>[
                    AppColors.primaryBlue,
                    AppColors.primaryBlueDark,
                  ],
                ),
          color: onPressed == null ? disabledOverlay : null,
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x30215BAF),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.transparent,
            disabledForegroundColor: Colors.white.withValues(alpha: 0.8),
            disabledBackgroundColor: Colors.transparent,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: borderRadius),
            textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          child: buttonChild,
        ),
      ),
    );
  }
}
