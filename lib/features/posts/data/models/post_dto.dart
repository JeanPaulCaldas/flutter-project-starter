import 'package:flutter_starter/features/posts/domain/entities/post.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_dto.freezed.dart';
part 'post_dto.g.dart';

/// Wire representation of a post.
@freezed
@JsonSerializable()
class const PostDto({
  required final int id,
  required final int userId,
  required final String title,
  required final String body,
}) with _$PostDto {
  /// Parses a JSON object.
  factory fromJson(Map<String, dynamic> json) => _$PostDtoFromJson(json);

  /// Converts to the domain entity.
  Post toEntity() => Post(id: id, userId: userId, title: title, body: body);
}
