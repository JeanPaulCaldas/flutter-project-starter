// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Flutter Starter';

  @override
  String get postsTitle => 'Publicaciones';

  @override
  String get postDetailTitle => 'Publicación';

  @override
  String get retry => 'Reintentar';

  @override
  String get emptyPosts => 'Aún no hay publicaciones.';

  @override
  String get errorNetwork =>
      'No se puede conectar con el servidor. Revisa tu conexión e inténtalo de nuevo.';

  @override
  String errorServer(String statusCode) {
    return 'El servidor devolvió un error ($statusCode). Inténtalo de nuevo más tarde.';
  }

  @override
  String get errorServerUnknownStatus =>
      'El servidor devolvió un error. Inténtalo de nuevo más tarde.';

  @override
  String get errorNotFound => 'No encontramos lo que buscabas.';

  @override
  String get errorParsing =>
      'El servidor envió una respuesta que no pudimos leer.';

  @override
  String get errorUnknown => 'Algo salió mal. Inténtalo de nuevo.';

  @override
  String get pageNotFound => 'Página no encontrada';

  @override
  String get goHome => 'Ir al inicio';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get themeMenuTooltip => 'Cambiar tema';
}
