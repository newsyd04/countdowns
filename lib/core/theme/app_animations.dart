import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';

/// Apple-style animation constants and spring configurations.
///
/// All animations in the app should use these presets to ensure
/// consistent, physically-grounded motion that matches iOS feel.
class AppAnimations {
  AppAnimations._();

  // ─── Durations ────────────────────────────────────────────

  /// Fast response (button press feedback, scale animations)
  static const Duration fast = Duration(milliseconds: 150);

  /// Normal transitions (card changes, list updates)
  static const Duration normal = Duration(milliseconds: 300);

  /// Slow/dramatic transitions (page transitions, modal sheets)
  static const Duration slow = Duration(milliseconds: 450);

  /// Spring settle time (used as upper bound for spring animations)
  static const Duration spring = Duration(milliseconds: 600);

  // ─── Apple-Style Spring Configurations ────────────────────

  /// Snappy spring for tap feedback (quick, no overshoot).
  /// Matches iOS button press behavior.
  static const SpringDescription tapSpring = SpringDescription(
    mass: 1.0,
    stiffness: 600,
    damping: 30,
  );

  /// Responsive spring for interactive gestures.
  /// Slightly slower with minimal overshoot.
  static const SpringDescription gestureSpring = SpringDescription(
    mass: 1.0,
    stiffness: 400,
    damping: 28,
  );

  /// Fluid spring for list reorder and card movements.
  /// Natural feel with gentle settle.
  static const SpringDescription reorderSpring = SpringDescription(
    mass: 1.0,
    stiffness: 300,
    damping: 24,
  );

  /// Soft spring for modal/sheet presentations.
  /// Smooth entrance with gentle deceleration.
  static const SpringDescription modalSpring = SpringDescription(
    mass: 1.0,
    stiffness: 250,
    damping: 22,
  );

  // ─── Curves ───────────────────────────────────────────────

  /// Default easing for non-spring animations (Apple's easeOutCubic).
  static const Curve defaultCurve = Curves.easeOutCubic;

  /// Deceleration curve for scrolling to a stop.
  static const Curve decelerationCurve = Curves.easeOutQuart;

  /// Gentle entrance curve for content appearing.
  static const Curve entranceCurve = Curves.easeOutCubic;

  /// Exit curve for content leaving.
  static const Curve exitCurve = Curves.easeInCubic;

  // ─── Scale Values ─────────────────────────────────────────

  /// Tap-down scale for interactive cards/buttons.
  static const double tapScale = 0.97;

  /// Drag lift scale for reorderable items.
  static const double dragLiftScale = 1.04;

  /// Parallax center-screen scale boost.
  static const double parallaxMaxScale = 1.02;

  // ─── Helpers ──────────────────────────────────────────────

  /// Create a spring simulation for the given spring config.
  static SpringSimulation springSimulation(
    SpringDescription spring, {
    double start = 0,
    double end = 1,
    double velocity = 0,
  }) {
    return SpringSimulation(spring, start, end, velocity);
  }
}
