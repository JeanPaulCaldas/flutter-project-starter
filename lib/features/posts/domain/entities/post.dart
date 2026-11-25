import 'package:freezed_annotation/freezed_annotation.dart';

part 'post.freezed.dart';

/// A blog post.
@freezed
class const Post({
  required final int id,
  required final int userId,
  required final String title,
  required final String body,
}) with _$Post;
