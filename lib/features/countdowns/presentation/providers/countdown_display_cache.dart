import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/countdown.dart';
import 'countdown_providers.dart';
import 'countdown_state.dart';

/// Precomputed, cached display values for a countdown.
///
/// Instead of calling DateTime.now() on every widget build,
/// we compute these values at discrete points:
/// - On app open (initial load)
/// - At midnight (timer-based refresh)
/// - On app resume (lifecycle event)
///
/// This eliminates redundant date math during scrolling and
/// ensures all cards show consistent values within a frame.
class CountdownDisplayValues {
  final int daysRemaining;
  final String formattedCountdown;
  final bool isToday;
  final bool isPast;
  final DateTime effectiveDate;

  const CountdownDisplayValues({
    required this.daysRemaining,
    required this.formattedCountdown,
    required this.isToday,
    required this.isPast,
    required this.effectiveDate,
  });

  /// Snapshot the current computed values from a Countdown entity.
  factory CountdownDisplayValues.from(Countdown countdown) {
    return CountdownDisplayValues(
      daysRemaining: countdown.daysRemaining,
      formattedCountdown: countdown.formattedCountdown,
      isToday: countdown.isToday,
      isPast: countdown.isPast,
      effectiveDate: countdown.effectiveDate,
    );
  }
}

/// Provider that caches display values for all countdowns.
/// Recomputes when countdown data changes (via countdownsProvider dependency).
final countdownDisplayCacheProvider = StateNotifierProvider<
    CountdownDisplayCacheNotifier, Map<String, CountdownDisplayValues>>(
  (ref) {
    final notifier = CountdownDisplayCacheNotifier(ref);
    // Recompute whenever countdown state changes
    ref.listen(countdownsProvider, (prev, next) {
      notifier.recompute(next);
    });
    // Initial computation
    notifier.recompute(ref.read(countdownsProvider));
    return notifier;
  },
);

class CountdownDisplayCacheNotifier
    extends StateNotifier<Map<String, CountdownDisplayValues>> {
  final Ref _ref;
  Timer? _midnightTimer;

  CountdownDisplayCacheNotifier(this._ref) : super({}) {
    _scheduleMidnightRefresh();
  }

  /// Recompute display values from the current countdown state.
  void recompute(CountdownsState countdownState) {
    if (countdownState is! CountdownsLoaded) return;

    final cache = <String, CountdownDisplayValues>{};
    for (final countdown in countdownState.sections.upcoming) {
      cache[countdown.id] = CountdownDisplayValues.from(countdown);
    }
    for (final countdown in countdownState.sections.past) {
      cache[countdown.id] = CountdownDisplayValues.from(countdown);
    }
    state = cache;
  }

  /// Force a full refresh (called on app resume).
  void refresh() {
    recompute(_ref.read(countdownsProvider));
  }

  /// Schedule a refresh at midnight to roll over day counts.
  void _scheduleMidnightRefresh() {
    _midnightTimer?.cancel();
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    final duration = midnight.difference(now);

    _midnightTimer = Timer(duration, () {
      refresh();
      _scheduleMidnightRefresh(); // Schedule the next midnight
    });
  }

  @override
  void dispose() {
    _midnightTimer?.cancel();
    super.dispose();
  }
}

/// Mixin for widgets that need to refresh countdown display values
/// when the app resumes from background.
mixin CountdownLifecycleObserver<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  late final _LifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = _LifecycleListener(
      onResumed: () {
        ref.read(countdownDisplayCacheProvider.notifier).refresh();
      },
    );
    WidgetsBinding.instance.addObserver(_lifecycleListener);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_lifecycleListener);
    super.dispose();
  }
}

/// Lightweight lifecycle observer that only listens for app resume.
class _LifecycleListener extends WidgetsBindingObserver {
  final VoidCallback onResumed;

  _LifecycleListener({required this.onResumed});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      onResumed();
    }
  }
}
