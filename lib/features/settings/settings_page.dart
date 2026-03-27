import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/extensions/context_extensions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/haptic_utils.dart';
import 'settings_provider.dart';

/// Apple-style Settings screen — pixel-precise implementation.
///
/// All spacing values are strict 8pt grid multiples.
/// Row heights target 56pt for comfortable tap targets.
/// Typography matches iOS Settings conventions exactly.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  // ─── Spacing Tokens (strict 8pt grid) ─────────────────────
  static const double _xs = 8;
  static const double _sm = 16;
  static const double _md = 24;
  static const double _lg = 32;

  // ─── Layout Constants ─────────────────────────────────────
  static const double _screenHPadding = 16;
  static const double _groupRadius = 16;
  static const double _rowHPadding = 16;
  static const double _rowVPadding = 16; // yields ~56pt row height
  static const double _iconSize = 22;
  static const double _iconLabelGap = 12;
  static const double _separatorInset = 50; // 16 + 22 + 12 = past icon

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(preferencesProvider);
    final isDark = context.isDark;

    final bgColor = isDark
        ? AppColors.backgroundPrimaryDark
        : AppColors.backgroundPrimary;
    final surfaceColor = isDark
        ? AppColors.surfacePrimaryDark
        : AppColors.surfacePrimary;
    final labelColor = isDark
        ? AppColors.labelPrimaryDark
        : AppColors.labelPrimary;
    final secondaryColor = isDark
        ? AppColors.labelSecondaryDark
        : AppColors.labelSecondary;
    final separatorColor = isDark
        ? AppColors.separatorDark
        : AppColors.separator;

    return CupertinoPageScaffold(
      backgroundColor: bgColor,
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Settings',
          style: AppTypography.headline.copyWith(
            color: labelColor,
            decoration: TextDecoration.none,
          ),
        ),
        backgroundColor: bgColor.withValues(alpha: 0.85),
        border: const Border(), // Empty border — no underline
      ),
      child: SafeArea(
        child: Material(
          color: Colors.transparent,
          child: ListView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: const EdgeInsets.only(
            left: _screenHPadding,
            right: _screenHPadding,
            top: _sm, // 16pt below nav bar
          ),
          children: [
            // ─── Preferences ────────────────────────────────────
            const SizedBox(height: _md), // 24pt before first header
            _buildSectionHeader('PREFERENCES', secondaryColor),
            const SizedBox(height: _xs), // 8pt header → group
            _buildGroup(
              surfaceColor: surfaceColor,
              children: [
                _buildToggleRow(
                  icon: CupertinoIcons.hand_draw,
                  iconColor: AppColors.accent,
                  label: 'Haptic Feedback',
                  labelColor: labelColor,
                  value: prefs.hapticsEnabled,
                  onChanged: (v) {
                    AppHaptics.selection();
                    ref.read(preferencesProvider.notifier).setHapticsEnabled(v);
                  },
                ),
                _buildSeparator(separatorColor),
                _buildToggleRow(
                  icon: CupertinoIcons.bell,
                  iconColor: AppColors.destructive,
                  label: 'Notifications',
                  labelColor: labelColor,
                  value: prefs.notificationsEnabled,
                  onChanged: (v) {
                    AppHaptics.selection();
                    ref
                        .read(preferencesProvider.notifier)
                        .setNotificationsEnabled(v);
                  },
                ),
              ],
            ),

            // ─── About ──────────────────────────────────────────
            const SizedBox(height: _md), // 24pt between groups
            _buildSectionHeader('ABOUT', secondaryColor),
            const SizedBox(height: _xs), // 8pt header → group
            _buildGroup(
              surfaceColor: surfaceColor,
              children: [
                _buildInfoRow(
                  label: 'App Name',
                  value: 'Countdowns',
                  labelColor: labelColor,
                  valueColor: secondaryColor,
                ),
                _buildSeparator(separatorColor),
                _buildInfoRow(
                  label: 'Version',
                  value: '1.0.0',
                  labelColor: labelColor,
                  valueColor: secondaryColor,
                ),
              ],
            ),

            // ─── Footer ─────────────────────────────────────────
            const SizedBox(height: _lg), // 32pt before footer
            Center(
              child: Column(
                children: [
                  Text(
                    'Version 1.0',
                    style: TextStyle(
                      fontFamily: '.SF Pro Display',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: secondaryColor.withValues(alpha: 0.45),
                    ),
                  ),
                  const SizedBox(height: _xs),
                  Text(
                    'Dara Newsome',
                    style: TextStyle(
                      fontFamily: '.SF Pro Display',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: secondaryColor.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: _md),
          ],
        ),
        ),
      ),
    );
  }

  // ─── Section Header ───────────────────────────────────────

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: _rowHPadding),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: '.SF Pro Display',
          fontSize: 13,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.4,
          color: color,
        ),
      ),
    );
  }

  // ─── Grouped Container ────────────────────────────────────

  Widget _buildGroup({
    required Color surfaceColor,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(_groupRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }

  // ─── Toggle Row (56pt target height) ──────────────────────

  Widget _buildToggleRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required Color labelColor,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _rowHPadding,
        vertical: _rowVPadding,
      ),
      child: Row(
        children: [
          Icon(icon, size: _iconSize, color: iconColor),
          const SizedBox(width: _iconLabelGap),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: '.SF Pro Display',
                fontSize: 17,
                fontWeight: FontWeight.w400,
                color: labelColor,
              ),
            ),
          ),
          CupertinoSwitch(
            value: value,
            activeTrackColor: const Color(0xFF34C759), // iOS system green
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  // ─── Info Row (56pt target height) ────────────────────────

  Widget _buildInfoRow({
    required String label,
    required String value,
    required Color labelColor,
    required Color valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _rowHPadding,
        vertical: _rowVPadding,
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: '.SF Pro Display',
              fontSize: 17,
              fontWeight: FontWeight.w400,
              color: labelColor,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontFamily: '.SF Pro Display',
              fontSize: 17,
              fontWeight: FontWeight.w400,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Separator ────────────────────────────────────────────

  Widget _buildSeparator(Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: _separatorInset),
      child: Container(
        height: 0.33,
        color: color.withValues(alpha: 0.12),
      ),
    );
  }
}
