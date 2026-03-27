import 'package:flutter_test/flutter_test.dart';
import 'package:countdowns/core/utils/date_utils.dart';
import 'package:countdowns/features/countdowns/domain/entities/countdown.dart';

void main() {
  group('Countdown entity', () {
    Countdown createCountdown({
      DateTime? targetDate,
      RecurrenceType recurrence = RecurrenceType.none,
    }) {
      return Countdown(
        id: 'test-id',
        title: 'Test Event',
        targetDate: targetDate ?? DateTime.now().add(const Duration(days: 10)),
        emoji: '\u{1F389}',
        colorIndex: 0,
        recurrence: recurrence,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    test('daysUntil returns correct value for future date', () {
      final countdown = createCountdown(
        targetDate: DateTime.now().add(const Duration(days: 10)),
      );
      expect(countdown.daysUntil, 10);
    });

    test('isPast returns true for past non-recurring events', () {
      final countdown = createCountdown(
        targetDate: DateTime.now().subtract(const Duration(days: 5)),
      );
      expect(countdown.isPast, true);
    });

    test('isPast returns false for recurring events even if date is past', () {
      final countdown = createCountdown(
        targetDate: DateTime.now().subtract(const Duration(days: 5)),
        recurrence: RecurrenceType.yearly,
      );
      expect(countdown.isPast, false);
    });

    test('effectiveDate returns next occurrence for recurring events', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 5));
      final countdown = createCountdown(
        targetDate: pastDate,
        recurrence: RecurrenceType.yearly,
      );
      expect(countdown.effectiveDate.isAfter(DateTime.now()), true);
    });

    test('isToday returns true when target is today', () {
      final countdown = createCountdown(
        targetDate: DateTime.now(),
      );
      expect(countdown.isToday, true);
    });

    test('copyWith creates a new instance with updated fields', () {
      final original = createCountdown();
      final updated = original.copyWith(title: 'Updated Title');
      expect(updated.title, 'Updated Title');
      expect(updated.id, original.id);
      expect(updated.emoji, original.emoji);
    });

    test('equality is based on id', () {
      final a = createCountdown();
      final b = a.copyWith(title: 'Different title');
      expect(a, equals(b));
    });

    test('formattedCountdown returns human-readable string', () {
      final countdown = createCountdown(
        targetDate: DateTime.now(),
      );
      expect(countdown.formattedCountdown, 'Today');
    });
  });
}
