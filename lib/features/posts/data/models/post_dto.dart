// Freezed's redirecting factories cannot use the `new` declaration form.
// ignore_for_file: unnecessary_type_name_in_constructor

import 'package:flutter_starter/features/posts/domain/entities/post.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_dto.freezed.dart';
part 'post_dto.g.dart';

/// Wire representation of a post.
@freezed
abstract class PostDto with _$PostDto {
  /// Creates a post DTO.
  const factory PostDto({
    required int id,
    required int userId,
    required String title,
    required String body,
  }) = _PostDto;

  /// Parses a JSON object.
  factory PostDto.fromJson(Map<String, dynamic> json) =>
      _$PostDtoFromJson(json);

  const PostDto._();

  /// Converts to the domain entity.
  Post toEntity() => Post(id: id, userId: userId, title: title, body: body);
}
