import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'package:countdowns/features/countdowns/data/datasources/countdown_local_datasource.dart';
import 'package:countdowns/features/countdowns/presentation/pages/home_page.dart';
import 'package:countdowns/features/countdowns/presentation/providers/countdown_providers.dart';
import 'package:countdowns/features/countdowns/presentation/widgets/empty_state_widget.dart';
import 'package:countdowns/core/theme/app_theme.dart';

void main() {
  late CountdownLocalDataSource dataSource;

  setUp(() async {
    // Initialize Hive with a temp directory for testing
    Hive.init('/tmp/hive_test_${DateTime.now().millisecondsSinceEpoch}');
    dataSource = CountdownLocalDataSource();
    await dataSource.init();
  });

  tearDown(() async {
    await dataSource.dispose();
    await Hive.deleteFromDisk();
  });

  Widget createTestApp() {
    return ProviderScope(
      overrides: [
        countdownDataSourceProvider.overrideWithValue(dataSource),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        home: const HomePage(),
      ),
    );
  }

  group('App Integration', () {
    testWidgets('shows empty state when no countdowns exist', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      expect(find.byType(EmptyStateWidget), findsOneWidget);
      expect(find.text('No Countdowns Yet'), findsOneWidget);
    });

    testWidgets('navigates to create page from empty state', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create Your First Countdown'));
      await tester.pumpAndSettle();

      expect(find.text('New Countdown'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('can create a countdown and see it on home', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Tap create button
      await tester.tap(find.text('Create Your First Countdown'));
      await tester.pumpAndSettle();

      // Enter a title
      await tester.enterText(
        find.byType(EditableText).first,
        'Christmas',
      );
      await tester.pumpAndSettle();

      // Tap Add
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Should be back on home with the countdown visible
      expect(find.text('Christmas'), findsOneWidget);
    });
  });
}
