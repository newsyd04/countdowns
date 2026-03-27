/// Feature flags and configuration for the Countdowns app.
///
/// Provides a single place to toggle advanced features on/off.
/// This enables device-aware degradation and A/B testing.
class AppConfig {
  AppConfig._();

  // ─── Performance Thresholds ─────────────────────────────────

  /// Device memory threshold (in MB) below which we consider
  /// the device "low-tier" and reduce visual effects.
  static const int lowTierMemoryThresholdMB = 2048;

  /// Maximum number of countdowns to render with full effects.
  /// Beyond this count, effects are simplified for scroll perf.
  static const int fullEffectsCountdownLimit = 30;
}
