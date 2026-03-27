import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/date_utils.dart';
import '../entities/countdown.dart';
import '../repositories/countdown_repository.dart';

const _uuid = Uuid();

/// Use case: Get all countdowns split into upcoming and past sections.
class GetCountdownsUseCase {
  final CountdownRepository _repository;

  GetCountdownsUseCase(this._repository);

  Future<CountdownSections> call() async {
    final all = await _repository.getAll();
    final upcoming = <Countdown>[];
    final past = <Countdown>[];

    for (final countdown in all) {
      if (countdown.isPast) {
        past.add(countdown);
      } else {
        upcoming.add(countdown);
      }
    }

    // Sort upcoming: soonest first (by effective date)
    upcoming.sort((a, b) => a.effectiveDate.compareTo(b.effectiveDate));

    // Sort past: most recently passed first
    past.sort((a, b) => b.targetDate.compareTo(a.targetDate));

    return CountdownSections(upcoming: upcoming, past: past);
  }
}

/// Use case: Create a new countdown with smart defaults.
class CreateCountdownUseCase {
  final CountdownRepository _repository;

  CreateCountdownUseCase(this._repository);

  Future<Countdown> call({
    required String title,
    required DateTime targetDate,
    String? emoji,
    int? colorIndex,
    RecurrenceType recurrence = RecurrenceType.none,
    bool notificationsEnabled = true,
    List<int>? notificationOffsets,
  }) async {
    final now = DateTime.now();

    final countdown = Countdown(
      id: _uuid.v4(),
      title: title.trim(),
      targetDate: targetDate,
      emoji: emoji ?? AppConstants.defaultEmoji,
      colorIndex: colorIndex ?? 0,
      recurrence: recurrence,
      notificationsEnabled: notificationsEnabled,
      notificationOffsets:
          notificationOffsets ?? AppConstants.defaultNotificationOffsets,
      sortOrder: 0, // Will be set based on existing items
      createdAt: now,
      updatedAt: now,
    );

    return _repository.create(countdown);
  }
}

/// Use case: Update an existing countdown.
class UpdateCountdownUseCase {
  final CountdownRepository _repository;

  UpdateCountdownUseCase(this._repository);

  Future<Countdown> call(Countdown countdown) async {
    final updated = countdown.copyWith(updatedAt: DateTime.now());
    return _repository.update(updated);
  }
}

/// Use case: Delete a countdown.
class DeleteCountdownUseCase {
  final CountdownRepository _repository;

  DeleteCountdownUseCase(this._repository);

  Future<void> call(String id) async {
    return _repository.delete(id);
  }
}

/// Use case: Reorder countdowns.
class ReorderCountdownsUseCase {
  final CountdownRepository _repository;

  ReorderCountdownsUseCase(this._repository);

  Future<void> call(List<String> orderedIds) async {
    return _repository.reorder(orderedIds);
  }
}

/// Use case: Suggest a smart date if the selected date is in the past.
class SuggestDateUseCase {
  DateSuggestion call(DateTime selectedDate) {
    if (CountdownDateUtils.hasSuggestion(selectedDate)) {
      final suggested = CountdownDateUtils.suggestSmartDate(selectedDate);
      return DateSuggestion(
        originalDate: selectedDate,
        suggestedDate: suggested,
        hasSuggestion: true,
        message: 'Did you mean next year?',
      );
    }
    return DateSuggestion(
      originalDate: selectedDate,
      suggestedDate: selectedDate,
      hasSuggestion: false,
    );
  }
}

/// Grouped countdowns for display.
class CountdownSections {
  final List<Countdown> upcoming;
  final List<Countdown> past;

  const CountdownSections({
    required this.upcoming,
    required this.past,
  });

  int get totalCount => upcoming.length + past.length;
  bool get isEmpty => upcoming.isEmpty && past.isEmpty;
}

/// Result of a smart date suggestion.
class DateSuggestion {
  final DateTime originalDate;
  final DateTime suggestedDate;
  final bool hasSuggestion;
  final String? message;

  const DateSuggestion({
    required this.originalDate,
    required this.suggestedDate,
    required this.hasSuggestion,
    this.message,
  });
}
