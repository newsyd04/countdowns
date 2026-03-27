import 'package:flutter/material.dart';

/// Strict 8pt grid spacing system.
///
/// All spacing values are multiples of 8 (with 4pt half-step
/// for tight optical adjustments). This ensures pixel-perfect
/// alignment across all screen densities.
///
/// Corner radius scale: Small (12), Medium (16), Large (20+).
class AppSpacing {
  AppSpacing._();

  // ─── Base Grid (strict 8pt multiples) ─────────────────────

  /// 4pt — optical adjustment only (half-step)
  static const double xxs = 4;

  /// 8pt — minimum standard spacing
  static const double xs = 8;

  /// 8pt — alias for xs (backward compat)
  static const double sm = 8;

  /// 16pt — standard content spacing
  static const double md = 16;

  /// 16pt — alias for md (backward compat)
  static const double lg = 16;

  /// 24pt — section-level spacing
  static const double xl = 24;

  /// 24pt — alias for xl
  static const double xxl = 24;

  /// 32pt — major section breaks
  static const double xxxl = 32;

  /// 48pt — hero spacing
  static const double huge = 48;

  /// 64pt — maximum spacing
  static const double massive = 64;

  // ─── Semantic Spacing ─────────────────────────────────────

  /// Internal card padding (16pt)
  static const double cardPadding = 16;

  /// Space between list items (8pt)
  static const double listItemSpacing = 8;

  /// Space between major sections (24pt)
  static const double sectionSpacing = 24;

  /// Horizontal screen margin (16pt)
  static const double screenHorizontal = 16;

  /// Vertical screen margin (16pt)
  static const double screenVertical = 16;

  // ─── Corner Radius Scale ──────────────────────────────────

  /// Small radius — buttons, chips, badges (12pt)
  static const double buttonRadius = 12;

  /// Medium radius — cards, inputs (16pt)
  static const double cardRadius = 16;

  /// Large radius — modals, sheets (20pt)
  static const double modalRadius = 20;

  /// Pill radius — fully rounded chips/tags (20pt)
  static const double chipRadius = 20;

  // ─── Prebuilt Edge Insets ─────────────────────────────────

  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: screenHorizontal,
    vertical: screenVertical,
  );

  static const EdgeInsets cardInsets = EdgeInsets.all(cardPadding);

  static const EdgeInsets sectionInsets = EdgeInsets.symmetric(
    horizontal: screenHorizontal,
    vertical: sectionSpacing,
  );
}
