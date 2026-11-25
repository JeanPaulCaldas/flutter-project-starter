// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Flutter Starter';

  @override
  String get postsTitle => 'Posts';

  @override
  String get postDetailTitle => 'Post';

  @override
  String get retry => 'Retry';

  @override
  String get emptyPosts => 'There are no posts yet.';

  @override
  String get errorNetwork =>
      'Can\'t reach the server. Check your connection and try again.';

  @override
  String errorServer(String statusCode) {
    return 'The server returned an error ($statusCode). Please try again later.';
  }

  @override
  String get errorServerUnknownStatus =>
      'The server returned an error. Please try again later.';

  @override
  String get errorNotFound => 'We couldn\'t find what you were looking for.';

  @override
  String get errorParsing => 'The server sent a response we couldn\'t read.';

  @override
  String get errorUnknown => 'Something went wrong. Please try again.';

  @override
  String get pageNotFound => 'Page not found';

  @override
  String get goHome => 'Go to home';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeMenuTooltip => 'Change theme';
}
