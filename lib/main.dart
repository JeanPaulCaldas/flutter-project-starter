import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter/app/app.dart';
import 'package:flutter_starter/core/storage/app_preferences.dart';
import 'package:flutter_starter/features/settings/data/settings_repository.dart';
import 'package:flutter_starter/features/settings/presentation/theme_mode_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = AppPreferences(SharedPreferencesAsync());
  final themeMode = await SettingsRepository(prefs).getThemeMode();
  runApp(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [
        appPreferencesProvider.overrideWithValue(prefs),
        initialThemeModeProvider.overrideWithValue(themeMode),
      ],
      child: const App(),
    ),
  );
}
