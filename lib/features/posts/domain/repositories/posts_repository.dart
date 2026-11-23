import 'package:flutter_starter/features/posts/domain/entities/post.dart';

/// Source of [Post]s. Failures surface as `AppException`.
abstract interface class PostsRepository {
  /// Returns all posts.
  Future<List<Post>> getPosts();

  /// Returns the post with the given [id].
  Future<Post> getPost(int id);
}
