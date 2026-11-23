import 'package:flutter_starter/core/storage/app_preferences.dart';
import 'package:material_ui/material_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_repository.g.dart';

/// Reads and writes user settings, mapping stored primitives to app types.
class SettingsRepository {
  /// Creates a repository persisting through [_prefs].
  const new(this._prefs);

  final AppPreferences _prefs;

  /// Returns the saved [ThemeMode]; missing or unknown values yield
  /// [ThemeMode.system].
  Future<ThemeMode> getThemeMode() async {
    final stored = await _prefs.getThemeMode();
    return ThemeMode.values.asNameMap()[stored] ?? ThemeMode.system;
  }

  /// Persists [mode] by name.
  Future<void> setThemeMode(ThemeMode mode) => _prefs.setThemeMode(mode.name);
}

/// The app's [SettingsRepository]; kept alive with its preferences dependency.
@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(Ref ref) =>
    SettingsRepository(ref.watch(appPreferencesProvider));
