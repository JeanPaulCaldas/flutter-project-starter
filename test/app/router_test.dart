import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter/app/app.dart';
import 'package:flutter_starter/app/router.dart';
import 'package:flutter_starter/features/posts/data/repositories/posts_repository_impl.dart';
import 'package:flutter_starter/features/posts/domain/entities/post.dart';
import 'package:flutter_starter/features/posts/domain/repositories/posts_repository.dart';
import 'package:flutter_starter/features/settings/data/settings_repository.dart';
import 'package:flutter_starter/l10n/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

class _MockPostsRepository extends Mock implements PostsRepository;

class _MockSettingsRepository extends Mock implements SettingsRepository;

void main() {
  final l10n = AppLocalizationsEn();

  setUpAll(() => registerFallbackValue(ThemeMode.system));

  Future<ProviderContainer> pumpApp(WidgetTester tester) async {
    final repo = _MockPostsRepository();
    final settings = _MockSettingsRepository();
    when(() => settings.setThemeMode(any())).thenAnswer((_) async {});
    when(repo.getPosts).thenAnswer(
      (_) async => const [
        Post(id: 1, userId: 1, title: 'Hello post', body: 'Body text'),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [
          postsRepositoryProvider.overrideWithValue(repo),
          settingsRepositoryProvider.overrideWithValue(settings),
        ],
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();
    return ProviderScope.containerOf(tester.element(find.byType(App)));
  }

  for (final location in ['/posts/abc', '/nope']) {
    testWidgets('shows not found for $location', (tester) async {
      final container = await pumpApp(tester);

      container.read(routerProvider).go(location);
      await tester.pumpAndSettle();

      expect(find.text(l10n.pageNotFound), findsOneWidget);
    });
  }

  testWidgets('not found offers a way back to the posts list', (tester) async {
    final container = await pumpApp(tester);
    container.read(routerProvider).go('/nope');
    await tester.pumpAndSettle();

    await tester.tap(find.text(l10n.goHome));
    await tester.pumpAndSettle();

    expect(find.text(l10n.pageNotFound), findsNothing);
    expect(find.text('Hello post'), findsOneWidget);
  });
}
