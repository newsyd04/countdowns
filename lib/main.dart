import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/haptic_utils.dart';
import 'features/countdowns/data/datasources/countdown_local_datasource.dart';
import 'features/countdowns/presentation/pages/home_page.dart';
import 'features/countdowns/presentation/providers/countdown_providers.dart';
import 'features/countdowns/services/notification_service.dart';
import 'features/settings/settings_provider.dart';

/// Notification service provider — singleton, initialized in main().
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait on phones (allow landscape on tablets)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarBrightness: Brightness.light,
  ));

  // Initialize Hive
  await Hive.initFlutter();

  // Initialize countdown data source (opens + registers adapters)
  final dataSource = CountdownLocalDataSource();
  await dataSource.init();

  // Open settings box (synchronous read after this point)
  final settingsBox = await Hive.openBox(AppConstants.hiveSettingsBoxName);

  // Initialize notifications
  final notificationService = NotificationService();
  await notificationService.init();

  runApp(
    ProviderScope(
      overrides: [
        countdownDataSourceProvider.overrideWithValue(dataSource),
        settingsBoxProvider.overrideWithValue(settingsBox),
      ],
      child: const CountdownsApp(),
    ),
  );
}

/// Root application widget.
/// Watches preferences to apply theme mode.
class CountdownsApp extends ConsumerWidget {
  const CountdownsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(preferencesProvider);
    AppHaptics.setEnabled(prefs.hapticsEnabled);

    final themeModeStr = prefs.themeMode;
    final themeMode = themeModeStr == 'light' ? ThemeMode.light
        : themeModeStr == 'dark' ? ThemeMode.dark
        : ThemeMode.system;

    return MaterialApp(
      title: 'Countdowns',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      scrollBehavior: const _AppleScrollBehavior(),
      home: const HomePage(),
    );
  }
}

/// Custom scroll behavior — BouncingScrollPhysics everywhere (iOS-like).
class _AppleScrollBehavior extends ScrollBehavior {
  const _AppleScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(
      parent: AlwaysScrollableScrollPhysics(),
    );
  }
}
