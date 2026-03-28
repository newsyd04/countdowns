import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/countdown_local_datasource.dart';
import '../../data/repositories/countdown_repository_impl.dart';
import '../../domain/entities/countdown.dart';
import '../../domain/repositories/countdown_repository.dart';
import '../../domain/usecases/countdown_usecases.dart';
import '../../../../core/utils/date_utils.dart';
import '../../services/notification_service.dart';
import 'countdown_state.dart';

// ─── Data Source & Repository ───────────────────────────────

/// Singleton data source provider (initialized at app startup).
final countdownDataSourceProvider = Provider<CountdownLocalDataSource>((ref) {
  throw UnimplementedError(
    'countdownDataSourceProvider must be overridden at app startup',
  );
});

/// Repository provider wired to the data source.
final countdownRepositoryProvider = Provider<CountdownRepository>((ref) {
  final dataSource = ref.watch(countdownDataSourceProvider);
  return CountdownRepositoryImpl(dataSource);
});

// ─── Use Cases ──────────────────────────────────────────────

final getCountdownsUseCaseProvider = Provider<GetCountdownsUseCase>((ref) {
  return GetCountdownsUseCase(ref.watch(countdownRepositoryProvider));
});

final createCountdownUseCaseProvider = Provider<CreateCountdownUseCase>((ref) {
  return CreateCountdownUseCase(ref.watch(countdownRepositoryProvider));
});

final updateCountdownUseCaseProvider = Provider<UpdateCountdownUseCase>((ref) {
  return UpdateCountdownUseCase(ref.watch(countdownRepositoryProvider));
});

final deleteCountdownUseCaseProvider = Provider<DeleteCountdownUseCase>((ref) {
  return DeleteCountdownUseCase(ref.watch(countdownRepositoryProvider));
});

final reorderCountdownsUseCaseProvider =
    Provider<ReorderCountdownsUseCase>((ref) {
  return ReorderCountdownsUseCase(ref.watch(countdownRepositoryProvider));
});

final suggestDateUseCaseProvider = Provider<SuggestDateUseCase>((ref) {
  return SuggestDateUseCase();
});

// ─── Main State Notifier ────────────────────────────────────

final countdownsProvider =
    StateNotifierProvider<CountdownsNotifier, CountdownsState>((ref) {
  return CountdownsNotifier(
    getCountdowns: ref.watch(getCountdownsUseCaseProvider),
    createCountdown: ref.watch(createCountdownUseCaseProvider),
    updateCountdown: ref.watch(updateCountdownUseCaseProvider),
    deleteCountdown: ref.watch(deleteCountdownUseCaseProvider),
    reorderCountdowns: ref.watch(reorderCountdownsUseCaseProvider),
    notificationService: NotificationService(),
    globalNotificationsEnabled: true,
  );
});

class CountdownsNotifier extends StateNotifier<CountdownsState> {
  final GetCountdownsUseCase _getCountdowns;
  final CreateCountdownUseCase _createCountdown;
  final UpdateCountdownUseCase _updateCountdown;
  final DeleteCountdownUseCase _deleteCountdown;
  final ReorderCountdownsUseCase _reorderCountdowns;
  final NotificationService _notificationService;
  final bool _globalNotificationsEnabled;

  Countdown? _lastDeleted;

  CountdownsNotifier({
    required GetCountdownsUseCase getCountdowns,
    required CreateCountdownUseCase createCountdown,
    required UpdateCountdownUseCase updateCountdown,
    required DeleteCountdownUseCase deleteCountdown,
    required ReorderCountdownsUseCase reorderCountdowns,
    required NotificationService notificationService,
    required bool globalNotificationsEnabled,
  })  : _getCountdowns = getCountdowns,
        _createCountdown = createCountdown,
        _updateCountdown = updateCountdown,
        _deleteCountdown = deleteCountdown,
        _reorderCountdowns = reorderCountdowns,
        _notificationService = notificationService,
        _globalNotificationsEnabled = globalNotificationsEnabled,
        super(const CountdownsState.loading()) {
    loadCountdowns();
  }

