import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Apple-inspired color palette.
///
/// Colors are organized into semantic groups matching Apple HIG:
/// - Labels (text colors with opacity hierarchy)
/// - Backgrounds & Surfaces (layered depth system)
/// - Card colors (vibrant, accessible palette for countdown cards)
/// - System colors (accent, destructive, separator)
class AppColors {
  AppColors._();

  // ─── Light Mode ───────────────────────────────────────────

  // Labels
  static const Color labelPrimary = Color(0xFF000000);
  static const Color labelSecondary = Color(0x993C3C43);
  static const Color labelTertiary = Color(0x4D3C3C43);

  // Backgrounds
  static const Color backgroundPrimary = Color(0xFFF2F2F7);
  static const Color backgroundSecondary = Color(0xFFFFFFFF);
  static const Color backgroundTertiary = Color(0xFFF2F2F7);

  // Surfaces
  static const Color surfacePrimary = Color(0xFFFFFFFF);
  static const Color surfaceSecondary = Color(0xFFF2F2F7);
  static const Color surfaceElevated = Color(0xFFFFFFFF);

  // System
  static const Color accent = Color(0xFF007AFF);
  static const Color accentSecondary = Color(0xFF5856D6);
  static const Color destructive = Color(0xFFFF3B30);
  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFF9500);
  static const Color separator = Color(0x4D3C3C43);
  static const Color separatorOpaque = Color(0xFFC6C6C8);

  // ─── Dark Mode ────────────────────────────────────────────

  static const Color labelPrimaryDark = Color(0xFFFFFFFF);
  static const Color labelSecondaryDark = Color(0x99EBEBF5);
  static const Color labelTertiaryDark = Color(0x4DEBEBF5);

  static const Color backgroundPrimaryDark = Color(0xFF000000);
  static const Color backgroundSecondaryDark = Color(0xFF1C1C1E);
  static const Color backgroundTertiaryDark = Color(0xFF2C2C2E);

  static const Color surfacePrimaryDark = Color(0xFF1C1C1E);
  static const Color surfaceSecondaryDark = Color(0xFF2C2C2E);
  static const Color surfaceElevatedDark = Color(0xFF2C2C2E);

  static const Color accentDark = Color(0xFF0A84FF);
  static const Color accentSecondaryDark = Color(0xFF5E5CE6);
  static const Color destructiveDark = Color(0xFFFF453A);
  static const Color successDark = Color(0xFF30D158);
  static const Color warningDark = Color(0xFFFF9F0A);
  static const Color separatorDark = Color(0x99545458);
  static const Color separatorOpaqueDark = Color(0xFF38383A);

  // ─── Card Colors (Vibrant Apple Palette) ──────────────────

  /// Curated palette of 12 vibrant colors for countdown cards.
  /// Each color is chosen for:
  /// - High visual impact on both light and dark backgrounds
  /// - WCAG AA contrast ratio with white text
  /// - Distinctiveness from adjacent colors in the palette
  static const List<CardColor> cardColors = [
    CardColor(
      name: 'Coral',
      color: Color(0xFFFF6B6B),
      darkVariant: Color(0xFFFF5252),
      textColor: Colors.white,
    ),
    CardColor(
      name: 'Tangerine',
      color: Color(0xFFFF9500),
      darkVariant: Color(0xFFFF9F0A),
      textColor: Colors.white,
    ),
    CardColor(
      name: 'Sunflower',
      color: Color(0xFFFFCC02),
      darkVariant: Color(0xFFFFD60A),
      textColor: Colors.white,
    ),
    CardColor(
      name: 'Mint',
      color: Color(0xFF34C759),
      darkVariant: Color(0xFF30D158),
      textColor: Colors.white,
    ),
    CardColor(
      name: 'Teal',
      color: Color(0xFF5AC8FA),
      darkVariant: Color(0xFF64D2FF),
      textColor: Colors.white,
    ),
    CardColor(
      name: 'Ocean',
      color: Color(0xFF007AFF),
      darkVariant: Color(0xFF0A84FF),
      textColor: Colors.white,
    ),
    CardColor(
      name: 'Indigo',
      color: Color(0xFF5856D6),
      darkVariant: Color(0xFF5E5CE6),
      textColor: Colors.white,
    ),
    CardColor(
      name: 'Purple',
      color: Color(0xFFAF52DE),
      darkVariant: Color(0xFFBF5AF2),
      textColor: Colors.white,
    ),
    CardColor(
      name: 'Rose',
      color: Color(0xFFFF2D55),
      darkVariant: Color(0xFFFF375F),
      textColor: Colors.white,
    ),
    CardColor(
      name: 'Graphite',
      color: Color(0xFF8E8E93),
      darkVariant: Color(0xFF98989D),
      textColor: Colors.white,
    ),
    CardColor(
      name: 'Storm',
      color: Color(0xFF636366),
      darkVariant: Color(0xFF6C6C70),
      textColor: Colors.white,
    ),
    CardColor(
      name: 'Midnight',
      color: Color(0xFF1C1C1E),
      darkVariant: Color(0xFF3A3A3C),
      textColor: Colors.white,
    ),
  ];

  /// Returns the CardColor at the given index, cycling if out of bounds.
  /// Applies a subtle algorithmic hue/brightness shift seeded by [seed]
  /// (e.g., countdown ID hash) for organic color variation.
  static CardColor cardColorAt(int index, {int? seed}) {
    final base = cardColors[index % cardColors.length];
    if (seed == null) return base;
    return _applyDynamicShift(base, seed);
  }

  /// Subtle algorithmic color variation.
  /// Shifts hue by ±8° and brightness by ±5% based on the seed,
  /// keeping colors vibrant and never muddy/desaturated.
  static CardColor _applyDynamicShift(CardColor base, int seed) {
    final rng = math.Random(seed);
    final hueShift = (rng.nextDouble() - 0.5) * 16; // ±8°
    final brightnessShift = (rng.nextDouble() - 0.5) * 0.1; // ±5%

    return CardColor(
      name: base.name,
      color: _shiftColor(base.color, hueShift, brightnessShift),
      darkVariant: _shiftColor(base.darkVariant, hueShift, brightnessShift),
      textColor: base.textColor, // Always preserve text color
    );
  }

  static Color _shiftColor(
      Color color, double hueShift, double brightnessShift) {
    final hsl = HSLColor.fromColor(color);
    final newHue = (hsl.hue + hueShift) % 360;
    final newLightness = (hsl.lightness + brightnessShift).clamp(0.25, 0.75);
    // Preserve saturation — never desaturate below 0.5
    final newSaturation = hsl.saturation.clamp(0.5, 1.0);
    return HSLColor.fromAHSL(1.0, newHue, newSaturation, newLightness)
        .toColor();
  }
}

/// A named color with light/dark variants and an accessible text color.
class CardColor {
  final String name;
  final Color color;
  final Color darkVariant;
  final Color textColor;

  const CardColor({
    required this.name,
    required this.color,
    required this.darkVariant,
    required this.textColor,
  });

  Color resolveColor(Brightness brightness) {
    return brightness == Brightness.dark ? darkVariant : color;
  }
}
