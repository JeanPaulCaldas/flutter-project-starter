import 'package:flutter_starter/features/settings/data/settings_repository.dart';
import 'package:material_ui/material_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_mode_controller.g.dart';

/// The theme mode loaded at startup; `main()` overrides it.
@Riverpod(keepAlive: true)
ThemeMode initialThemeMode(Ref ref) => ThemeMode.system;

/// Holds the current [ThemeMode] and persists changes.
@Riverpod(keepAlive: true)
class ThemeModeController extends _$ThemeModeController {
  @override
  ThemeMode build() => ref.watch(initialThemeModeProvider);

  /// Applies [mode] immediately, then saves it.
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await ref.read(settingsRepositoryProvider).setThemeMode(mode);
  }
}
