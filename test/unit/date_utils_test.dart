import 'package:flutter_test/flutter_test.dart';
import 'package:countdowns/core/utils/date_utils.dart';

void main() {
  group('CountdownDateUtils', () {
    group('daysUntil', () {
      test('returns 0 for today', () {
        final today = DateTime.now();
        expect(CountdownDateUtils.daysUntil(today), 0);
      });

      test('returns positive for future dates', () {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        expect(CountdownDateUtils.daysUntil(tomorrow), 1);
      });

      test('returns negative for past dates', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        expect(CountdownDateUtils.daysUntil(yesterday), -1);
      });

      test('handles large day counts', () {
        final farFuture = DateTime.now().add(const Duration(days: 365));
        expect(CountdownDateUtils.daysUntil(farFuture), 365);
      });
    });

    group('formatCountdown', () {
      test('returns "Today" for today', () {
        final today = DateTime.now();
        expect(CountdownDateUtils.formatCountdown(today), 'Today');
      });

      test('returns "Tomorrow" for tomorrow', () {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        expect(CountdownDateUtils.formatCountdown(tomorrow), 'Tomorrow');
      });

      test('returns "Yesterday" for yesterday', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        expect(CountdownDateUtils.formatCountdown(yesterday), 'Yesterday');
      });

      test('returns days for near future', () {
        final inFiveDays = DateTime.now().add(const Duration(days: 5));
        expect(CountdownDateUtils.formatCountdown(inFiveDays), '5 days');
      });

      test('returns weeks for 7-29 days', () {
        final inTwoWeeks = DateTime.now().add(const Duration(days: 14));
        expect(CountdownDateUtils.formatCountdown(inTwoWeeks), '2 weeks');
      });

      test('returns months for 30-364 days', () {
        final inTwoMonths = DateTime.now().add(const Duration(days: 60));
        expect(CountdownDateUtils.formatCountdown(inTwoMonths), '2 months');
      });

      test('returns years for 365+ days', () {
        final inTwoYears = DateTime.now().add(const Duration(days: 730));
        expect(CountdownDateUtils.formatCountdown(inTwoYears), '2 years');
      });

      test('handles past dates with "ago" suffix', () {
        final fiveDaysAgo = DateTime.now().subtract(const Duration(days: 5));
        expect(
          CountdownDateUtils.formatCountdown(fiveDaysAgo),
          '5 days ago',
        );
      });
    });

    group('isToday', () {
      test('returns true for today', () {
        expect(CountdownDateUtils.isToday(DateTime.now()), true);
      });

      test('returns false for tomorrow', () {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        expect(CountdownDateUtils.isToday(tomorrow), false);
      });
    });

    group('nextOccurrence', () {
      test('returns original date for non-recurring', () {
        final date = DateTime(2025, 6, 15);
        final result = CountdownDateUtils.nextOccurrence(
          date,
          RecurrenceType.none,
        );
        expect(result, date);
      });

      test('yearly recurrence finds next year if past', () {
        final now = DateTime.now();
        final pastThisYear = DateTime(now.year, 1, 1);
        final result = CountdownDateUtils.nextOccurrence(
          pastThisYear,
          RecurrenceType.yearly,
        );
        expect(result.year, now.year + 1);
        expect(result.month, 1);
        expect(result.day, 1);
      });

      test('handles leap year dates gracefully', () {
        // Feb 29 should clamp to Feb 28 in non-leap years
        final leapDate = DateTime(2024, 2, 29);
        final result = CountdownDateUtils.nextOccurrence(
          leapDate,
          RecurrenceType.yearly,
        );
        // Should be valid (either Feb 28 or 29 depending on year)
        expect(result.month, 2);
        expect(result.day, lessThanOrEqualTo(29));
      });
    });

    group('suggestSmartDate', () {
      test('suggests next year for past dates', () {
        final pastDate = DateTime.now().subtract(const Duration(days: 30));
        final suggested = CountdownDateUtils.suggestSmartDate(pastDate);
        expect(suggested.year, pastDate.year + 1);
      });

      test('returns same date for future dates', () {
        final futureDate = DateTime.now().add(const Duration(days: 30));
        final suggested = CountdownDateUtils.suggestSmartDate(futureDate);
        expect(suggested, futureDate);
      });
    });
  });
}
