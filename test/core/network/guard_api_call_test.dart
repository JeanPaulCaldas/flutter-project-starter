import 'package:dio/dio.dart';
import 'package:flutter_starter/core/error/app_exception.dart';
import 'package:flutter_starter/core/network/guard_api_call.dart';
import 'package:flutter_test/flutter_test.dart';

Never _failToDecode() => throw const FormatException('bad json');

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

  test('maps any other error to UnknownException', () {
    expect(
      guardApiCall<int>(() async => throw StateError('boom')),
      throwsA(
        isA<UnknownException>().having((e) => e.cause, 'cause', isStateError),
      ),
    );
  });

  test('keeps the stack trace of the original failure', () async {
    StackTrace? trace;
    try {
      await guardApiCall<int>(() async => _failToDecode());
    } on ParsingException catch (_, st) {
      trace = st;
    }

    expect(trace.toString(), contains('_failToDecode'));
  });
}
