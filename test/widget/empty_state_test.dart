import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:countdowns/features/countdowns/presentation/widgets/empty_state_widget.dart';

void main() {
  group('EmptyStateWidget', () {
    testWidgets('displays title and subtitle', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(),
          ),
        ),
      );

      expect(find.text('No Countdowns Yet'), findsOneWidget);
      expect(
        find.textContaining('Start counting down'),
        findsOneWidget,
      );
    });

    testWidgets('displays create button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(),
          ),
        ),
      );

      expect(find.text('Create Your First Countdown'), findsOneWidget);
    });

    testWidgets('calls onCreateTap when button is tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              onCreateTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Create Your First Countdown'));
      await tester.pumpAndSettle();

      expect(tapped, true);
    });
  });
}
