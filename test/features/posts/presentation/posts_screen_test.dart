import 'dart:async';

import 'package:flutter_starter/core/error/app_exception.dart';
import 'package:flutter_starter/features/posts/data/repositories/posts_repository_impl.dart';
import 'package:flutter_starter/features/posts/domain/entities/post.dart';
import 'package:flutter_starter/features/posts/domain/repositories/posts_repository.dart';
import 'package:flutter_starter/features/posts/presentation/screens/posts_screen.dart';
import 'package:flutter_starter/l10n/app_localizations_en.dart';
import 'package:flutter_starter/shared/widgets/error_view.dart';
import 'package:flutter_starter/shared/widgets/loading_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
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

  testWidgets('shows loading, not the stale error, while retrying', (
    tester,
  ) async {
    final retry = Completer<List<Post>>();
    var calls = 0;
    when(() => repo.getPosts()).thenAnswer((_) {
      calls++;
      if (calls == 1) return Future.error(const NetworkException());
      return retry.future;
    });

    await pump(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.retry));
    await tester.pump();

    expect(find.byType(LoadingView), findsOneWidget);
    expect(find.byType(ErrorView), findsNothing);

    retry.complete([post]);
    await tester.pumpAndSettle();

    expect(find.text('Hello post'), findsOneWidget);
  });

  testWidgets('keeps the list and shows a SnackBar when a refresh fails', (
    tester,
  ) async {
    var calls = 0;
    when(() => repo.getPosts()).thenAnswer((_) async {
      calls++;
      if (calls == 1) return [post];
      throw const NetworkException();
    });

    await pump(tester);
    await tester.pumpAndSettle();
    await tester.fling(find.text('Hello post'), const Offset(0, 300), 1000);
    await tester.pumpAndSettle();

    expect(calls, 2);
    expect(find.text('Hello post'), findsOneWidget);
    expect(find.byType(ErrorView), findsNothing);
    expect(
      find.descendant(
        of: find.byType(SnackBar),
        matching: find.text(l10n.errorNetwork),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('the empty state can be pulled to refresh', (tester) async {
    var calls = 0;
    when(() => repo.getPosts()).thenAnswer((_) async {
      calls++;
      return calls == 1 ? [] : [post];
    });

    await pump(tester);
    await tester.pumpAndSettle();
    await tester.fling(find.text(l10n.emptyPosts), const Offset(0, 300), 1000);
    await tester.pumpAndSettle();

    expect(find.text('Hello post'), findsOneWidget);
  });
}
