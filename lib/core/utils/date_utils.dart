/// Date calculation utilities for countdowns.
///
/// Handles edge cases: leap years, timezone changes, past dates,
/// same-day events, and recurring event next-occurrence calculations.
class CountdownDateUtils {
  CountdownDateUtils._();

  /// Returns the number of days between now and the target date.
  /// Positive = future, negative = past, zero = today.
  static int daysUntil(DateTime target) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDay = DateTime(target.year, target.month, target.day);
    return targetDay.difference(today).inDays;
  }

  /// Returns a human-readable string for the countdown.
  static String formatCountdown(DateTime target) {
    final days = daysUntil(target);

    if (days == 0) return 'Today';
    if (days == 1) return 'Tomorrow';
    if (days == -1) return 'Yesterday';

    if (days > 0) {
      if (days < 7) return '$days days';
      if (days < 30) {
        final weeks = days ~/ 7;
        return weeks == 1 ? '1 week' : '$weeks weeks';
      }
      if (days < 365) {
        final months = days ~/ 30;
        return months == 1 ? '1 month' : '$months months';
      }
      final years = days ~/ 365;
      return years == 1 ? '1 year' : '$years years';
    }

    // Past dates
    final absDays = days.abs();
    if (absDays < 7) return '$absDays days ago';
    if (absDays < 30) {
      final weeks = absDays ~/ 7;
      return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
    }
    if (absDays < 365) {
      final months = absDays ~/ 30;
      return months == 1 ? '1 month ago' : '$months months ago';
    }
    final years = absDays ~/ 365;
    return years == 1 ? '1 year ago' : '$years years ago';
  }

  /// Returns precise days remaining (always absolute number for display).
  static int daysRemaining(DateTime target) {
    return daysUntil(target).abs();
  }

  /// Whether the target date is in the past (excluding today).
  static bool isPast(DateTime target) {
    return daysUntil(target) < 0;
  }

  /// Whether the target date is today.
  static bool isToday(DateTime target) {
    return daysUntil(target) == 0;
  }

  /// Whether the target date is in the future (excluding today).
  static bool isFuture(DateTime target) {
    return daysUntil(target) > 0;
  }

  /// Calculates the next occurrence of a recurring event.
  /// For yearly recurrence: finds the next birthday/anniversary.
  /// For monthly recurrence: finds the next monthly occurrence.
  static DateTime nextOccurrence(
    DateTime originalDate,
    RecurrenceType recurrence,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (recurrence) {
      case RecurrenceType.none:
        return originalDate;

      case RecurrenceType.yearly:
        var next = DateTime(
          today.year,
          originalDate.month,
          _clampDay(originalDate.day, today.year, originalDate.month),
        );
        if (next.isBefore(today) || next.isAtSameMomentAs(today)) {
          next = DateTime(
            today.year + 1,
            originalDate.month,
            _clampDay(originalDate.day, today.year + 1, originalDate.month),
          );
        }
        return next;

      case RecurrenceType.monthly:
        var next = DateTime(
          today.year,
          today.month,
          _clampDay(originalDate.day, today.year, today.month),
        );
        if (next.isBefore(today) || next.isAtSameMomentAs(today)) {
          final nextMonth = today.month == 12 ? 1 : today.month + 1;
          final nextYear = today.month == 12 ? today.year + 1 : today.year;
          next = DateTime(
            nextYear,
            nextMonth,
            _clampDay(originalDate.day, nextYear, nextMonth),
          );
        }
        return next;

      case RecurrenceType.weekly:
        var next = today.add(
          Duration(days: (originalDate.weekday - today.weekday) % 7),
        );
        if (next.isBefore(today) || next.isAtSameMomentAs(today)) {
          next = next.add(const Duration(days: 7));
        }
        return next;
    }
  }

  /// Smart date suggestion: if a user picks a date that's already
  /// passed this year, suggest next year's date instead.
  static DateTime suggestSmartDate(DateTime selectedDate) {
    if (isPast(selectedDate)) {
      // Suggest the same date next year
      return DateTime(
        selectedDate.year + 1,
        selectedDate.month,
        _clampDay(selectedDate.day, selectedDate.year + 1, selectedDate.month),
      );
    }
    return selectedDate;
  }

  /// Whether a smart date suggestion is available.
  static bool hasSuggestion(DateTime selectedDate) {
    return isPast(selectedDate);
  }

  /// Clamp day to valid range for the given month/year (handles Feb 29, etc.).
  static int _clampDay(int day, int year, int month) {
    final maxDay = DateTime(year, month + 1, 0).day;
    return day > maxDay ? maxDay : day;
  }
}

/// Recurrence pattern for countdowns.
enum RecurrenceType {
  none,
  weekly,
  monthly,
  yearly;

  String get displayName {
    switch (this) {
      case RecurrenceType.none:
        return 'Never';
      case RecurrenceType.weekly:
        return 'Every week';
      case RecurrenceType.monthly:
        return 'Every month';
      case RecurrenceType.yearly:
        return 'Every year';
    }
  }
}
