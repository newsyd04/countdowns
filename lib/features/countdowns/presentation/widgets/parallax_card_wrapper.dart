import 'package:flutter/material.dart';

import '../../../../core/theme/app_animations.dart';

/// Wraps a child widget with subtle scroll-aware depth effects.
///
/// Cards near the vertical center of the screen get:
/// - Slight scale boost (1.0 → 1.02)
/// - Enhanced shadow elevation
///
/// Cards at the edges settle back to their resting state.
/// The effect is intentionally subtle — it should feel like
/// natural depth, not a carousel zoom.
class ParallaxCardWrapper extends StatelessWidget {
  final Widget child;
  final ScrollController scrollController;
  final double shadowMultiplier;

  const ParallaxCardWrapper({
    super.key,
    required this.child,
    required this.scrollController,
    this.shadowMultiplier = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: scrollController,
      builder: (context, child) {
        // Safely get screen position — return identity if layout not ready
        final proximity = _calculateProximity(context);

        // Scale: 1.0 at edges → parallaxMaxScale at center
        final scale = 1.0 +
            (AppAnimations.parallaxMaxScale - 1.0) * proximity * proximity;

        // Shadow: base elevation boosted near center
        final elevation = 2.0 + (6.0 * proximity * shadowMultiplier);

        return Transform.scale(
          scale: scale,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color:
                      Colors.black.withValues(alpha: 0.08 + 0.12 * proximity),
                  blurRadius: elevation * 2,
                  offset: Offset(0, elevation * 0.5),
                  spreadRadius: -2,
                ),
              ],
            ),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// Calculate proximity to screen center (0.0 = edge, 1.0 = center).
  /// Returns 0.0 if the render object isn't ready for measurement.
  double _calculateProximity(BuildContext context) {
    try {
      final renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox == null || !renderBox.hasSize || !renderBox.attached) {
        return 0.0;
      }

      final screenHeight = MediaQuery.of(context).size.height;
      final screenCenter = screenHeight / 2;

      final widgetPosition = renderBox.localToGlobal(Offset.zero);
      final widgetCenter = widgetPosition.dy + renderBox.size.height / 2;

      final distanceFromCenter = (widgetCenter - screenCenter).abs();
      final normalizedDistance =
          (distanceFromCenter / (screenHeight / 2)).clamp(0.0, 1.0);

      return 1.0 - normalizedDistance;
    } catch (_) {
      // RenderBox not yet laid out — return neutral position
      return 0.0;
    }
  }
}
