import 'package:flutter_starter/features/posts/data/models/post_dto.dart';
import 'package:flutter_starter/features/posts/domain/entities/post.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fromJson then toEntity maps all fields', () {
    final dto = PostDto.fromJson(const {
      'id': 1,
      'userId': 2,
      'title': 't',
      'body': 'b',
    });
    expect(dto.toEntity(), const Post(id: 1, userId: 2, title: 't', body: 'b'));
  });
}
