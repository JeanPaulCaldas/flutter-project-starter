# Design: Flutter Project Starter (team baseline)

## Context and intent

The `flutter-project-starter` repo is empty (initial commit only). The goal is a **Flutter project baseline that a dev team will use as its standard** for starting new apps. Target apps are simple and consume HTTP APIs; no caching for now.

Because a team will use it, the main criterion is: **predictable, one obvious way to do each thing, easy to test and easy to read for a newcomer** — over minimizing lines of code.

The project ships a sample app that demonstrates the pattern end to end: a home screen that GETs a free public API and renders the data with loading and error states.

All code, comments, documentation and commit messages are in **English**. The app is localized in **English and Spanish**.

Environment: fvm is installed (global = stable). Dart 3.12+ (sealed classes, pattern matching, dot shorthands available).

## Goals

- Three clear layers — **presentation / domain / data** — organized **by feature**.
- A decided standard stack (below) with a documented convention for each piece.
- A complete sample feature: API → DTO → entity → repository → provider → UI with loading/error/data/retry.
- Persisted preferences, demonstrated by a real feature (light/dark/system theme).
- Localization (EN, ES) wired from day one, including error messages.
- Sample tests in each layer that serve as templates for the team.
- A README explaining the architecture, conventions and "how to add a new feature".

## Non-goals

- Caching / offline mode / local database.
- Authentication, native flavors (Android productFlavors / iOS schemes), analytics, crash reporting.
- In-app language picker (the app follows the device locale).
- Use case / interactor classes by default (see decisions).

## Anti-goals (failure even if it works)

- Adding a simple feature requires touching lots of "plumbing" files or empty layers with no purpose.
- The domain depends on Dio, JSON or Flutter.
- Two ways of doing the same thing (e.g. DI via providers *and* via a global singleton; UI reading storage directly *and* via repositories).
- Hard-coded user-facing strings outside the ARB files.
- The sample doesn't build or tests fail after cloning (`fvm flutter pub get && fvm dart run build_runner build && fvm flutter test` must pass clean).

## Approaches considered

| Approach | Trade-offs | Decision |
|---|---|---|
| **A. Riverpod 3 (with `riverpod_generator`)** for state + DI | One library for two problems; `AsyncValue` gives loading/error/data for free; tests via `overrides`, no global mocks. Somewhat steeper curve; needs conventions. | **Chosen by the user** |
| B. Cubit (flutter_bloc) + get_it | Very explicit, `bloc_test`. Two libraries, hand-written loading/error states per screen, get_it is a global service locator. | Rejected |
| C. Riverpod 3 without the generator | Less build_runner, but build_runner is needed anyway for Freezed; the generator is Riverpod's recommended syntax. | Rejected |

