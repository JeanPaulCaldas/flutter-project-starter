import 'dart:async';

import 'package:flutter_starter/core/error/app_exception.dart';
import 'package:flutter_starter/features/posts/data/repositories/posts_repository_impl.dart';
import 'package:flutter_starter/features/posts/domain/entities/post.dart';
import 'package:flutter_starter/features/posts/domain/repositories/posts_repository.dart';
import 'package:flutter_starter/features/posts/presentation/screens/posts_screen.dart';
import 'package:flutter_starter/l10n/app_localizations_en.dart';
import 'package:flutter_starter/shared/widgets/loading_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/pump_app.dart';

class _MockPostsRepository extends Mock implements PostsRepository;

void main() {
  const post = Post(id: 1, userId: 1, title: 'Hello post', body: 'Body text');
  final l10n = AppLocalizationsEn();
  late _MockPostsRepository repo;

  setUp(() => repo = _MockPostsRepository());

  Future<void> pump(WidgetTester tester) => tester.pumpApp(
    const PostsScreen(),
    overrides: [postsRepositoryProvider.overrideWithValue(repo)],
  );

  testWidgets('shows loading while posts are fetched', (tester) async {
    when(() => repo.getPosts())
        .thenAnswer((_) => Completer<List<Post>>().future);

    await pump(tester);

    expect(find.byType(LoadingView), findsOneWidget);
  });

  testWidgets('shows posts when loaded', (tester) async {
    when(() => repo.getPosts()).thenAnswer((_) async => [post]);

    await pump(tester);
    await tester.pumpAndSettle();

    expect(find.text(l10n.postsTitle), findsOneWidget);
    expect(find.text('Hello post'), findsOneWidget);
  });

  testWidgets('shows the error and retries', (tester) async {
    var calls = 0;
    when(() => repo.getPosts()).thenAnswer((_) async {
      calls++;
      if (calls == 1) throw const NetworkException();
      return [post];
    });

    await pump(tester);
    await tester.pumpAndSettle();

    expect(find.text(l10n.errorNetwork), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('Hello post'), findsOneWidget);
    verify(() => repo.getPosts()).called(2);
  });

  testWidgets('shows the empty message for an empty list', (tester) async {
    when(() => repo.getPosts()).thenAnswer((_) async => []);

    await pump(tester);
    await tester.pumpAndSettle();

    expect(find.text(l10n.emptyPosts), findsOneWidget);
  });
}
