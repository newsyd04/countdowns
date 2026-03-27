import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';

import 'package:countdowns/features/countdowns/data/datasources/countdown_local_datasource.dart';
import 'package:countdowns/features/countdowns/presentation/pages/home_page.dart';
import 'package:countdowns/features/countdowns/presentation/providers/countdown_providers.dart';
import 'package:countdowns/features/countdowns/presentation/widgets/empty_state_widget.dart';
import 'package:countdowns/features/settings/settings_provider.dart';
import 'package:countdowns/core/theme/app_theme.dart';

void main() {
  late CountdownLocalDataSource dataSource;
  late Box settingsBox;

  setUp(() async {
    final dir = '/tmp/hive_test_${DateTime.now().millisecondsSinceEpoch}';
    Hive.init(dir);
    dataSource = CountdownLocalDataSource();
    await dataSource.init();
    settingsBox = await Hive.openBox('settings_box');
  });

  tearDown(() async {
    await dataSource.dispose();
    await settingsBox.close();
    await Hive.deleteFromDisk();
  });

  Widget createTestApp() {
    return ProviderScope(
      overrides: [
        countdownDataSourceProvider.overrideWithValue(dataSource),
        settingsBoxProvider.overrideWithValue(settingsBox),
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
      // Use pump with duration instead of pumpAndSettle (looping animations)
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(EmptyStateWidget), findsOneWidget);
    });

    testWidgets('navigates to create page from empty state', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.text('Create Your First Countdown'));
      // Pump multiple frames to advance the route transition
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(find.text('New Countdown'), findsOneWidget);
    });
  });
}
