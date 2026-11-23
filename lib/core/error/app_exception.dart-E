import 'dart:io';

import 'package:dio/dio.dart';

/// Application-level failures, independent of the transport library.
sealed class AppException implements Exception {
  const AppException();
}

/// No connectivity, or the request timed out.
final class NetworkException extends AppException {
  const NetworkException();

  @override
  String toString() => 'NetworkException';
}

/// The server answered with an error status.
final class ServerException extends AppException {
  const ServerException(this.statusCode);

  final int? statusCode;

  @override
  String toString() => 'ServerException($statusCode)';
}

/// The requested resource does not exist (HTTP 404).
final class NotFoundException extends AppException {
  const NotFoundException();

  @override
  String toString() => 'NotFoundException';
}

/// The response could not be parsed into the expected shape.
final class ParsingException extends AppException {
  const ParsingException([this.cause]);

  final Object? cause;

  @override
  String toString() => 'ParsingException($cause)';
}

/// Any failure that does not fit another category.
final class UnknownException extends AppException {
  const UnknownException([this.cause]);

  final Object? cause;

  @override
  String toString() => 'UnknownException($cause)';
}

/// Maps Dio errors to [AppException]s.
extension DioExceptionMapper on DioException {
  AppException toAppException() {
    switch (type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
      case DioExceptionType.transformTimeout:
        return const NetworkException();
      case DioExceptionType.badResponse:
        final code = response?.statusCode;
        return code == 404 ? const NotFoundException() : ServerException(code);
      case DioExceptionType.unknown:
        final cause = error;
        return cause is SocketException
            ? const NetworkException()
            : UnknownException(cause);
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
        return UnknownException(this);
    }
  }
}
