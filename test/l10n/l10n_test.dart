import 'package:flutter_starter/core/error/app_exception.dart';
import 'package:flutter_starter/l10n/app_localizations_en.dart';
import 'package:flutter_starter/l10n/l10n.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final l10n = AppLocalizationsEn();

  group('errorMessage', () {
    test('maps each AppException subtype', () {
      expect(errorMessage(const NetworkException(), l10n), l10n.errorNetwork);
      expect(errorMessage(const NotFoundException(), l10n), l10n.errorNotFound);
      expect(errorMessage(const ParsingException(), l10n), l10n.errorParsing);
      expect(errorMessage(const UnknownException(), l10n), l10n.errorUnknown);
    });

    test('includes the status code for server errors', () {
      expect(errorMessage(const ServerException(503), l10n), contains('503'));
    });

    test('renders a placeholder when the status code is missing', () {
      expect(
        errorMessage(const ServerException(null), l10n),
        l10n.errorServer('?'),
      );
    });

    test('maps non-AppException errors to unknown', () {
      expect(errorMessage(Exception('x'), l10n), l10n.errorUnknown);
    });
  });
}
