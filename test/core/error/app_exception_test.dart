import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_starter/core/error/app_exception.dart';
import 'package:flutter_test/flutter_test.dart';

DioException _dioError(
  DioExceptionType type, {
  int? statusCode,
  Object? error,
}) {
  final options = RequestOptions();
  return DioException(
    requestOptions: options,
    type: type,
    error: error,
    response: statusCode == null
        ? null
        : Response<void>(requestOptions: options, statusCode: statusCode),
  );
}

void main() {
  group('DioExceptionMapper.toAppException', () {
    for (final type in [
      DioExceptionType.connectionTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.receiveTimeout,
      DioExceptionType.connectionError,
      DioExceptionType.transformTimeout,
    ]) {
      test('maps $type to NetworkException', () {
        expect(_dioError(type).toAppException(), isA<NetworkException>());
      });
    }

    test('maps badResponse 404 to NotFoundException', () {
      final e = _dioError(DioExceptionType.badResponse, statusCode: 404);
      expect(e.toAppException(), isA<NotFoundException>());
    });

    test('maps badResponse 500 to ServerException with status code', () {
      final e = _dioError(DioExceptionType.badResponse, statusCode: 500);
      expect(
        e.toAppException(),
        isA<ServerException>().having((s) => s.statusCode, 'statusCode', 500),
      );
    });

    test('maps unknown with SocketException to NetworkException', () {
      final e = _dioError(
        DioExceptionType.unknown,
        error: const SocketException('x'),
      );
      expect(e.toAppException(), isA<NetworkException>());
    });

    test('maps unknown with FormatException to ParsingException', () {
      const cause = FormatException('bad json');
      final e = _dioError(DioExceptionType.unknown, error: cause);
      expect(
        e.toAppException(),
        isA<ParsingException>().having((p) => p.cause, 'cause', cause),
      );
    });

    test('maps unknown with other error to UnknownException', () {
      final cause = StateError('x');
      final e = _dioError(DioExceptionType.unknown, error: cause);
      expect(
        e.toAppException(),
        isA<UnknownException>().having((u) => u.cause, 'cause', same(cause)),
      );
    });

    test('maps cancel to UnknownException', () {
      expect(
        _dioError(DioExceptionType.cancel).toAppException(),
        isA<UnknownException>(),
      );
    });

    test('maps badCertificate to UnknownException', () {
      expect(
        _dioError(DioExceptionType.badCertificate).toAppException(),
        isA<UnknownException>(),
      );
    });
  });
}
