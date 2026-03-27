import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/performance/performance_tier.dart';
import '../../../../core/theme/app_animations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../domain/entities/countdown.dart';
import '../../domain/usecases/countdown_usecases.dart';
import '../providers/countdown_display_cache.dart';
import '../providers/countdown_providers.dart';
import '../providers/countdown_state.dart';
import '../widgets/collapsing_nav_bar.dart';
import '../widgets/countdown_card.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/parallax_card_wrapper.dart';
import '../../../settings/settings_page.dart';
import 'create_countdown_page.dart';

/// The main home screen showing all countdowns.
///
/// Navigation follows Apple HIG:
/// - CupertinoSliverNavigationBar with large title that collapses on scroll
/// - Top-right "+" button for primary action (no FAB)
/// - Frosted glass blur on collapsed nav bar
/// - Separator appears only when content scrolls underneath
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with TickerProviderStateMixin, CountdownLifecycleObserver {
  final ScrollController _scrollController = ScrollController();
  bool _showPastEvents = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showSettings() {
    AppHaptics.light();
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => const SettingsPage(),
      ),
    );
  }

  void _showCreateSheet() {
    AppHaptics.light();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const CreateCountdownPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final tween = Tween(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).chain(CurveTween(curve: AppAnimations.defaultCurve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: AppAnimations.slow,
        reverseTransitionDuration: AppAnimations.normal,
        fullscreenDialog: true,
      ),
    );
  }

  void _showEditSheet(Countdown countdown) {
    AppHaptics.light();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            CreateCountdownPage(existingCountdown: countdown),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final tween = Tween(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).chain(CurveTween(curve: AppAnimations.defaultCurve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: AppAnimations.slow,
        reverseTransitionDuration: AppAnimations.normal,
        fullscreenDialog: true,
      ),
    );
  }

  Future<void> _deleteCountdown(Countdown countdown) async {
    AppHaptics.medium();
    await ref.read(countdownsProvider.notifier).delete(countdown.id);

    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '"${countdown.title}" deleted',
          style: const TextStyle(color: Colors.white),
        ),
        action: SnackBarAction(
          label: 'Undo',
          textColor: AppColors.accent,
          onPressed: () async {
            await ref.read(countdownsProvider.notifier).undoDelete();
            AppHaptics.success();
          },
        ),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppSpacing.lg),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
        ),
        backgroundColor: context.isDark
            ? AppColors.surfaceElevatedDark
            : const Color(0xFF2C2C2E),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(countdownsProvider);
    final displayCache = ref.watch(countdownDisplayCacheProvider);
    final isDark = context.isDark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundPrimaryDark
          : AppColors.backgroundPrimary,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          // ─── Collapsing Nav Bar ────────────────────────────────
          CollapsingNavBarSliver(
            title: 'Countdowns',
            onAddPressed: _showCreateSheet,
            onSettingsPressed: _showSettings,
            isDark: isDark,
          ),

          // ─── Pull to Refresh ────────────────────────────────
          CupertinoSliverRefreshControl(
            onRefresh: () async {
              AppHaptics.light();
              await ref.read(countdownsProvider.notifier).loadCountdowns();
            },
          ),

          // ─── Content ────────────────────────────────────────
          state.when(
            loading: () => const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: CupertinoActivityIndicator(radius: 14),
              ),
            ),
            error: (message) => SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CupertinoIcons.exclamationmark_circle,
                      size: 48,
                      color: isDark
                          ? AppColors.labelTertiaryDark
                          : AppColors.labelTertiary,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Something went wrong',
                      style: AppTypography.headline.copyWith(
                        color: isDark
                            ? AppColors.labelPrimaryDark
                            : AppColors.labelPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      message,
                      style: AppTypography.footnote,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            loaded: (sections) => sections.isEmpty
                ? SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyStateWidget(
                      onCreateTap: _showCreateSheet,
                    ),
                  )
                : _buildCountdownList(sections, displayCache),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownList(
    CountdownSections sections,
    Map<String, CountdownDisplayValues> displayCache,
  ) {
    final caps = ref.watch(performanceCapsProvider);

    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          // ─── Upcoming Section ─────────────────────────────
          if (sections.upcoming.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            _SectionHeader(
              title: 'Upcoming',
              count: sections.upcoming.length,
            ),
            const SizedBox(height: AppSpacing.md),
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              proxyDecorator: (child, index, animation) {
                return AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    final scale = Tween<double>(
                      begin: 1.0,
                      end: AppAnimations.dragLiftScale,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: AppAnimations.defaultCurve,
                    ));
                    return Transform.scale(
                      scale: scale.value,
                      child: Material(
                        elevation: 8 * caps.shadowMultiplier,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.cardRadius),
                        color: Colors.transparent,
                        child: child,
                      ),
                    );
                  },
                  child: child,
                );
              },
              onReorder: (oldIndex, newIndex) {
                AppHaptics.medium();
                ref
                    .read(countdownsProvider.notifier)
                    .reorder(oldIndex, newIndex);
              },
              itemCount: sections.upcoming.length,
              itemBuilder: (context, index) {
                final countdown = sections.upcoming[index];
                final card = CountdownCard(
                  countdown: countdown,
                  displayValues: displayCache[countdown.id],
                  onTap: () => _showEditSheet(countdown),
                  onEdit: () => _showEditSheet(countdown),
                  onDelete: () => _deleteCountdown(countdown),
                );
                return RepaintBoundary(
                  key: ValueKey(countdown.id),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      bottom: AppSpacing.listItemSpacing,
                    ),
                    child: ReorderableDragStartListener(
                      index: index,
                      child: ParallaxCardWrapper(
                        scrollController: _scrollController,
                        shadowMultiplier: caps.shadowMultiplier,
                        child: card,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],

          // ─── Past Section ─────────────────────────────────
          if (sections.past.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            GestureDetector(
              onTap: () {
                AppHaptics.selection();
                setState(() => _showPastEvents = !_showPastEvents);
              },
              child: _SectionHeader(
                title: 'Past Events',
                count: sections.past.length,
                isCollapsible: true,
                isExpanded: _showPastEvents,
              ),
            ),
            if (_showPastEvents) ...[
              const SizedBox(height: AppSpacing.md),
              ...sections.past.map(
                (countdown) {
                  final card = CountdownCard(
                    countdown: countdown,
                    displayValues: displayCache[countdown.id],
                    isPast: true,
                    onTap: () => _showEditSheet(countdown),
                    onEdit: () => _showEditSheet(countdown),
                    onDelete: () => _deleteCountdown(countdown),
                  );
                  return RepaintBoundary(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppSpacing.listItemSpacing,
                      ),
                      child: ParallaxCardWrapper(
                        scrollController: _scrollController,
                        shadowMultiplier: caps.shadowMultiplier,
                        child: card,
                      ),
                    ),
                  );
                },
              ),
            ],
          ],

          // Bottom padding for safe area
          const SizedBox(height: AppSpacing.huge),
        ]),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final bool isCollapsible;
  final bool isExpanded;

  const _SectionHeader({
    required this.title,
    required this.count,
    this.isCollapsible = false,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Text(
          title,
          style: AppTypography.title3Semibold.copyWith(
            color: isDark ? AppColors.labelPrimaryDark : AppColors.labelPrimary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xxs,
          ),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.surfaceSecondaryDark
                : AppColors.surfaceSecondary,
            borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
          ),
          child: Text(
            '$count',
            style: AppTypography.caption1.copyWith(
              color: isDark
                  ? AppColors.labelSecondaryDark
                  : AppColors.labelSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Spacer(),
        if (isCollapsible)
          AnimatedRotation(
            turns: isExpanded ? 0.25 : 0,
            duration: AppAnimations.fast,
            curve: AppAnimations.defaultCurve,
            child: Icon(
              CupertinoIcons.chevron_right,
              size: 16,
              color: isDark
                  ? AppColors.labelTertiaryDark
                  : AppColors.labelTertiary,
            ),
          ),
      ],
    );
  }
}
