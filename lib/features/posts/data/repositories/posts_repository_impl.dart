import 'package:flutter_starter/features/posts/data/datasources/posts_remote_data_source.dart';
import 'package:flutter_starter/features/posts/domain/entities/post.dart';
import 'package:flutter_starter/features/posts/domain/repositories/posts_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'posts_repository_impl.g.dart';

/// [PostsRepository] backed by the remote data source.
class PostsRepositoryImpl implements PostsRepository {
  /// Creates a repository reading from [_remote].
  const new(this._remote);

  final PostsRemoteDataSource _remote;

  @override
  Future<List<Post>> getPosts() async {
    final dtos = await _remote.fetchPosts();
    return dtos.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<Post> getPost(int id) async =>
      (await _remote.fetchPost(id)).toEntity();
}

/// The app's [PostsRepository].
@riverpod
PostsRepository postsRepository(Ref ref) =>
    PostsRepositoryImpl(ref.watch(postsRemoteDataSourceProvider));
