import 'package:flutter/material.dart';

@immutable
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  final Color background;
  final Color surface;
  final Color card;
  final Color border;
  final Color divider;
  final Color textPrimary;
  final Color textSecondary;
  final Color fieldFill;
  final Color icon;
  final Color success;
  final Color warning;
  final Color error;

  const AppThemeColors({
    required this.background,
    required this.surface,
    required this.card,
    required this.border,
    required this.divider,
    required this.textPrimary,
    required this.textSecondary,
    required this.fieldFill,
    required this.icon,
    required this.success,
    required this.warning,
    required this.error,
  });

  static const AppThemeColors light = AppThemeColors(
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFF8F9FA),
    card: Color(0xFFFFFFFF),
    border: Color(0xFFE8E8E8),
    divider: Color(0xFFEEEEEE),
    textPrimary: Color(0xFF020202),
    textSecondary: Color(0xFF666666),
    fieldFill: Color(0xFFF4F5FA),
    icon: Color(0xFF020202),
    success: Color(0xFF16A34A),
    warning: Color(0xFFD97706),
    error: Color(0xFFFF3434),
  );

  static const AppThemeColors dark = AppThemeColors(
    background: Color(0xFF000000),
    surface: Color(0xFF121212),
    card: Color(0xFF121212),
    border: Color(0xFF242424),
    divider: Color(0xFF222222),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFB0B0B0),
    fieldFill: Color(0xFF1A1A1A),
    icon: Color(0xFFFFFFFF),
    success: Color(0xFF22C55E),
    warning: Color(0xFFF59E0B),
    error: Color(0xFFEF4444),
  );

  @override
  AppThemeColors copyWith({
    Color? background,
    Color? surface,
    Color? card,
    Color? border,
    Color? divider,
    Color? textPrimary,
    Color? textSecondary,
    Color? fieldFill,
    Color? icon,
    Color? success,
    Color? warning,
    Color? error,
  }) {
    return AppThemeColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      card: card ?? this.card,
      border: border ?? this.border,
      divider: divider ?? this.divider,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      fieldFill: fieldFill ?? this.fieldFill,
      icon: icon ?? this.icon,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
    );
  }

  @override
  AppThemeColors lerp(ThemeExtension<AppThemeColors>? other, double t) {
    if (other is! AppThemeColors) {
      return this;
    }
    return AppThemeColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      card: Color.lerp(card, other.card, t)!,
      border: Color.lerp(border, other.border, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      fieldFill: Color.lerp(fieldFill, other.fieldFill, t)!,
      icon: Color.lerp(icon, other.icon, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
    );
  }
}

extension AppThemeX on BuildContext {
  AppThemeColors get colors =>
      Theme.of(this).extension<AppThemeColors>() ?? AppThemeColors.light;
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
