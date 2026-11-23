import 'package:dio/dio.dart';
import 'package:flutter_starter/core/error/app_exception.dart';
import 'package:json_annotation/json_annotation.dart';

/// Runs [call] and converts every failure into an [AppException].
///
/// This is the single place where transport and parsing errors are mapped.
Future<T> guardApiCall<T>(Future<T> Function() call) async {
  try {
    return await call();
  } on AppException {
    rethrow;
  } on DioException catch (e) {
    throw e.toAppException();
    // A failed cast while decoding JSON surfaces as a TypeError.
    // ignore: avoid_catching_errors
  } on TypeError catch (e) {
    throw ParsingException(e);
  } on FormatException catch (e) {
    throw ParsingException(e);
  } on CheckedFromJsonException catch (e) {
    throw ParsingException(e);
  }
}