Ruled out upfront: Provider (superseded by Riverpod), zero codegen (hand-written JSON/copyWith doesn't scale for a team).

## Decisions made with the user

- **State + dependency injection:** Riverpod 3 + `riverpod_annotation` / `riverpod_generator`. Providers *are* the dependency graph; no get_it, no global singletons.
- **HTTP:** Dio.
- **Preferences:** `shared_preferences`.
- **Immutable models:** Freezed 3 (+ `json_serializable` for DTOs).
- **Layers:** presentation, domain, data.
- **Layering rule — domain is optional.** Presentation only talks to repositories and never touches `AppPreferences` or Dio directly. A `domain/` folder exists only when there are entities or contracts worth abstracting (as in `posts`). `settings` has only `data/` (a concrete `SettingsRepository` wrapping `AppPreferences`, working with `ThemeMode`) and `presentation/` (`ThemeModeController`, a `@riverpod` Notifier). This is the template for any new preference. Flow: `presentation → repository → core/storage`.
- **Flutter version:** latest stable, pinned via fvm (`.fvmrc`), resolved at project creation time.
- **Localization:** EN and ES.
- **Language:** project, code and all documentation in English.

## Designer's calls (correctable)

- **Sample API: JSONPlaceholder** (`https://jsonplaceholder.typicode.com`), `GET /posts` for the list and `GET /posts/{id}` for detail. Free, no API key, stable, simple JSON. A detail screen is included to demonstrate navigation with parameters and a second (family) provider. Post content from the API is Latin placeholder text and is not translated — only UI chrome is localized.
- **Navigation: `go_router`**, with simple path constants (no `go_router_builder`, to avoid another generator). De facto standard and something a team needs on day one.
- **Localization mechanics:** official `flutter_localizations` + `intl` + `gen_l10n` (`l10n.yaml`, ARB files in `lib/l10n/` — `app_en.arb` as template, `app_es.arb`). Generated localization code is produced by `flutter gen-l10n` (synthetic package disabled / output into `lib/l10n/`, whichever the current Flutter stable supports). A `context.l10n` extension for ergonomic access. Supported locales `[en, es]`, fallback `en`, follows device locale. Error messages are localized by mapping `AppException` → string in presentation via an exhaustive `switch`.
- **Preferences:** `SharedPreferencesAsync` (the newer recommended API), wrapped in an `AppPreferences` class in `core/storage` (typed methods per key), exposed via a provider and consumed **only** by repositories. The `settings` feature persists `ThemeMode` (system/light/dark) and applies it in `MaterialApp`.
- **Theme at startup:** `main()` reads the saved theme before `runApp` and injects it as the initial value (a `ProviderScope` override). No theme flicker, and the pattern works for any preference needed at boot.
- **No UseCase classes.** The domain holds **entities** (Freezed, no JSON) and **repository contracts** (`abstract interface class`). Presentation providers call the repository directly. If a feature has real business logic, a use case is added under `domain/` — documented in the README as the exception, not the rule.
- **DTO ≠ entity.** `data/models/*_dto.dart` (Freezed + `fromJson`) with a `toEntity()` method. The domain never sees JSON.
- **Errors: typed exceptions, not `Result`/`Either`.** `sealed class AppException implements Exception` in `core/error/` with subtypes: `NetworkException` (no connection/timeout), `ServerException(statusCode)`, `NotFoundException`, `ParsingException`, `UnknownException`. The data layer translates `DioException` → `AppException` at a single point (helper/extension used by data sources). Repositories throw `AppException`; Riverpod captures them in `AsyncError`. Idiomatic with `AsyncValue`, less boilerplate than Either, exhaustive thanks to `sealed`.
- **Environment config:** `--dart-define-from-file=config/dev.json` with `BASE_URL`; an `Env` class reads `String.fromEnvironment`, defaulting to JSONPlaceholder so `flutter run` works without flags. No native flavors.
- **Dio:** a `dioProvider` (keepAlive) configured with baseUrl, timeouts and `LogInterceptor` in debug only.
- **Lints:** `very_good_analysis` (strict, good for teams) + `riverpod_lint` if compatible with the installed Riverpod/analyzer versions.
- **Package versions:** let `flutter pub add` resolve the latest compatible versions, no manual pinning. If `analyzer` conflicts between codegen packages and lints: **riverpod_generator + Freezed + json_serializable are non-negotiable**; drop `riverpod_lint` first, then downgrade `very_good_analysis` (or use `flutter_lints`), and note why in the README.
- **Testing:** `mocktail`. Minimal templates:
  - data: data source/repository with mocked Dio → DTO→entity mapping and `DioException`→`AppException`.
  - presentation: provider via `ProviderContainer` + repository override (success and error).
  - widget: home screen renders loading, error (with retry button) and list; pumped with localization delegates (test at least one string in both EN and ES).
  - settings: repository with mocked `AppPreferences`; controller persists on change.
- **CI:** minimal GitHub Actions workflow using the Flutter version from `.fvmrc`: `pub get`, `build_runner build` + `git diff --exit-code` (generated files up to date), `dart format --set-exit-if-changed`, `flutter analyze`, `flutter test`.
- **Generated files (`*.g.dart`, `*.freezed.dart`, l10n output) are committed** so the project builds on clone and PR diffs show generation changes. (Correctable if the team prefers ignoring them.)
- **Name/platforms:** package `flutter_starter`, org `com.example`, `flutter create --platforms=android,ios` (no web/desktop). README explains how to rename.

## Proposed structure

```
lib/
  main.dart                      # read initial prefs, ProviderScope + runApp
  app/
    app.dart                     # MaterialApp.router, themeMode, l10n delegates
    router.dart                  # go_router provider + routes
    theme.dart                   # light/dark ThemeData (Material 3)
  core/
    config/env.dart
    error/app_exception.dart     # sealed + mapping from DioException
    network/dio_provider.dart
    storage/app_preferences.dart # SharedPreferencesAsync wrapper + provider
  l10n/
    app_en.arb  app_es.arb  (+ generated localizations)
    l10n_extensions.dart         # context.l10n, AppException → message
  features/
    posts/
      data/
        datasources/posts_remote_data_source.dart
        models/post_dto.dart
        repositories/posts_repository_impl.dart
      domain/
        entities/post.dart
        repositories/posts_repository.dart
      presentation/
        providers/posts_providers.dart   # postsList, postDetail(id)
        screens/posts_screen.dart        # home screen
        screens/post_detail_screen.dart
        widgets/...
    settings/                    # no domain/ (see layering rule)
      data/settings_repository.dart
      presentation/theme_mode_controller.dart
  shared/widgets/                # LoadingView, ErrorView(retry), etc.
test/  (mirrors lib/)
config/dev.json
l10n.yaml
.fvmrc
.github/workflows/ci.yml
README.md
```

Dependency rules: `presentation → domain ← data`; `core` usable by all; `domain` has no Flutter/Dio imports. Wiring providers (`postsRepositoryProvider`) live in `data/` next to their implementation and expose the domain type.

## Sample screen flow

```
PostsScreen (ConsumerWidget)
  ref.watch(postsListProvider)  ── AsyncLoading → LoadingView
                                ── AsyncError   → ErrorView(localized message by type, "Retry" → ref.invalidate)
                                ── AsyncData    → ListView (title, excerpt) → tap → /posts/:id
  AppBar: action to change theme (system/light/dark) → persisted in preferences
  Pull-to-refresh → ref.refresh
```

## Left to the builder

- Concrete visual design of list/detail/error views (Material 3, understated).
- Exact file/class names within the structure.
- UI copy (EN and ES).
- Exact README content following the points above.

## Next steps

1. Design approved on 2026-11-23.
2. Write the implementation plan (TDD per layer).

## Verification

1. `fvm flutter pub get && fvm dart run build_runner build -d` with no errors.
2. `dart format --set-exit-if-changed .` and `flutter analyze` clean.
3. `flutter test` passes (data, provider, widget, settings, l10n).
4. `fvm flutter run` on a simulator: list loads; airplane mode → ErrorView with working retry; tap → detail; theme change persists across app restarts; switching device language to Spanish shows Spanish UI.
