import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter/core/error/app_exception.dart';
import 'package:flutter_starter/features/posts/data/repositories/posts_repository_impl.dart';
import 'package:flutter_starter/features/posts/domain/entities/post.dart';
import 'package:flutter_starter/features/posts/domain/repositories/posts_repository.dart';
import 'package:flutter_starter/features/posts/presentation/providers/posts_providers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockPostsRepository extends Mock implements PostsRepository;

void main() {
  const post = Post(id: 1, userId: 1, title: 't', body: 'b');
  late _MockPostsRepository repo;

  ProviderContainer makeContainer() => ProviderContainer.test(
    retry: (_, _) => null,
    overrides: [postsRepositoryProvider.overrideWithValue(repo)],
  );

  setUp(() => repo = _MockPostsRepository());

  test('postsList completes with the repository posts', () async {
    when(() => repo.getPosts()).thenAnswer((_) async => [post]);

    await expectLater(
      makeContainer().read(postsListProvider.future),
      completion([post]),
    );
  });

  test('postsList surfaces repository errors', () async {
    when(() => repo.getPosts()).thenThrow(const NetworkException());

    await expectLater(
      makeContainer().read(postsListProvider.future),
      throwsA(isA<NetworkException>()),
    );
  });

  test('postDetail completes with the requested post', () async {
    when(() => repo.getPost(1)).thenAnswer((_) async => post);

    await expectLater(
      makeContainer().read(postDetailProvider(1).future),
      completion(post),
    );
  });
}
