import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../../../../core/theme/app_animations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/haptic_utils.dart';

/// Apple-native collapsing navigation bar with unified background.
///
/// Uses CupertinoSliverNavigationBar for layout safety during route
/// transitions. The header uses the same background color as the body
/// at full opacity — no glass effect, no tint. This makes the header
/// feel like a continuous part of the screen surface.
///
/// Separation is provided by a subtle 0.5px divider at 6% opacity.
class CollapsingNavBarSliver extends StatelessWidget {
  final String title;
  final VoidCallback onAddPressed;
  final VoidCallback? onSettingsPressed;
  final bool isDark;

  const CollapsingNavBarSliver({
    super.key,
    required this.title,
    required this.onAddPressed,
    this.onSettingsPressed,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // ─── Header Background ─────────────────────────────────────
    // Same background as body — no glass effect, no tint.
    // The header is a continuous part of the screen surface.
    final headerBg =
        isDark ? AppColors.backgroundPrimaryDark : AppColors.backgroundPrimary;

    return CupertinoSliverNavigationBar(
      largeTitle: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onSettingsPressed != null) ...[
            _NavBarButton(
              icon: CupertinoIcons.gear,
              onPressed: onSettingsPressed!,
              isDark: isDark,
            ),
            const SizedBox(width: 16), // 8pt grid: 16pt between icons
          ],
          _NavBarButton(
            icon: CupertinoIcons.add,
            onPressed: onAddPressed,
            isDark: isDark,
          ),
        ],
      ),
      backgroundColor: headerBg,
      border: Border(
        bottom: BorderSide(
          color: (isDark ? const Color(0xFF545458) : const Color(0xFF3C3C43))
              .withValues(alpha: 0.06),
          width: 0.5,
        ),
      ),
      stretch: true,
    );
  }
}

/// Spring-animated nav bar button with haptic feedback.
///
/// Tap down: Spring to 0.96 scale
/// Tap up: Spring to 1.0 + light haptic + action
/// Cancel: Spring to 1.0
///
/// Icon: 22pt, system blue, 44x44 hit target (Apple HIG minimum).
class _NavBarButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isDark;

  const _NavBarButton({
    required this.icon,
    required this.onPressed,
    required this.isDark,
  });

  @override
  State<_NavBarButton> createState() => _NavBarButtonState();
}

class _NavBarButtonState extends State<_NavBarButton>
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
          AppAnimations.tapSpring, _scaleController.value, 0.96, 0),
    );
  }

  void _animateRelease() {
    _scaleController.animateWith(
      SpringSimulation(AppAnimations.tapSpring, _scaleController.value, 1.0, 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use system blue — matches native iOS nav bar button color
    final iconColor = widget.isDark ? AppColors.accentDark : AppColors.accent;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _animatePress(),
      onTapUp: (_) {
        _animateRelease();
        AppHaptics.light();
        widget.onPressed();
      },
      onTapCancel: () => _animateRelease(),
      child: AnimatedBuilder(
        animation: _scaleController,
        builder: (context, child) => Transform.scale(
          scale: _scaleController.value,
          child: child,
        ),
        child: SizedBox(
          width: 44, // Apple HIG minimum hit target
          height: 44,
          child: Center(
            child: Icon(
              widget.icon,
              size: 22, // Consistent stroke weight
              color: iconColor,
            ),
          ),
        ),
      ),
    );
  }
}
