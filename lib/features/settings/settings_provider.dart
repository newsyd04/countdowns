import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive_ce.dart';

/// Persisted user preferences backed by a pre-opened Hive box.
class AppPreferences {
  final bool hapticsEnabled;
  final bool notificationsEnabled;
  final String themeMode;

  const AppPreferences({
    this.hapticsEnabled = true,
    this.notificationsEnabled = true,
    this.themeMode = 'system',
  });

  AppPreferences copyWith({
    bool? hapticsEnabled,
    bool? notificationsEnabled,
    String? themeMode,
  }) {
    return AppPreferences(
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
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
          hapticsEnabled:
              _box.get('hapticsEnabled', defaultValue: true) as bool,
          notificationsEnabled:
              _box.get('notificationsEnabled', defaultValue: true) as bool,
          themeMode:
              _box.get('themeMode', defaultValue: 'system') as String,
        ));

  void setHapticsEnabled(bool value) {
    _box.put('hapticsEnabled', value);
    state = state.copyWith(hapticsEnabled: value);
  }

  void setNotificationsEnabled(bool value) {
    _box.put('notificationsEnabled', value);
    state = state.copyWith(notificationsEnabled: value);
  }

  void setThemeMode(String value) {
    _box.put('themeMode', value);
    state = state.copyWith(themeMode: value);
  }
}
