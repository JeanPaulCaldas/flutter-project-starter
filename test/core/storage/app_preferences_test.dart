import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter/core/storage/app_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  late AppPreferences preferences;

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    preferences = AppPreferences(SharedPreferencesAsync());
  });

  test('getThemeMode returns null initially', () async {
    expect(await preferences.getThemeMode(), isNull);
  });

  test('setThemeMode persists the value', () async {
    await preferences.setThemeMode('dark');

    expect(await preferences.getThemeMode(), 'dark');
  });

  test('writing the theme mode twice keeps the last value', () async {
    await preferences.setThemeMode('dark');
    await preferences.setThemeMode('light');

    expect(await preferences.getThemeMode(), 'light');
  });

  test('appPreferencesProvider reads and writes the shared storage', () async {
    final container = ProviderContainer.test(retry: (_, _) => null);

    await container.read(appPreferencesProvider).setThemeMode('dark');

    expect(await container.read(appPreferencesProvider).getThemeMode(), 'dark');
    expect(await preferences.getThemeMode(), 'dark');
  });
}
