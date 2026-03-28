import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/haptic_utils.dart';

/// Physics-based swipe gesture wrapper with resistance, velocity handling,
/// and magnetic snap behavior.
///
/// Swipe LEFT → reveal DELETE action
/// Swipe RIGHT → reveal EDIT action
///
/// Gesture model:
/// - Initial: slight resistance (deadzone prevents accidental swipes)
/// - Mid: smooth, responsive tracking
/// - Limits: elastic resistance
///
/// Snap behavior:
/// - Small swipe → spring back to center
/// - Medium swipe → settle into "action revealed" state
///
/// User must tap the revealed action button to trigger edit/delete.
class PhysicsSwipeCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final double actionExtent;
  final BorderRadius borderRadius;

  const PhysicsSwipeCard({
    super.key,
    required this.child,
    this.onEdit,
    this.onDelete,
    this.actionExtent = 80,
    this.borderRadius = const BorderRadius.all(Radius.circular(AppSpacing.cardRadius)),
  });

  @override
  State<PhysicsSwipeCard> createState() => _PhysicsSwipeCardState();
}

class _PhysicsSwipeCardState extends State<PhysicsSwipeCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // Gesture tracking
  double _dragStartX = 0;
  double _currentOffset = 0;
  bool _isDragging = false;
  bool _hasTriggeredHaptic = false;

  // Thresholds
  static const double _deadzone = 8; // px before swipe activates
  static const double _snapThreshold = 0.4; // % of actionExtent to snap open
  static const double _elasticFactor = 0.3; // resistance beyond limits

  // Spring for snap-back and settle
  static const SpringDescription _snapSpring = SpringDescription(
    mass: 1.0,
    stiffness: 350,
    damping: 26,
  );

  @override
  void initState() {
    super.initState();
    _controller = AnimationController.unbounded(vsync: this, value: 0);
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    _controller.stop();
    _isDragging = true;
    _hasTriggeredHaptic = false;
    _dragStartX = details.localPosition.dx;
    _currentOffset = _controller.value;
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;

    final rawDelta = details.localPosition.dx - _dragStartX;
    var targetOffset = _currentOffset + rawDelta;

    // Apply deadzone
    if (targetOffset.abs() < _deadzone) {
      targetOffset = 0;
    } else {
      targetOffset = targetOffset - targetOffset.sign * _deadzone;
    }

    // Apply resistance model
    targetOffset = _applyResistance(targetOffset);

    _controller.value = targetOffset;

    // Haptic feedback when crossing action threshold
    if (!_hasTriggeredHaptic && targetOffset.abs() > widget.actionExtent * _snapThreshold) {
      AppHaptics.selection();
      _hasTriggeredHaptic = true;
    }
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    _isDragging = false;
    final velocity = details.primaryVelocity ?? 0;
    final offset = _controller.value;

    // ─── Determine snap target ──────────────────────────────
    double snapTarget = 0;

    if (offset < 0) {
      // Swiping left (delete direction)
      final progress = offset.abs() / widget.actionExtent;
      if (progress > _snapThreshold || velocity < -200) {
        snapTarget = -widget.actionExtent;
      }
    } else if (offset > 0) {
      // Swiping right (edit direction)
      final progress = offset / widget.actionExtent;
      if (progress > _snapThreshold || velocity > 200) {
        snapTarget = widget.actionExtent;
      }
    }

    _animateTo(snapTarget, velocity);
  }

  /// Non-linear resistance model.
  /// Linear in the middle zone, elastic at the limits.
  double _applyResistance(double offset) {
    final maxExtent = widget.actionExtent * 1.2;

    if (offset.abs() <= widget.actionExtent) {
      return offset; // Free movement within action zone
    }

    // Beyond action extent: elastic resistance
    final excess = offset.abs() - widget.actionExtent;
    final dampedExcess = excess * _elasticFactor;
    return offset.sign * (widget.actionExtent + dampedExcess).clamp(0, maxExtent);
  }

  void _animateTo(double target, [double velocity = 0]) {
    _controller.animateWith(
      SpringSimulation(
        _snapSpring,
        _controller.value,
        target,
        velocity / 1000, // convert px/s to reasonable velocity
      ),
    );
  }

  void _handleActionTap(bool isDelete) {
    if (isDelete) {
      AppHaptics.medium();
      widget.onDelete?.call();
    } else {
      AppHaptics.light();
      widget.onEdit?.call();
    }
    _animateTo(0);
  }

  @override
  Widget build(BuildContext context) {
    final offset = _controller.value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Action reveal progress (0→1)
    final deleteProgress = offset < 0
        ? (offset.abs() / widget.actionExtent).clamp(0.0, 1.0)
        : 0.0;
    final editProgress = offset > 0
        ? (offset / widget.actionExtent).clamp(0.0, 1.0)
        : 0.0;

    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: Stack(
        children: [
          // ─── Action Backgrounds (behind card) ─────────────
          if (deleteProgress > 0)
            Positioned.fill(
              child: Container(
                alignment: Alignment.centerRight,
                decoration: BoxDecoration(
                  color: AppColors.destructive,
                  borderRadius: widget.borderRadius,
                ),
                padding: const EdgeInsets.only(right: AppSpacing.xl),
                child: Opacity(
                  opacity: deleteProgress,
                  child: Transform.scale(
                    scale: 0.8 + 0.2 * deleteProgress,
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(CupertinoIcons.trash, color: Colors.white, size: 22),
                        SizedBox(height: 4),
                        Text(
                          'Delete',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          if (editProgress > 0)
            Positioned.fill(
              child: Container(
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: widget.borderRadius,
                ),
                padding: const EdgeInsets.only(left: AppSpacing.xl),
                child: Opacity(
                  opacity: editProgress,
                  child: Transform.scale(
                    scale: 0.8 + 0.2 * editProgress,
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(CupertinoIcons.pencil, color: Colors.white, size: 22),
                        SizedBox(height: 4),
                        Text(
                          'Edit',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // ─── Card (translates with finger) ────────────────
          GestureDetector(
            onHorizontalDragStart: _onHorizontalDragStart,
            onHorizontalDragUpdate: _onHorizontalDragUpdate,
            onHorizontalDragEnd: _onHorizontalDragEnd,
            child: Transform.translate(
              offset: Offset(offset, 0),
              child: widget.child,
            ),
          ),

          // ─── Tap targets over revealed actions ────────────
          if (deleteProgress > 0.5)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: offset.abs().clamp(0, widget.actionExtent),
              child: GestureDetector(
                onTap: () => _handleActionTap(true),
                behavior: HitTestBehavior.opaque,
              ),
            ),

          if (editProgress > 0.5)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: offset.clamp(0, widget.actionExtent),
              child: GestureDetector(
                onTap: () => _handleActionTap(false),
                behavior: HitTestBehavior.opaque,
              ),
            ),
        ],
      ),
    );
  }
}
