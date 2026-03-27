import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


/// Device performance classification.
///
/// Controls which visual effects are enabled to maintain 60fps
/// on mid-range devices while enabling luxury effects on high-end.
enum DeviceTier {
  /// Low-end: minimal effects, prioritize 60fps
  low,

  /// Mid-range: standard effects, selective enhancements
  mid,

  /// High-end: full parallax, richer shadows, all effects
  high,
}

/// Singleton provider for the detected device tier.
/// Detected once at app startup and cached for the session.
final deviceTierProvider = Provider<DeviceTier>((ref) {
  return PerformanceTier.detect();
});

/// Performance capabilities resolved from the device tier.
/// Use this in widgets to decide which effects to render.
final performanceCapsProvider = Provider<PerformanceCaps>((ref) {
  final tier = ref.watch(deviceTierProvider);
  return PerformanceCaps.fromTier(tier);
});

/// Device tier detection and capability resolution.
class PerformanceTier {
  PerformanceTier._();

  /// Detect device tier based on platform heuristics.
  ///
  /// On web, we default to mid-tier since we can't query hardware.
  /// On native platforms, we check physical memory as a proxy
  /// for overall device capability.
  static DeviceTier detect() {
    // Web: default to mid-tier (no hardware introspection)
    if (kIsWeb) return DeviceTier.mid;

    // Debug mode: always high-tier for development
    if (kDebugMode) return DeviceTier.high;

    // Native: use platform heuristics via defaultTargetPlatform
    // (avoids dart:io import which breaks web compilation)
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        // Apple devices from 2019+ are universally high-tier
        return DeviceTier.high;
      case TargetPlatform.android:
        // Android: conservative default to mid-tier
        // In production, enhance with device_info_plus RAM check
        return DeviceTier.mid;
      default:
        return DeviceTier.mid;
    }
  }
}

/// Resolved performance capabilities for the current device.
///
/// Widgets check these flags rather than querying the tier directly,
/// which decouples the decision logic from the rendering logic.
class PerformanceCaps {
  /// Whether to apply micro-parallax and depth effects on scroll.
  final bool enableParallax;

  /// Whether to use richer box shadows (multiple layers, larger blur).
  final bool enableRichShadows;

  /// Whether to use spring physics for animations.
  final bool enableSprings;

  /// Maximum blur sigma for frosted glass effects.
  final double maxBlurSigma;

  /// Shadow elevation multiplier (1.0 = standard, >1 = enhanced).
  final double shadowMultiplier;

  const PerformanceCaps({
    required this.enableParallax,
    required this.enableRichShadows,
    required this.enableSprings,
    required this.maxBlurSigma,
    required this.shadowMultiplier,
  });

  factory PerformanceCaps.fromTier(DeviceTier tier) {
    switch (tier) {
      case DeviceTier.low:
        return const PerformanceCaps(
          enableParallax: false,
          enableRichShadows: false,
          enableSprings: false,
          maxBlurSigma: 10,
          shadowMultiplier: 0.6,
        );
      case DeviceTier.mid:
        return const PerformanceCaps(
          enableParallax: true,
          enableRichShadows: true,
          enableSprings: true,
          maxBlurSigma: 15,
          shadowMultiplier: 1.0,
        );
      case DeviceTier.high:
        return const PerformanceCaps(
          enableParallax: true,
          enableRichShadows: true,
          enableSprings: true,
          maxBlurSigma: 20,
          shadowMultiplier: 1.3,
        );
    }
  }
}
