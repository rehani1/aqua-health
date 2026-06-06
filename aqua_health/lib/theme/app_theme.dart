import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryBlue = Color(0xFF2D7EEA);
  static const Color primaryBlueDark = Color(0xFF1F63C3);
  static const Color textPrimary = Color(0xFF365381);
  static const Color textSecondary = Color(0xFF5F7BA8);
  static const Color card = Color(0xF7FFFFFF);
  static const Color divider = Color(0x3F89A8D8);
  static const Color chipMuted = Color(0xFFE9EFFB);
  static const Color success = Color(0xFF4A9B69);
  static const Color warning = Color(0xFFD18C45);

  static const LinearGradient pageGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFD6E5FF), Color(0xFFEFEFFF), Color(0xFFE7F1FF)],
  );
}

class AppTheme {
  static ThemeData get lightTheme {
    final ColorScheme colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.primaryBlue,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColors.primaryBlue,
          onPrimary: Colors.white,
          surface: Colors.white,
          onSurface: AppColors.textPrimary,
        );

    final TextTheme textTheme = Typography.material2021().black
        .copyWith(
          headlineLarge: const TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
          headlineMedium: const TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
          headlineSmall: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
          titleLarge: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
          titleMedium: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: const TextStyle(
            fontSize: 18,
            height: 1.45,
            fontWeight: FontWeight.w500,
          ),
          bodyMedium: const TextStyle(
            fontSize: 16,
            height: 1.4,
            fontWeight: FontWeight.w500,
          ),
        )
        .apply(
          bodyColor: AppColors.textPrimary,
          displayColor: AppColors.textPrimary,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: Colors.transparent,
      dividerColor: AppColors.divider,
      splashFactory: InkSparkle.splashFactory,
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.82),
        indicatorColor: const Color(0x402D7EEA),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primaryBlue);
          }
          return const IconThemeData(color: Color(0xFF94AED7));
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: states.contains(WidgetState.selected)
                ? AppColors.primaryBlue
                : const Color(0xFF9AAFD4),
          );
        }),
      ),
    );
  }
}
