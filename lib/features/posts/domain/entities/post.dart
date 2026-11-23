// Freezed's redirecting factories cannot use the `new` declaration form.
// ignore_for_file: unnecessary_type_name_in_constructor

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
