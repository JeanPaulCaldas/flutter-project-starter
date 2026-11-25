/// Compile-time configuration, supplied with `--dart-define` or
/// `--dart-define-from-file=config/dev.json`.
abstract final class Env {
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://jsonplaceholder.typicode.com',
  );
}