  /// Load all countdowns from storage.
  Future<void> loadCountdowns() async {
    try {
      state = const CountdownsState.loading();
      final sections = await _getCountdowns();
      state = CountdownsState.loaded(sections: sections);
    } catch (e) {
      state = CountdownsState.error(e.toString());
    }
  }

  /// Create a new countdown and schedule notifications.
  Future<Countdown?> create({
    required String title,
    required DateTime targetDate,
    String? emoji,
    int? colorIndex,
    RecurrenceType recurrence = RecurrenceType.none,
    bool notificationsEnabled = true,
    List<int>? notificationOffsets,
  }) async {
    try {
      final countdown = await _createCountdown(
        title: title,
        targetDate: targetDate,
        emoji: emoji,
        colorIndex: colorIndex,
        recurrence: recurrence,
        notificationsEnabled: notificationsEnabled,
        notificationOffsets: notificationOffsets,
      );

      // Schedule notifications for the new countdown
      if (_globalNotificationsEnabled) {
        await _notificationService.scheduleForCountdown(countdown);
      } else {
        await _notificationService.cancelForCountdown(countdown.id);
      }

      await loadCountdowns();
      return countdown;
    } catch (e) {
      state = CountdownsState.error(e.toString());
      return null;
    }
  }

  /// Update a countdown and reschedule its notifications.
  Future<void> update(Countdown countdown) async {
    try {
      await _updateCountdown(countdown);

      // Reschedule notifications (cancels old, schedules new)
      if (_globalNotificationsEnabled) {
        await _notificationService.scheduleForCountdown(countdown);
      } else {
        await _notificationService.cancelForCountdown(countdown.id);
      }

      await loadCountdowns();
    } catch (e) {
      state = CountdownsState.error(e.toString());
    }
  }

  /// Delete a countdown, cancel its notifications, support undo.
  Future<void> delete(String id) async {
    final currentState = state;
    if (currentState is CountdownsLoaded) {
      _lastDeleted = [
        ...currentState.sections.upcoming,
        ...currentState.sections.past,
      ].where((c) => c.id == id).firstOrNull;
    }

    try {
      // Cancel notifications before deleting
      await _notificationService.cancelForCountdown(id);

      await _deleteCountdown(id);
      await loadCountdowns();
    } catch (e) {
      state = CountdownsState.error(e.toString());
    }
  }

  /// Undo the last delete — recreate and reschedule notifications.
  Future<bool> undoDelete() async {
    if (_lastDeleted == null) return false;

    try {
      final restored = await _createCountdown(
        title: _lastDeleted!.title,
        targetDate: _lastDeleted!.targetDate,
        emoji: _lastDeleted!.emoji,
        colorIndex: _lastDeleted!.colorIndex,
        recurrence: _lastDeleted!.recurrence,
        notificationsEnabled: _lastDeleted!.notificationsEnabled,
        notificationOffsets: _lastDeleted!.notificationOffsets,
      );

      // Reschedule notifications for the restored countdown
      if (_globalNotificationsEnabled) {
        await _notificationService.scheduleForCountdown(restored);
      } else {
        await _notificationService.cancelForCountdown(restored.id);
      }

      _lastDeleted = null;
      await loadCountdowns();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Reorder countdowns (drag and drop).
  Future<void> reorder(int oldIndex, int newIndex) async {
    final currentState = state;
    if (currentState is! CountdownsLoaded) return;

    final upcoming = List<Countdown>.from(currentState.sections.upcoming);
    if (oldIndex < 0 || oldIndex >= upcoming.length) return;
    if (newIndex < 0 || newIndex > upcoming.length) return;

    final item = upcoming.removeAt(oldIndex);
    final adjustedIndex = newIndex > oldIndex ? newIndex - 1 : newIndex;
    upcoming.insert(adjustedIndex, item);

    // Optimistic update
    state = CountdownsState.loaded(
      sections: CountdownSections(
        upcoming: upcoming,
        past: currentState.sections.past,
      ),
    );

    // Persist
    final orderedIds = upcoming.map((c) => c.id).toList();
    await _reorderCountdowns(orderedIds);
  }
}
