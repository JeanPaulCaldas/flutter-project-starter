import 'package:flutter_starter/core/storage/app_preferences.dart';
import 'package:flutter_starter/features/settings/data/settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

class _MockAppPreferences extends Mock implements AppPreferences;

void main() {
  late _MockAppPreferences prefs;
  late SettingsRepository repository;

  setUp(() {
    prefs = _MockAppPreferences();
    repository = SettingsRepository(prefs);
  });

  test('getThemeMode maps a stored name to ThemeMode', () async {
    when(() => prefs.getThemeMode()).thenAnswer((_) async => 'dark');

    expect(await repository.getThemeMode(), ThemeMode.dark);
  });

  test('getThemeMode returns system when nothing is stored', () async {
    when(() => prefs.getThemeMode()).thenAnswer((_) async => null);

    expect(await repository.getThemeMode(), ThemeMode.system);
  });

  test('getThemeMode returns system for an unknown stored value', () async {
    when(() => prefs.getThemeMode()).thenAnswer((_) async => 'purple');

    expect(await repository.getThemeMode(), ThemeMode.system);
  });

  test('setThemeMode persists the mode name', () async {
    when(() => prefs.setThemeMode(any())).thenAnswer((_) async {});

    await repository.setThemeMode(ThemeMode.light);

    verify(() => prefs.setThemeMode('light')).called(1);
  });
}
