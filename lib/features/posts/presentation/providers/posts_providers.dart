import 'package:flutter_starter/features/posts/data/repositories/posts_repository_impl.dart';
import 'package:flutter_starter/features/posts/domain/entities/post.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'posts_providers.g.dart';

/// All posts.
@riverpod
Future<List<Post>> postsList(Ref ref) =>
    ref.watch(postsRepositoryProvider).getPosts();

/// A single post by [id].
@riverpod
Future<Post> postDetail(Ref ref, int id) =>
    ref.watch(postsRepositoryProvider).getPost(id);
