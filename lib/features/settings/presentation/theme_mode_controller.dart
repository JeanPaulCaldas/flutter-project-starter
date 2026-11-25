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
  ///
  /// Never throws: a failed save is reported and the choice still applies for
  /// this session, but is not restored on the next launch.
  Future<void> setThemeMode(ThemeMode mode) async {
    // Optimistic: the UI updates at once. Callers such as the menu button pass
    // this method as a tear-off and cannot await it, so a rethrown error would
    // be unhandled. FlutterError.reportError (rather than debugPrint) keeps the
    // failure visible in release builds through FlutterError.onError, where a
    // crash reporter can pick it up.
    state = mode;
    try {
      await ref.read(settingsRepositoryProvider).setThemeMode(mode);
    } on Object catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'settings',
          context: ErrorDescription('while saving the theme mode'),
        ),
      );
    }
  }
}
