import 'package:flutter/material.dart';

class AvatarColorPair {
  const AvatarColorPair({
    required this.background,
    required this.text,
  });

  final Color background;
  final Color text;
}

class AvatarColorHelper {
  static const List<AvatarColorPair> palette = [
    AvatarColorPair(
      background: Color(0xFFEEF2FF), // Indigo
      text: Color(0xFF4F46E5),
    ),
    AvatarColorPair(
      background: Color(0xFFECFDF5), // Emerald
      text: Color(0xFF059669),
    ),
    AvatarColorPair(
      background: Color(0xFFFFFBEB), // Amber
      text: Color(0xFFD97706),
    ),
    AvatarColorPair(
      background: Color(0xFFFFE4E6), // Rose
      text: Color(0xFFE11D48),
    ),
    AvatarColorPair(
      background: Color(0xFFE0F2FE), // Sky
      text: Color(0xFF0284C7),
    ),
    AvatarColorPair(
      background: Color(0xFFF3E8FF), // Purple
      text: Color(0xFF7E22CE),
    ),
    AvatarColorPair(
      background: Color(0xFFFFEDD5), // Orange
      text: Color(0xFFEA580C),
    ),
    AvatarColorPair(
      background: Color(0xFFCCFBF1), // Teal
      text: Color(0xFF0D9488),
    ),
    AvatarColorPair(
      background: Color(0xFFE8F0FE), // Royal Blue
      text: Color(0xFF1D4ED8),
    ),
    AvatarColorPair(
      background: Color(0xFFFCE7F3), // Fuchsia
      text: Color(0xFFC026D3),
    ),
    AvatarColorPair(
      background: Color(0xFFFEE2E2), // Crimson
      text: Color(0xFFDC2626),
    ),
  ];

  /// Returns a deterministic [AvatarColorPair] based on the client/user's [name].
  static AvatarColorPair getColorPair(String? name) {
    if (name == null || name.trim().isEmpty) {
      return palette.first;
    }

    final trimmed = name.trim();
    var initialCode = 0;
    for (final rune in trimmed.runes) {
      final c = String.fromCharCode(rune).toUpperCase();
      if (RegExp('[A-Z0-9]').hasMatch(c)) {
        initialCode = c.codeUnitAt(0);
        break;
      }
    }

    var hash = initialCode;
    for (final rune in trimmed.toLowerCase().codeUnits) {
      hash = (hash * 31 + rune) & 0x7FFFFFFF;
    }

    return palette[hash % palette.length];
  }

  /// Extracts the primary initial (A-Z or 0-9) from [name], or fallback 'C'.
  static String getInitial(String? name, {String fallback = 'C'}) {
    if (name == null || name.trim().isEmpty) {
      return fallback;
    }
    final trimmed = name.trim();
    for (final rune in trimmed.runes) {
      final char = String.fromCharCode(rune);
      if (RegExp('[a-zA-Z0-9]').hasMatch(char)) {
        return char.toUpperCase();
      }
    }
    return fallback;
  }
}
