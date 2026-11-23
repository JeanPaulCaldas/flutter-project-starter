import 'package:flutter_starter/core/error/app_exception.dart';
import 'package:flutter_starter/features/posts/data/repositories/posts_repository_impl.dart';
import 'package:flutter_starter/features/posts/domain/entities/post.dart';
import 'package:flutter_starter/features/posts/domain/repositories/posts_repository.dart';
import 'package:flutter_starter/features/posts/presentation/screens/post_detail_screen.dart';
import 'package:flutter_starter/l10n/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/pump_app.dart';

class _MockPostsRepository extends Mock implements PostsRepository;

void main() {
  final l10n = AppLocalizationsEn();
  late _MockPostsRepository repo;

  setUp(() => repo = _MockPostsRepository());

  Future<void> pump(WidgetTester tester, int id) async {
    await tester.pumpApp(
      PostDetailScreen(postId: id),
      overrides: [postsRepositoryProvider.overrideWithValue(repo)],
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows title and body', (tester) async {
    when(() => repo.getPost(1)).thenAnswer(
      (_) async =>
          const Post(id: 1, userId: 1, title: 'Hello post', body: 'Body text'),
    );

    await pump(tester, 1);

    expect(find.text('Hello post'), findsOneWidget);
    expect(find.text('Body text'), findsOneWidget);
  });

  testWidgets('shows not-found message', (tester) async {
    when(() => repo.getPost(999)).thenThrow(const NotFoundException());

    await pump(tester, 999);

    expect(find.text(l10n.errorNotFound), findsOneWidget);
  });
}
