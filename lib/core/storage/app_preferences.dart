import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'app_preferences.g.dart';

const _themeModeKey = 'theme_mode';

/// Thin wrapper over [SharedPreferencesAsync] that stores primitives only.
///
/// Mapping to domain/Flutter types happens in repositories.
class AppPreferences {
  /// Creates preferences backed by [_prefs].
  const AppPreferences(this._prefs);

  final SharedPreferencesAsync _prefs;

  /// Returns the stored theme mode name, or `null` if none was saved.
  Future<String?> getThemeMode() => _prefs.getString(_themeModeKey);

  /// Persists the theme mode name.
  Future<void> setThemeMode(String value) =>
      _prefs.setString(_themeModeKey, value);
}

/// App-wide [AppPreferences]; `main()` overrides it at startup.
@Riverpod(keepAlive: true)
AppPreferences appPreferences(Ref ref) =>
    AppPreferences(SharedPreferencesAsync());
