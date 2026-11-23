import 'package:dio/dio.dart';
import 'package:flutter_starter/core/network/dio_provider.dart';
import 'package:flutter_starter/core/network/guard_api_call.dart';
import 'package:flutter_starter/features/posts/data/models/post_dto.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'posts_remote_data_source.g.dart';

/// REST access to posts. Failures surface as `AppException`.
class PostsRemoteDataSource {
  /// Creates a data source backed by [_dio].
  const PostsRemoteDataSource(this._dio);

  final Dio _dio;

  /// Fetches all posts.
  Future<List<PostDto>> fetchPosts() => guardApiCall(() async {
    final response = await _dio.get<dynamic>('/posts');
    return (response.data as List<dynamic>)
        .map((e) => PostDto.fromJson(e as Map<String, dynamic>))
        .toList();
  });

  /// Fetches the post with the given [id].
  Future<PostDto> fetchPost(int id) => guardApiCall(() async {
    final response = await _dio.get<dynamic>('/posts/$id');
    return PostDto.fromJson(response.data as Map<String, dynamic>);
  });
}

/// [PostsRemoteDataSource] bound to the shared [Dio].
@riverpod
PostsRemoteDataSource postsRemoteDataSource(Ref ref) =>
    PostsRemoteDataSource(ref.watch(dioProvider));
