import 'package:flutter/services.dart';

/// Premium haptic feedback tuned per interaction type.
///
/// Apple's Taptic Engine provides distinct feedback patterns.
/// We map semantic actions to the appropriate haptic intensity
/// so the app feels responsive without being overwhelming.
class AppHaptics {
  AppHaptics._();

  /// Light tap — used for selections, toggles, small interactions.
  static Future<void> light() async {
    await HapticFeedback.lightImpact();
  }

  /// Medium impact — used for significant actions like delete, reorder.
  static Future<void> medium() async {
    await HapticFeedback.mediumImpact();
  }

  /// Heavy impact — used sparingly for destructive confirmations.
  static Future<void> heavy() async {
    await HapticFeedback.heavyImpact();
  }

  /// Selection tick — used for picker scrolling, segment changes.
  static Future<void> selection() async {
    await HapticFeedback.selectionClick();
  }

  /// Success notification — used when creating/saving a countdown.
  static Future<void> success() async {
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.lightImpact();
  }

  /// Error notification — used for validation failures.
  static Future<void> error() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 80));
    await HapticFeedback.heavyImpact();
  }

  /// Warning — used for destructive action previews (swipe to delete).
  static Future<void> warning() async {
    await HapticFeedback.mediumImpact();
  }
}
