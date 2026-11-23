import 'package:dio/dio.dart';
import 'package:flutter_starter/core/error/app_exception.dart';
import 'package:flutter_starter/features/posts/data/datasources/posts_remote_data_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockDio extends Mock implements Dio;

Response<dynamic> _ok(String path, Object? data) => Response<dynamic>(
  requestOptions: RequestOptions(path: path),
  data: data,
  statusCode: 200,
);

Map<String, Object?> _json(int id) => {
  'id': id,
  'userId': 1,
  'title': 't$id',
  'body': 'b$id',
};

void main() {
  late _MockDio dio;
  late PostsRemoteDataSource source;

  setUp(() {
    dio = _MockDio();
    source = PostsRemoteDataSource(dio);
  });

  test('fetchPosts returns a DTO per list item', () async {
    when(() => dio.get<dynamic>('/posts'))
        .thenAnswer((_) async => _ok('/posts', [_json(1), _json(2)]));

    final posts = await source.fetchPosts();

    expect(posts, hasLength(2));
    expect(posts.last.id, 2);
  });

  test('fetchPost returns the DTO', () async {
    when(() => dio.get<dynamic>('/posts/1'))
        .thenAnswer((_) async => _ok('/posts/1', _json(1)));

    expect((await source.fetchPost(1)).title, 't1');
  });

  test('fetchPosts throws ParsingException when data is not a list', () async {
    when(() => dio.get<dynamic>('/posts'))
        .thenAnswer((_) async => _ok('/posts', {'not': 'a list'}));

    await expectLater(source.fetchPosts(), throwsA(isA<ParsingException>()));
  });

  test('fetchPost throws ParsingException on ill-typed JSON', () async {
    when(() => dio.get<dynamic>('/posts/1'))
        .thenAnswer((_) async => _ok('/posts/1', {'id': 'x'}));

    await expectLater(source.fetchPost(1), throwsA(isA<ParsingException>()));
  });

  test('fetchPost maps a 404 to NotFoundException', () async {
    final options = RequestOptions(path: '/posts/999');
    when(() => dio.get<dynamic>('/posts/999')).thenThrow(
      DioException.badResponse(
        statusCode: 404,
        requestOptions: options,
        response: Response<void>(requestOptions: options, statusCode: 404),
      ),
    );

    await expectLater(source.fetchPost(999), throwsA(isA<NotFoundException>()));
  });

  test('fetchPosts maps a connection error to NetworkException', () async {
    final options = RequestOptions(path: '/posts');
    when(() => dio.get<dynamic>('/posts')).thenThrow(
      DioException.connectionError(requestOptions: options, reason: 'offline'),
    );

    await expectLater(source.fetchPosts(), throwsA(isA<NetworkException>()));
  });
}
