import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter/features/settings/data/settings_repository.dart';
import 'package:flutter_starter/features/settings/presentation/theme_mode_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

class _MockSettingsRepository extends Mock implements SettingsRepository;

void main() {
  setUpAll(() => registerFallbackValue(ThemeMode.system));

  late _MockSettingsRepository repo;

  setUp(() {
    repo = _MockSettingsRepository();
    when(() => repo.setThemeMode(any())).thenAnswer((_) async {});
  });

  ProviderContainer makeContainer() => ProviderContainer.test(
    retry: (_, _) => null,
    overrides: [
      initialThemeModeProvider.overrideWithValue(ThemeMode.dark),
      settingsRepositoryProvider.overrideWithValue(repo),
    ],
  );

  test('starts with the initial theme mode', () {
    final container = makeContainer();

    expect(container.read(themeModeControllerProvider), ThemeMode.dark);
  });

  test('setThemeMode updates state and persists', () async {
    final container = makeContainer();

    await container
        .read(themeModeControllerProvider.notifier)
        .setThemeMode(ThemeMode.light);

    expect(container.read(themeModeControllerProvider), ThemeMode.light);
    verify(() => repo.setThemeMode(ThemeMode.light)).called(1);
  });

  test('keeps the new mode and does not throw when saving fails', () async {
    when(() => repo.setThemeMode(any())).thenAnswer((_) async {
      throw StateError('disk full');
    });
    final reported = <FlutterErrorDetails>[];
    final previous = FlutterError.onError;
    FlutterError.onError = reported.add;
    addTearDown(() => FlutterError.onError = previous);
    final container = makeContainer();

    await container
        .read(themeModeControllerProvider.notifier)
        .setThemeMode(ThemeMode.light);

    expect(container.read(themeModeControllerProvider), ThemeMode.light);
    expect(reported, hasLength(1));
    expect(reported.single.exception, isStateError);
  });
}
