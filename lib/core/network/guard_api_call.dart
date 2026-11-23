import 'package:dio/dio.dart';
import 'package:flutter_starter/core/error/app_exception.dart';
import 'package:json_annotation/json_annotation.dart';

/// Runs [call] and converts every failure into an [AppException], keeping
/// the original stack trace.
///
/// This is the single place where transport and parsing errors are mapped.
Future<T> guardApiCall<T>(Future<T> Function() call) async {
  try {
    return await call();
  } on AppException {
    rethrow;
  } on Object catch (e, st) {
    Error.throwWithStackTrace(_toAppException(e), st);
  }
}

AppException _toAppException(Object error) => switch (error) {
  DioException() => error.toAppException(),
  // A failed cast while decoding JSON surfaces as a TypeError.
  TypeError() ||
  FormatException() ||
  CheckedFromJsonException() => ParsingException(error),
  _ => UnknownException(error),
};
