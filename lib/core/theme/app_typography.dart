import 'package:flutter/material.dart';
import 'app_colors.dart';

/// iOS-style type scale following Apple Human Interface Guidelines.
///
/// Uses SF Pro Display metrics. Falls back to system font if SF Pro
/// is not bundled — on iOS this resolves to SF Pro natively.
class AppTypography {
  AppTypography._();

  static const String _fontFamily = '.SF Pro Display';

  // ─── Large Title ──────────────────────────────────────────
  static const TextStyle largeTitleBold = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 34,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.37,
    height: 1.21,
    color: AppColors.labelPrimary,
  );

  static const TextStyle largeTitleRegular = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 34,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.37,
    height: 1.21,
    color: AppColors.labelPrimary,
  );

  // ─── Title 1 ──────────────────────────────────────────────
  static const TextStyle title1Bold = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.36,
    height: 1.21,
    color: AppColors.labelPrimary,
  );

  static const TextStyle title1Regular = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.36,
    height: 1.21,
    color: AppColors.labelPrimary,
  );

  // ─── Title 2 ──────────────────────────────────────────────
  static const TextStyle title2Bold = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.35,
    height: 1.27,
    color: AppColors.labelPrimary,
  );

  static const TextStyle title2Regular = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.35,
    height: 1.27,
    color: AppColors.labelPrimary,
  );

  // ─── Title 3 ──────────────────────────────────────────────
  static const TextStyle title3Semibold = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.38,
    height: 1.25,
    color: AppColors.labelPrimary,
  );

  static const TextStyle title3Regular = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.38,
    height: 1.25,
    color: AppColors.labelPrimary,
  );

  // ─── Headline ─────────────────────────────────────────────
  static const TextStyle headline = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.41,
    height: 1.29,
    color: AppColors.labelPrimary,
  );

  // ─── Body ─────────────────────────────────────────────────
  static const TextStyle body = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.41,
    height: 1.29,
    color: AppColors.labelPrimary,
  );

  // ─── Callout ──────────────────────────────────────────────
  static const TextStyle callout = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.32,
    height: 1.31,
    color: AppColors.labelPrimary,
  );

  static const TextStyle calloutSemibold = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.32,
    height: 1.31,
    color: AppColors.labelPrimary,
  );

  // ─── Subhead ──────────────────────────────────────────────
  static const TextStyle subhead = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.24,
    height: 1.33,
    color: AppColors.labelSecondary,
  );

  static const TextStyle subheadSemibold = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.24,
    height: 1.33,
    color: AppColors.labelSecondary,
  );

  // ─── Footnote ─────────────────────────────────────────────
  static const TextStyle footnote = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.08,
    height: 1.38,
    color: AppColors.labelSecondary,
  );

  static const TextStyle footnoteSemibold = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.08,
    height: 1.38,
    color: AppColors.labelSecondary,
  );

  // ─── Caption 1 ────────────────────────────────────────────
  static const TextStyle caption1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.33,
    color: AppColors.labelSecondary,
  );

  // ─── Caption 2 ────────────────────────────────────────────
  static const TextStyle caption2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.07,
    height: 1.18,
    color: AppColors.labelTertiary,
  );

  // ─── Countdown Display (Custom) ───────────────────────────
  /// Large number display for the countdown value on cards.
  static const TextStyle countdownLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 48,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.5,
    height: 1.0,
    color: Colors.white,
  );

  /// Unit label below the countdown number.
  static const TextStyle countdownUnit = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.2,
    color: Colors.white70,
  );
}
