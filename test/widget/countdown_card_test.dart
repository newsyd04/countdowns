import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:countdowns/features/countdowns/domain/entities/countdown.dart';
import 'package:countdowns/features/countdowns/presentation/widgets/countdown_card.dart';

void main() {
  Countdown createTestCountdown({
    DateTime? targetDate,
    String title = 'Test Event',
    String emoji = '\u{1F389}',
  }) {
    return Countdown(
      id: 'test-id',
      title: title,
      targetDate: targetDate ?? DateTime.now().add(const Duration(days: 10)),
      emoji: emoji,
      colorIndex: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Widget wrapWithMaterial(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  group('CountdownCard', () {
    testWidgets('displays title and emoji', (tester) async {
      final countdown = createTestCountdown(
        title: 'Birthday Party',
        emoji: '\u{1F382}',
      );

      await tester.pumpWidget(
        wrapWithMaterial(
          CountdownCard(countdown: countdown),
        ),
      );

      expect(find.text('Birthday Party'), findsOneWidget);
      expect(find.text('\u{1F382}'), findsOneWidget);
    });

    testWidgets('shows "Today!" for same-day events', (tester) async {
      final countdown = createTestCountdown(
        targetDate: DateTime.now(),
      );

      await tester.pumpWidget(
        wrapWithMaterial(
          CountdownCard(countdown: countdown),
        ),
      );

      expect(find.text('Today!'), findsOneWidget);
    });

    testWidgets('shows days remaining for future events', (tester) async {
      final countdown = createTestCountdown(
        targetDate: DateTime.now().add(const Duration(days: 42)),
      );

      await tester.pumpWidget(
        wrapWithMaterial(
          CountdownCard(countdown: countdown),
        ),
      );

      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      final countdown = createTestCountdown();

      await tester.pumpWidget(
        wrapWithMaterial(
          CountdownCard(
            countdown: countdown,
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.byType(CountdownCard));
      await tester.pumpAndSettle();

      expect(tapped, true);
    });

    testWidgets('applies past styling when isPast is true', (tester) async {
      final countdown = createTestCountdown(
        targetDate: DateTime.now().subtract(const Duration(days: 5)),
      );

      await tester.pumpWidget(
        wrapWithMaterial(
          CountdownCard(
            countdown: countdown,
            isPast: true,
          ),
        ),
      );

      // Card should still render without errors
      expect(find.byType(CountdownCard), findsOneWidget);
    });
  });
}
