import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

/// Premium haptic feedback tuned per interaction type.
///
/// Uses the `vibration` package for reliable Android support.
/// Falls back to Flutter's HapticFeedback on iOS (which uses
/// the Taptic Engine natively).
///
/// Respects the global haptics preference. When disabled,
/// all methods are no-ops.
class AppHaptics {
  AppHaptics._();

  static bool _enabled = true;
  static bool? _hasVibrator;

  static void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  /// Check device capability once.
  static Future<bool> _canVibrate() async {
    _hasVibrator ??= await Vibration.hasVibrator() ?? false;
    return _hasVibrator!;
  }

  /// Light tap — selections, toggles, small interactions.
  static Future<void> light() async {
    if (!_enabled) return;
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await HapticFeedback.lightImpact();
    } else if (await _canVibrate()) {
      await Vibration.vibrate(duration: 20, amplitude: 40);
    }
  }

  /// Medium impact — significant actions like delete.
  static Future<void> medium() async {
    if (!_enabled) return;
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await HapticFeedback.mediumImpact();
    } else if (await _canVibrate()) {
      await Vibration.vibrate(duration: 30, amplitude: 80);
    }
  }

  /// Heavy impact — destructive confirmations (used sparingly).
  static Future<void> heavy() async {
    if (!_enabled) return;
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await HapticFeedback.heavyImpact();
    } else if (await _canVibrate()) {
      await Vibration.vibrate(duration: 40, amplitude: 120);
    }
  }

  /// Selection tick — picker scrolling, segment changes.
  static Future<void> selection() async {
    if (!_enabled) return;
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await HapticFeedback.selectionClick();
    } else if (await _canVibrate()) {
      await Vibration.vibrate(duration: 10, amplitude: 30);
    }
  }

  /// Success — creating/saving a countdown.
  static Future<void> success() async {
    if (!_enabled) return;
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.lightImpact();
    } else if (await _canVibrate()) {
      await Vibration.vibrate(duration: 30, amplitude: 80);
      await Future.delayed(const Duration(milliseconds: 100));
      await Vibration.vibrate(duration: 20, amplitude: 40);
    }
  }

  /// Error — validation failures.
  static Future<void> error() async {
    if (!_enabled) return;
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 80));
      await HapticFeedback.heavyImpact();
    } else if (await _canVibrate()) {
      await Vibration.vibrate(duration: 40, amplitude: 120);
      await Future.delayed(const Duration(milliseconds: 80));
      await Vibration.vibrate(duration: 40, amplitude: 120);
    }
  }

  /// Warning — destructive action previews (swipe to delete).
  static Future<void> warning() async {
    if (!_enabled) return;
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await HapticFeedback.mediumImpact();
    } else if (await _canVibrate()) {
      await Vibration.vibrate(duration: 30, amplitude: 80);
    }
  }
}
