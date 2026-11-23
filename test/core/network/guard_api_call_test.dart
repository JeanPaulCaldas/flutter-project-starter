import 'package:dio/dio.dart';
import 'package:flutter_starter/core/error/app_exception.dart';
import 'package:flutter_starter/core/network/guard_api_call.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('returns the value on success', () async {
    expect(await guardApiCall(() async => 42), 42);
  });

  test('maps a 404 DioException to NotFoundException', () {
    final options = RequestOptions(path: '/x');
    expect(
      guardApiCall<int>(
        () async => throw DioException.badResponse(
          statusCode: 404,
          requestOptions: options,
          response: Response<void>(requestOptions: options, statusCode: 404),
        ),
      ),
      throwsA(isA<NotFoundException>()),
    );
  });

  test('maps TypeError to ParsingException', () {
    expect(
      guardApiCall<int>(() async => throw TypeError()),
      throwsA(isA<ParsingException>()),
    );
  });

  test('maps FormatException to ParsingException', () {
    expect(
      guardApiCall<int>(() async => throw const FormatException()),
      throwsA(isA<ParsingException>()),
    );
  });

  test('rethrows an AppException unchanged', () {
    expect(
      guardApiCall<int>(() async => throw const NetworkException()),
      throwsA(isA<NetworkException>()),
    );
  });
}
