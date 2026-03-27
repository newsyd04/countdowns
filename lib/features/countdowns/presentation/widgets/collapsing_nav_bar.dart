import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../../../../core/theme/app_animations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/haptic_utils.dart';

/// Apple-native collapsing navigation bar with glass-layer tuning.
///
/// Uses CupertinoSliverNavigationBar for layout safety during route
/// transitions. Glass effect is achieved via the framework's internal
/// BackdropFilter (activated when backgroundColor has alpha < 1.0).
///
/// Glass layering model:
/// 1. Blur layer — handled by CupertinoSliverNavigationBar internally (~10 sigma)
/// 2. Neutral tint overlay — backgroundColor with tuned alpha (0.78)
/// 3. Depth separation — border set to empty (no harsh divider)
/// 4. Foreground — title, gear icon, "+" icon
///
/// The neutral tint uses white (light mode) or near-black (dark mode)
/// to prevent color bleed from bright countdown cards underneath.
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
    // ─── Glass Tint Layer ──────────────────────────────────────
    // Use a neutral color (white/near-black) instead of the page
    // background to prevent card color contamination.
    // Opacity 0.78 = translucent enough to feel glassy,
    // opaque enough to neutralize bright colors underneath.
    final glassTint = isDark
        ? const Color(0xFF1C1C1E).withValues(alpha: 0.78)
        : const Color(0xFFF9F9F9).withValues(alpha: 0.78);

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
      backgroundColor: glassTint,
      border: const Border(), // No divider — glass separation is sufficient
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
      SpringSimulation(AppAnimations.tapSpring, _scaleController.value, 0.96, 0),
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
    final iconColor = widget.isDark
        ? AppColors.accentDark
        : AppColors.accent;

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
