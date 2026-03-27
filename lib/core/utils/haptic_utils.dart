import 'package:flutter/services.dart';

/// Premium haptic feedback tuned per interaction type.
///
/// Respects the global haptics preference. When disabled,
/// all methods are no-ops. Call [AppHaptics.setEnabled] at
/// startup and when the setting changes.
class AppHaptics {
  AppHaptics._();

  /// Global enabled state — set from preferences provider.
  static bool _enabled = true;

  /// Update the global haptics enabled state.
  /// Called when the preference changes.
  static void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  /// Light tap — selections, toggles, small interactions.
  static Future<void> light() async {
    if (!_enabled) return;
    await HapticFeedback.lightImpact();
  }

  /// Medium impact — significant actions like delete, reorder.
  static Future<void> medium() async {
    if (!_enabled) return;
    await HapticFeedback.mediumImpact();
  }

  /// Heavy impact — destructive confirmations (used sparingly).
  static Future<void> heavy() async {
    if (!_enabled) return;
    await HapticFeedback.heavyImpact();
  }

  /// Selection tick — picker scrolling, segment changes.
  static Future<void> selection() async {
    if (!_enabled) return;
    await HapticFeedback.selectionClick();
  }

  /// Success — creating/saving a countdown.
  static Future<void> success() async {
    if (!_enabled) return;
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.lightImpact();
  }

  /// Error — validation failures.
  static Future<void> error() async {
    if (!_enabled) return;
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 80));
    await HapticFeedback.heavyImpact();
  }

  /// Warning — destructive action previews (swipe to delete).
  static Future<void> warning() async {
    if (!_enabled) return;
    await HapticFeedback.mediumImpact();
  }
}
