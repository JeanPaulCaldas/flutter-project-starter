# Flutter Starter

A team baseline for Flutter apps that consume HTTP APIs. It gives you one obvious way to do each common thing: layers by feature, Riverpod for state and dependency injection, Dio for HTTP, typed errors, persisted preferences, English/Spanish localization, and test templates for every layer.

The sample app lists posts from [JSONPlaceholder](https://jsonplaceholder.typicode.com), opens a post detail screen, and lets the user pick a light/dark/system theme that survives restarts. Read it as a worked example of the conventions below.

Platforms: Android and iOS. Out of scope: caching/offline, auth, native flavors, analytics, an in-app language picker.

## Requirements

- [fvm](https://fvm.app) 3 or newer. Install or upgrade with `brew upgrade fvm` or `dart pub global activate fvm`.
- Flutter **3.50.1**, pinned in `.fvmrc` (`{"flutter": "3.50.1"}`). `fvm install` fetches it.

fvm 2.x reads `.fvm/fvm_config.json` instead of `.fvmrc` and will not pick up the pin; upgrade to fvm 3+. The `.fvm/` folder is git-ignored.

Run every Flutter and Dart command through `fvm` (`fvm flutter ...`, `fvm dart ...`).

## Getting started

```sh
fvm install
fvm flutter pub get
fvm dart run build_runner build -d
fvm flutter run --dart-define-from-file=config/dev.json
```

`config/dev.json` sets `BASE_URL`. `Env` (`lib/core/config/env.dart`) reads it with `String.fromEnvironment` and defaults to JSONPlaceholder, so `fvm flutter run` also works without the flag. Add another file (for example `config/prod.json`) per environment; there are no native flavors.

While developing, `fvm dart run build_runner watch -d` regenerates code on save.

### Generated files are committed

`*.g.dart`, `*.freezed.dart` and `lib/l10n/app_localizations*.dart` are checked in, so the project builds on a fresh clone and PR diffs show what generation changed. If you edit an annotated source or an ARB file, regenerate and commit the output. CI runs the generators and fails if `git status --porcelain` is not empty, so stale and never-committed generated files are both caught.

## Architecture

Code is organized by feature, and each feature has up to three layers.

```
lib/
  main.dart            read startup prefs, ProviderScope, runApp
  app/                 App widget, router, themes
  core/                config, error, network (Dio), storage (preferences)
  l10n/                ARB files, generated localizations, context.l10n, errorMessage
  features/
    posts/
      data/            datasources/, models/ (DTOs), repositories/ (impl)
      domain/          entities/, repositories/ (contracts)
      presentation/    providers/, screens/, widgets/
    settings/
      data/            settings_repository.dart
      presentation/    theme_mode_controller.dart, widgets/
  shared/widgets/      LoadingView, ErrorView, EmptyView, NotFoundView
test/                  mirrors lib/
```

### Dependency rules

```
presentation  -->  domain  <--  data
      \             |            /
       +----------> core <------+
```

- `presentation` talks to repositories only. It never imports `package:dio` or `core/storage`.
- `domain` imports nothing from Flutter, Dio, or JSON packages. Plain Dart: entities and repository contracts.
- `data` implements the domain contracts and is the only place that knows about HTTP and JSON.
- `core` can be used by every layer.
- Wiring providers (`postsRepositoryProvider`) live in `data/` next to their implementation and expose the domain type.

### The domain layer is optional

Create `domain/` only when there are entities or contracts worth abstracting.

- **`posts` has a `domain/`**: a `Post` entity and an `abstract interface class PostsRepository`. The data layer maps `PostDto` to `Post` so the domain never sees JSON.
- **`settings` has no `domain/`**: just `data/` (a concrete `SettingsRepository` wrapping `AppPreferences` and working with `ThemeMode`) and `presentation/` (`ThemeModeController`). Flow: `presentation -> repository -> core/storage`. This is the template for any new preference.

### No UseCase classes by default

Presentation providers call the repository directly. Add a use case under `domain/` only when a feature has real business logic that does not belong in a repository. Treat it as the exception, not the rule.

### DTO is not the entity

`data/models/*_dto.dart` holds the wire format and a `toEntity()` method. Entities live in `domain/entities/`.

### Canonical templates

Constructors use the Dart 3.13 declaration form `const new(...)`. The lint `unnecessary_type_name_in_constructor` is enabled with no exceptions, so do not write `const Foo(...)`.

Freezed 4 models use primary-constructor syntax. An entity (`domain/entities/post.dart`):

```dart
@freezed
class const Post({
  required final int id,
  required final int userId,
  required final String title,
  required final String body,
}) with _$Post;
```

A DTO adds an explicit `@JsonSerializable()` and a `factory fromJson` in the class body (`data/models/post_dto.dart`):

```dart
@freezed
@JsonSerializable()
class const PostDto({
  required final int id,
  // ...
}) with _$PostDto {
  factory fromJson(Map<String, dynamic> json) => _$PostDtoFromJson(json);

  Post toEntity() => Post(id: id, /* ... */);
}
```

A regular class:

```dart
class PostsRepositoryImpl implements PostsRepository {
  const new(this._remote);

  final PostsRemoteDataSource _remote;
}
```

## State and dependency injection (Riverpod)

Providers are the dependency graph. There is no get_it, no global singleton and no static service instance. Everything is a `@riverpod` function or class, generated by `riverpod_generator`.

- **Naming.** The function or class name decides the provider name: `postsList` becomes `postsListProvider`, `postDetail(Ref ref, int id)` becomes `postDetailProvider(id)`, `ThemeModeController` becomes `themeModeControllerProvider`.
- **Where they live.** Wiring providers (`dioProvider`, `postsRemoteDataSourceProvider`, `postsRepositoryProvider`) sit next to the class they build. UI-facing providers go in `presentation/providers/`.
- **keepAlive policy.** Process-wide singletons use `@Riverpod(keepAlive: true)`: `dioProvider`, `appPreferencesProvider`, `settingsRepositoryProvider`, `routerProvider`, and the theme providers. Everything else is auto-dispose, which is the default: data sources, repositories, and screen data such as `postsListProvider` and `postDetailProvider`. When a screen is left, its data is released and refetched next time.
- **Startup values.** `main()` reads the saved theme before `runApp` and injects it with a `ProviderScope` override (`initialThemeModeProvider`), so there is no theme flicker. Use the same pattern for any preference needed at boot.
- **Async data.** Providers return `Future<T>`; screens `watch` them and switch on the `AsyncValue` (loading, error, data). The Retry button calls `ref.invalidate(...)`.

### Auto-retry is disabled

Riverpod 3 retries failed providers automatically. This project turns that off with `retry: (_, _) => null` on the `ProviderScope` in `main()` and on every test `ProviderScope` and `ProviderContainer`. Reasons: the UI has an explicit Retry button, and errors must surface at once and the same way every time (so tests are deterministic and the user is never left watching a spinner while hidden retries run). Keep it when you add scopes or containers.

### Overriding in tests

Override a provider to swap its dependency; no global mocks needed:

```dart
ProviderContainer.test(
  retry: (_, _) => null,
  overrides: [postsRepositoryProvider.overrideWithValue(repo)],
);
```

`Override` is imported from `package:flutter_riverpod/misc.dart` when you need to name the type.

## Error handling

Errors are typed exceptions, not `Result` or `Either`. Riverpod already captures thrown errors in `AsyncError`.

- `sealed class AppException` (`lib/core/error/app_exception.dart`) has the subtypes `NetworkException` (no connection or timeout), `ServerException(statusCode)`, `NotFoundException` (404), `ParsingException` and `UnknownException`.
- Data sources wrap every network call in `guardApiCall(() async { ... })` (`lib/core/network/guard_api_call.dart`). It is the single place that translates `DioException` and decoding failures (`TypeError`, `FormatException`, `CheckedFromJsonException`) into an `AppException`. Repositories and everything above only ever see `AppException`.
- In presentation, `errorMessage(error, l10n)` (`lib/l10n/l10n.dart`) maps an error to a localized message with an exhaustive `switch` over the sealed type. Adding a subtype is a compile error until the mapping handles it. Any non-`AppException` maps to the generic unknown message.
- `ErrorView` (in `shared/widgets`) shows that message with a Retry button.

```dart
// data source
Future<PostDto> fetchPost(int id) => guardApiCall(() async {
  final response = await _dio.get<dynamic>('/posts/$id');
  return PostDto.fromJson(response.data as Map<String, dynamic>);
});
```

## Localization

English and Spanish through `flutter_localizations`, `intl` and `gen_l10n`. Locales are `[en, es]`, the fallback is `en`, and the app follows the device locale. No user-facing string may live outside the ARB files. (Content that comes from the API, like post text, is not translated.)

To add a string:

1. Add the key to `lib/l10n/app_en.arb` (the template), with an `@key` block for placeholders.
2. Add the same key to `lib/l10n/app_es.arb`.
3. Run `fvm flutter gen-l10n` (or `fvm flutter pub get`, which also generates).
4. Use it as `context.l10n.yourKey` (import `package:flutter_starter/l10n/l10n.dart`).
5. Commit the regenerated `app_localizations*.dart`.

When you build a `MaterialApp`, `localizationsDelegates` must be `[AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates]`. See `lib/app/app.dart` and `test/helpers/pump_app.dart`.

Import Material from `package:material_ui/material_ui.dart`; `package:flutter/material.dart` is deprecated in Flutter 3.50.

## Preferences

Preferences follow one pattern, shown by the theme mode:

1. **`AppPreferences`** (`lib/core/storage/app_preferences.dart`) wraps `SharedPreferencesAsync` with typed methods per key. It stores primitives only (the theme is saved as its name string).
2. **A repository** (`features/settings/data/settings_repository.dart`) maps primitives to app types (`ThemeMode`, falling back to `ThemeMode.system` for missing or unknown values). Only repositories touch `AppPreferences`.
3. **A controller** (`features/settings/presentation/theme_mode_controller.dart`), a `@riverpod` Notifier, holds the current value, updates `state` immediately and then persists through the repository.
4. If the value is needed at boot, `main()` reads it through the repository and overrides an `initial...Provider`.

To add a preference: add a key plus getter/setter to `AppPreferences`, map it in a repository, expose a controller.

## Testing

`test/` mirrors `lib/`. Mocks use `mocktail`. Each layer has a template to copy:

| Layer | Template |
|---|---|
| DTO and mapping | `test/features/posts/data/post_dto_test.dart` |
| Data source with mocked Dio, `DioException` to `AppException` | `posts_remote_data_source_test.dart`, `guard_api_call_test.dart` |
| Repository | `posts_repository_impl_test.dart`, `settings_repository_test.dart` |
| Provider with overridden repository | `posts_providers_test.dart` |
| Controller persistence | `theme_mode_controller_test.dart` |
| Widget (loading, error with retry, data) | `posts_screen_test.dart` |
| Localization (EN and ES) | `test/l10n/l10n_test.dart` |

- **`pumpApp`** (`test/helpers/pump_app.dart`) pumps a widget inside a `ProviderScope` (retry disabled) and a `MaterialApp` with the localization delegates and a configurable `locale`. Pass `overrides:` to swap providers.
- **`ProviderContainer.test`** creates a container that is disposed automatically. Always pass `retry: (_, _) => null`.
- **Mocks**: `class _MockPostsRepository extends Mock implements PostsRepository;`, then stub with `when(() => repo.getPosts())` and inject through `overrideWithValue`.

Run everything with `fvm flutter test`.

## How to add a new feature

Example: a `comments` feature that reads from the API.

1. **Folder**: `lib/features/comments/` with `data/`, `presentation/`, and `domain/` only if you have entities or contracts to abstract (see "The domain layer is optional").
2. **Entity and contract** (if domain): a Freezed entity and an `abstract interface class CommentsRepository`.
3. **DTO**: `data/models/comment_dto.dart` with `@freezed @JsonSerializable()`, `fromJson` and `toEntity()`.
4. **Data source**: `data/datasources/...`, calling `ref.watch(dioProvider)` and wrapping calls in `guardApiCall`. Add its `@riverpod` provider.
5. **Repository implementation** and its `@riverpod` provider, typed as the domain contract.
6. **UI providers**: `presentation/providers/..._providers.dart` calling the repository.
7. **Screen**: a `ConsumerWidget` that handles loading (`LoadingView`), error (`ErrorView` with `errorMessage` and `ref.invalidate`), empty (`EmptyView`) and data.
8. **Route**: add a path constant to `AppRoutes` and a `GoRoute` in `lib/app/router.dart`.
9. **Strings**: add keys to both ARB files.
10. **Generate**: `fvm dart run build_runner build -d`, then commit the generated files.
11. **Tests**: copy the templates above for each layer you added.
12. **Check**: `fvm dart format .`, `fvm flutter analyze`, `fvm flutter test`.

A new preference follows "Preferences" instead and usually needs only `data/` and `presentation/`.

## Renaming the project

The package is `flutter_starter`, the org `com.example`.

1. Rename the package in `pubspec.yaml` (`name:`) and replace `package:flutter_starter/` with `package:your_app/` in every file under `lib/` and `test/`.
2. Android: change `namespace` and `applicationId` in `android/app/build.gradle*`, and move `MainActivity.kt` to the matching directory under `android/app/src/main/kotlin/` with an updated `package` line.
3. iOS: change `PRODUCT_BUNDLE_IDENTIFIER` (and the `RunnerTests` one) in `ios/Runner.xcodeproj/project.pbxproj`, and the display name in `ios/Runner/Info.plist`.
4. Change `appTitle` in both ARB files, then regenerate.
5. Run `fvm flutter clean && fvm flutter pub get && fvm dart run build_runner build -d` and the full check.

## CI

`.github/workflows/ci.yml` runs on pushes and pull requests to `main`. It reads the Flutter version from `.fvmrc`, then runs: `pub get`, `build_runner build -d`, a clean-tree check (`git status --porcelain` must print nothing, so generated files must be committed and up to date; on failure it prints the offending files), `dart format --set-exit-if-changed .`, `flutter analyze`, `flutter test`. Superseded runs on the same ref are cancelled.

Run the same sequence locally before pushing (commit your work first, or the clean-tree check fails on it):

```sh
fvm flutter pub get && fvm dart run build_runner build -d && test -z "$(git status --porcelain)" \
  && fvm dart format --set-exit-if-changed . && fvm flutter analyze && fvm flutter test
```

## Lint and dependency notes

- Lints: `very_good_analysis`, plus `riverpod_lint`. `riverpod_lint` runs through the analyzer `plugins:` section in `analysis_options.yaml` (the analysis server plugin mechanism), not `custom_lint`. Generated files and `lib/l10n/app_localizations*.dart` are excluded from analysis. `public_member_api_docs` is off because this is an app, not a package.
- Dependency versions were resolved by `flutter pub add` (latest compatible). No dependency conflicts occurred, so no fallbacks were applied: `riverpod_generator`, Freezed, `json_serializable`, `riverpod_lint` and `very_good_analysis` are all in use at their latest versions. If a future analyzer conflict appears, keep `riverpod_generator` + Freezed + `json_serializable`, drop `riverpod_lint` first, then downgrade `very_good_analysis`, and record the reason here.
- The only lint suppression in hand-written code is `avoid_catching_errors` in `lib/core/network/guard_api_call.dart`. Catching `TypeError` there is deliberate: a failed cast while decoding JSON surfaces as one, and it must become a `ParsingException`. Do not add suppressions elsewhere without a comment explaining why.
- Dio uses a 10 s connect timeout and a 15 s receive timeout, and a `LogInterceptor` in debug mode only.
