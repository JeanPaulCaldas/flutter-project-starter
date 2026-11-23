import 'package:flutter_starter/core/error/app_exception.dart';
import 'package:flutter_starter/features/posts/data/datasources/posts_remote_data_source.dart';
import 'package:flutter_starter/features/posts/data/models/post_dto.dart';
import 'package:flutter_starter/features/posts/data/repositories/posts_repository_impl.dart';
import 'package:flutter_starter/features/posts/domain/entities/post.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRemote extends Mock implements PostsRemoteDataSource;

void main() {
  late _MockRemote remote;
  late PostsRepositoryImpl repository;

  setUp(() {
    remote = _MockRemote();
    repository = PostsRepositoryImpl(remote);
  });

  test('getPosts maps DTOs to entities', () async {
    when(() => remote.fetchPosts()).thenAnswer(
      (_) async => [const PostDto(id: 1, userId: 2, title: 't', body: 'b')],
    );

    expect(await repository.getPosts(), const [
      Post(id: 1, userId: 2, title: 't', body: 'b'),
    ]);
  });

  test('getPost maps the DTO to an entity', () async {
    when(() => remote.fetchPost(1)).thenAnswer(
      (_) async => const PostDto(id: 1, userId: 2, title: 't', body: 'b'),
    );

    expect(
      await repository.getPost(1),
      const Post(id: 1, userId: 2, title: 't', body: 'b'),
    );
  });

  test('getPosts propagates AppException unchanged', () async {
    when(() => remote.fetchPosts()).thenThrow(const NetworkException());

    await expectLater(repository.getPosts(), throwsA(isA<NetworkException>()));
  });

  test('getPost propagates AppException unchanged', () async {
    when(() => remote.fetchPost(1)).thenThrow(const NotFoundException());

    await expectLater(repository.getPost(1), throwsA(isA<NotFoundException>()));
  });
}
