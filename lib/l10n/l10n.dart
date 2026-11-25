import 'package:flutter/widgets.dart';
import 'package:flutter_starter/core/error/app_exception.dart';
import 'package:flutter_starter/l10n/app_localizations.dart';

export 'package:flutter_starter/l10n/app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Maps any error to a localized, user-facing message.
///
/// A [ServerException] without a status code uses a message without one.
String errorMessage(Object error, AppLocalizations l10n) {
  if (error is! AppException) return l10n.errorUnknown;
  return switch (error) {
    NetworkException() => l10n.errorNetwork,
    ServerException(:final statusCode) =>
      statusCode == null
          ? l10n.errorServerUnknownStatus
          : l10n.errorServer(statusCode.toString()),
    NotFoundException() => l10n.errorNotFound,
    ParsingException() => l10n.errorParsing,
    UnknownException() => l10n.errorUnknown,
  };
}
