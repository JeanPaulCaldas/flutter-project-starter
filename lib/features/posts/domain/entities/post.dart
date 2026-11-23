import 'package:freezed_annotation/freezed_annotation.dart';

part 'post.freezed.dart';

/// A blog post.
@freezed
abstract class Post with _$Post {
  /// Creates a post.
  const factory Post({
    required int id,
    required int userId,
    required String title,
    required String body,
  }) = _Post;
}
