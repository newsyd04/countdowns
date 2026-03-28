import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive_ce.dart';

/// Persisted user preferences backed by a pre-opened Hive box.
class AppPreferences {
  final String themeMode;

  const AppPreferences({
    this.themeMode = 'system',
  });

  AppPreferences copyWith({
    String? themeMode,
  }) {
    return AppPreferences(
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

/// Provider for the pre-opened settings Hive box.
/// Must be overridden in ProviderScope at app startup.
final settingsBoxProvider = Provider<Box>((ref) {
  throw UnimplementedError(
    'settingsBoxProvider must be overridden at app startup',
  );
});

/// State notifier for app preferences.
/// Reads synchronously from the pre-opened box — no async gap.
final preferencesProvider =
    StateNotifierProvider<PreferencesNotifier, AppPreferences>((ref) {
  final box = ref.watch(settingsBoxProvider);
  return PreferencesNotifier(box);
});

class PreferencesNotifier extends StateNotifier<AppPreferences> {
  final Box _box;

  PreferencesNotifier(this._box)
      : super(AppPreferences(
          themeMode:
              _box.get('themeMode', defaultValue: 'system') as String,
        ));

  void setThemeMode(String value) {
    _box.put('themeMode', value);
    state = state.copyWith(themeMode: value);
  }
}
