import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_starter/app/app.dart';
import 'package:flutter_starter/app/theme.dart';
import 'package:flutter_starter/features/posts/data/repositories/posts_repository_impl.dart';
import 'package:flutter_starter/features/posts/domain/entities/post.dart';
import 'package:flutter_starter/features/posts/domain/repositories/posts_repository.dart';
import 'package:flutter_starter/features/posts/presentation/screens/post_detail_screen.dart';
import 'package:flutter_starter/features/settings/data/settings_repository.dart';
import 'package:flutter_starter/features/settings/presentation/theme_mode_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

class _MockPostsRepository extends Mock implements PostsRepository;

class _MockSettingsRepository extends Mock implements SettingsRepository;

void main() {
  const post = Post(id: 1, userId: 1, title: 'Hello post', body: 'Body text');
  late _MockPostsRepository posts;
  late _MockSettingsRepository settings;

  setUp(() {
    posts = _MockPostsRepository();
    settings = _MockSettingsRepository();
    when(() => posts.getPosts()).thenAnswer((_) async => [post]);
    when(() => posts.getPost(1)).thenAnswer((_) async => post);
  });

  Future<void> pumpAppWidget(
    WidgetTester tester, {
    List<Override> extra = const [],
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [
          postsRepositoryProvider.overrideWithValue(posts),
          settingsRepositoryProvider.overrideWithValue(settings),
          ...extra,
        ],
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('boots into the posts list', (tester) async {
    await pumpAppWidget(tester);

    expect(find.text('Posts'), findsOneWidget);
    expect(find.text('Hello post'), findsOneWidget);
  });

  testWidgets('uses Spanish when the device locale is Spanish', (tester) async {
    tester.platformDispatcher.localesTestValue = [const Locale('es')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    await pumpAppWidget(tester);

    expect(find.text('Publicaciones'), findsOneWidget);
  });

  testWidgets('opens the post detail when a post is tapped', (tester) async {
    await pumpAppWidget(tester);

    await tester.tap(find.text('Hello post'));
    await tester.pumpAndSettle();

    expect(find.text('Body text'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.byType(PostDetailScreen), findsNothing);
    expect(find.text('Posts'), findsOneWidget);
    expect(find.text('Hello post'), findsOneWidget);
  });

  testWidgets('uses the light and dark themes from AppTheme', (tester) async {
    await pumpAppWidget(tester);

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.theme, AppTheme.light);
    expect(app.darkTheme, AppTheme.dark);
  });

  testWidgets('applies the initial theme mode', (tester) async {
    await pumpAppWidget(
      tester,
      extra: [initialThemeModeProvider.overrideWithValue(ThemeMode.dark)],
    );

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
  });
}
