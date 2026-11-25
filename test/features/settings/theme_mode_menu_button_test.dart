import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter/features/settings/data/settings_repository.dart';
import 'package:flutter_starter/features/settings/presentation/theme_mode_controller.dart';
import 'package:flutter_starter/features/settings/presentation/widgets/theme_mode_menu_button.dart';
import 'package:flutter_starter/l10n/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/pump_app.dart';

class _MockSettingsRepository extends Mock implements SettingsRepository;

void main() {
  setUpAll(() => registerFallbackValue(ThemeMode.system));

  testWidgets('the current mode is the menu initialValue', (tester) async {
    final repo = _MockSettingsRepository();
    await tester.pumpApp(
      const ThemeModeMenuButton(),
      overrides: [
        settingsRepositoryProvider.overrideWithValue(repo),
        initialThemeModeProvider.overrideWithValue(ThemeMode.light),
      ],
    );

    final menu = tester.widget<PopupMenuButton<ThemeMode>>(
      find.byType(PopupMenuButton<ThemeMode>),
    );

    expect(menu.initialValue, ThemeMode.light);
  });

  testWidgets('selecting Dark updates the theme mode', (tester) async {
    final repo = _MockSettingsRepository();
    when(() => repo.setThemeMode(any())).thenAnswer((_) async {});

    await tester.pumpApp(
      const ThemeModeMenuButton(),
      overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
    );

    await tester.tap(find.byTooltip(AppLocalizationsEn().themeMenuTooltip));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppLocalizationsEn().themeDark));
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(ThemeModeMenuButton)),
    );
    expect(container.read(themeModeControllerProvider), ThemeMode.dark);
    verify(() => repo.setThemeMode(ThemeMode.dark)).called(1);
  });
}
