import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:intl/intl.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_animations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_utils.dart' show RecurrenceType;
import '../../../../core/utils/haptic_utils.dart';
import '../../domain/entities/countdown.dart';
import '../providers/countdown_display_cache.dart';
import 'physics_swipe_card.dart';

/// Premium countdown card with:
/// - Vibrant background color with dynamic shift
/// - Frosted glass overlay
/// - Spring-based tap scale animation
/// - Physics-based swipe gestures (edit/delete)
/// - Emoji display
/// - Days remaining with unit label
class CountdownCard extends StatefulWidget {
  final Countdown countdown;
  final CountdownDisplayValues? displayValues;
  final bool isPast;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CountdownCard({
    super.key,
    required this.countdown,
    this.displayValues,
    this.isPast = false,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<CountdownCard> createState() => _CountdownCardState();
}

class _CountdownCardState extends State<CountdownCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController.unbounded(
      vsync: this,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _animatePress() {
    _scaleController.animateWith(
      SpringSimulation(
        AppAnimations.tapSpring,
        _scaleController.value,
        AppAnimations.tapScale,
        0,
      ),
    );
  }

  void _animateRelease() {
    _scaleController.animateWith(
      SpringSimulation(
        AppAnimations.tapSpring,
        _scaleController.value,
        1.0,
        0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = AppColors.cardColorAt(
      widget.countdown.colorIndex,
      seed: widget.countdown.id.hashCode,
    );
    final bgColor = cardColor.resolveColor(context.brightness);
    final textColor = cardColor.textColor;
    final dateFormat = DateFormat('MMM d, y');
    final countdown = widget.countdown;
    final dv = widget.displayValues;
    final isToday = dv?.isToday ?? countdown.isToday;
    final daysRemaining = dv?.daysRemaining ?? countdown.daysRemaining;
    final formattedCountdown =
        dv?.formattedCountdown ?? countdown.formattedCountdown;
    final effectiveDate = dv?.effectiveDate ?? countdown.effectiveDate;

    final cardContent = GestureDetector(
      onTapDown: (_) => _animatePress(),
      onTapUp: (_) {
        _animateRelease();
        AppHaptics.light();
        widget.onTap?.call();
      },
      onTapCancel: () => _animateRelease(),
      child: AnimatedBuilder(
        animation: _scaleController,
        builder: (context, child) => Transform.scale(
          scale: _scaleController.value,
          child: child,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            boxShadow: [
              BoxShadow(
                color: bgColor.withValues(alpha: widget.isPast ? 0.15 : 0.3),
                blurRadius: widget.isPast ? 8 : 16,
                offset: const Offset(0, 4),
                spreadRadius: -2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            child: Container(
              decoration: BoxDecoration(
                color: bgColor.withValues(alpha: widget.isPast ? 0.6 : 1.0),
              ),
              child: Stack(
                children: [
                  // Frosted glass highlight
                  Positioned(
                    top: -20,
                    left: -20,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.15),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Card content
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.cardPadding),
                    child: Row(
                      children: [
                        // Emoji
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              countdown.emoji,
                              style: const TextStyle(fontSize: 26),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.lg),

                        // Title & Date
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                countdown.title,
                                style: AppTypography.headline.copyWith(
                                  color: textColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: AppSpacing.xxs),
                              Text(
                                dateFormat.format(effectiveDate),
                                style: AppTypography.footnote.copyWith(
                                  color: textColor.withValues(alpha: 0.75),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),

                        // Days remaining
                        Padding(
                          padding: EdgeInsets.only(
                            top: countdown.recurrence != RecurrenceType.none
                                ? 20
                                : 0,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                isToday ? '\u{2728}' : '$daysRemaining',
                                style: isToday
                                    ? const TextStyle(fontSize: 32)
                                    : AppTypography.countdownLarge.copyWith(
                                        color: textColor,
                                        fontSize: 36,
                                      ),
                              ),
                              if (!isToday)
                                Text(
                                  formattedCountdown,
                                  style: AppTypography.countdownUnit.copyWith(
                                    color: textColor.withValues(alpha: 0.7),
                                    fontSize: 12,
                                  ),
                                ),
                              if (isToday)
                                Text(
                                  'Today!',
                                  style: AppTypography.calloutSemibold.copyWith(
                                    color: textColor,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Recurrence badge
                  if (countdown.recurrence != RecurrenceType.none)
                    Positioned(
                      top: AppSpacing.sm,
                      right: AppSpacing.sm,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              CupertinoIcons.repeat,
                              size: 10,
                              color: textColor.withValues(alpha: 0.8),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              countdown.recurrence.displayName,
                              style: AppTypography.caption2.copyWith(
                                color: textColor.withValues(alpha: 0.8),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return PhysicsSwipeCard(
      onEdit: widget.onEdit,
      onDelete: widget.onDelete,
      child: cardContent,
    );
  }
}
