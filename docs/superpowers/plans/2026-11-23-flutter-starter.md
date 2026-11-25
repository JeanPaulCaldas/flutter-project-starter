# Flutter Starter Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a team-standard Flutter baseline with a feature-first presentation/domain/data architecture and a sample "posts" app (JSONPlaceholder) with loading/error/empty/data states, persisted theme preference, and EN/ES localization.

**Architecture:** Feature folders (`features/<name>/{data,domain,presentation}`), `domain/` only when it holds entities or contracts. Riverpod 3 providers (via `riverpod_generator`) are the only DI mechanism and the only state mechanism. The data layer converts all Dio/parsing failures into a sealed `AppException`. Presentation maps those to localized messages.

**Tech Stack:** Flutter 3.50.1 (fvm), Dart ≥3.13, flutter_riverpod 3 + riverpod_annotation/riverpod_generator 4, dio 5, shared_preferences 2 (`SharedPreferencesAsync`), freezed 4 / freezed_annotation 3, json_serializable 6, go_router 18, flutter_localizations + intl (gen_l10n), very_good_analysis, riverpod_lint (analysis_server_plugin), mocktail.

**Spec:** `docs/superpowers/specs/2026-11-23-flutter-starter-design.md`

## Global Constraints

- Flutter pinned to **3.50.1** via fvm (`.fvmrc`); every command in this plan runs through `fvm` (`fvm flutter …`, `fvm dart …`).
- Package: `flutter_starter`, org `com.example`, platforms `android,ios` only.
- All code, comments, docs and commit messages in **English**. Commits use Conventional Commits and end with `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
- No user-facing string outside `lib/l10n/app_en.arb` / `app_es.arb`. Locales `[en, es]`, fallback `en`, follows device locale.
- `domain/` imports nothing from Flutter, Dio, or JSON packages. `presentation/` never imports `package:dio` or `core/storage`.
- DI only through Riverpod providers — no get_it, no global singletons, no static service instances.
- Dependency versions resolved by `flutter pub add` (latest compatible). On analyzer conflicts: keep riverpod_generator + freezed + json_serializable; drop `riverpod_lint` first, then downgrade `very_good_analysis`; record the reason in README.
- Generated files (`*.g.dart`, `*.freezed.dart`, `lib/l10n/app_localizations*.dart`) are committed.
- **Riverpod's automatic retry is disabled** in the app's `ProviderScope` and in every test container/scope (`retry: (_, _) => null`). Rationale (plan-level call): the UI has an explicit Retry button, and errors must surface at once and the same way every time.
- Dio timeouts: connect **10 s**, receive **15 s**. Base URL default `https://jsonplaceholder.typicode.com`.

## Review Focus

1. **Detail for a missing post (`GET /posts/999` → 404 `{}`)** must show the localized "not found" message, not a generic or parsing error. Pinned in Task 5 (data source) and Task 7 (detail screen).
2. **Malformed or unexpected JSON** (object instead of list, missing/ill-typed field) must become `ParsingException` → localized message, never an uncaught `TypeError`. Pinned in Task 5.
3. **Bad route parameter** (`/posts/abc`, unknown path) must render the localized "page not found" view, not crash. Pinned in Task 9.
4. **Empty list from the API** must show an empty-state message, not a blank screen. Pinned in Task 7.
5. **Unknown/corrupted stored theme value** must fall back to `ThemeMode.system`. Pinned in Task 8.

---

## File Structure

```
.fvmrc  .gitignore  analysis_options.yaml  l10n.yaml  pubspec.yaml  README.md
config/dev.json
.github/workflows/ci.yml
lib/
  main.dart
  app/{app.dart, router.dart, theme.dart}
  core/config/env.dart
  core/error/app_exception.dart          # sealed AppException + DioException mapping
  core/network/{dio_provider.dart, guard_api_call.dart}
  core/storage/app_preferences.dart
  l10n/{app_en.arb, app_es.arb, app_localizations*.dart (generated), l10n.dart}
  shared/widgets/{loading_view.dart, error_view.dart, empty_view.dart}
  features/posts/
    domain/entities/post.dart
    domain/repositories/posts_repository.dart
    data/models/post_dto.dart
    data/datasources/posts_remote_data_source.dart
    data/repositories/posts_repository_impl.dart
    presentation/providers/posts_providers.dart
    presentation/screens/{posts_screen.dart, post_detail_screen.dart}
    presentation/widgets/post_tile.dart
  features/settings/
    data/settings_repository.dart
    presentation/theme_mode_controller.dart
    presentation/widgets/theme_mode_menu_button.dart
test/ (mirrors lib/) + test/helpers/pump_app.dart
```

---

### Task 1: Project scaffold and toolchain

**Files:**
- Create: `.fvmrc`, `pubspec.yaml`, `analysis_options.yaml`, `config/dev.json`, `lib/core/config/env.dart`, `lib/main.dart` (placeholder)
- Modify: `.gitignore`
- Delete: default counter app in `lib/main.dart` body, `test/widget_test.dart`
- Test: `test/core/config/env_test.dart`

**Interfaces:**
- Produces: `abstract final class Env { static const String baseUrl; }`, which reads `String.fromEnvironment('BASE_URL', defaultValue: 'https://jsonplaceholder.typicode.com')`.

- [ ] **Step 1: Install and scaffold**

```bash
fvm install 3.50.1
~/fvm/versions/3.50.1/bin/flutter create --org com.example --project-name flutter_starter --platforms=android,ios .
fvm use 3.50.1 --force
```
Expected: `.fvmrc` contains `"flutter": "3.50.1"`; add `.fvm/` to `.gitignore`.

- [ ] **Step 2: Add dependencies**

```bash
fvm flutter pub add flutter_riverpod riverpod_annotation dio shared_preferences freezed_annotation json_annotation go_router intl 'flutter_localizations:{"sdk":"flutter"}'
fvm flutter pub add -d build_runner riverpod_generator freezed json_serializable very_good_analysis riverpod_lint mocktail shared_preferences_platform_interface
```
Add `generate: true` under `flutter:` in `pubspec.yaml`. If resolution fails, apply the conflict rule from Global Constraints.

- [ ] **Step 3: Configure analysis**

`analysis_options.yaml`: `include: package:very_good_analysis/analysis_options.yaml`; `analyzer.exclude` for `**/*.g.dart`, `**/*.freezed.dart`, `lib/l10n/app_localizations*.dart`; disable `public_member_api_docs` (this is an app); enable riverpod_lint via the top-level `plugins:` section (`riverpod_lint: ^<resolved version>`), following riverpod_lint's README for analysis_server_plugin.

`config/dev.json`: `{ "BASE_URL": "https://jsonplaceholder.typicode.com" }`.

- [ ] **Step 4: Write the failing test** `test/core/config/env_test.dart`

```dart
test('baseUrl defaults to JSONPlaceholder', () {
  expect(Env.baseUrl, 'https://jsonplaceholder.typicode.com');
});
```

- [ ] **Step 5: Run it, expect FAIL** — `fvm flutter test test/core/config/env_test.dart` → compile error, `Env` undefined.

- [ ] **Step 6: Implement `Env`** in `lib/core/config/env.dart`. Replace the counter app in `lib/main.dart` with a minimal `runApp(const SizedBox.shrink())` placeholder (Task 9 replaces it). Delete `test/widget_test.dart`.

- [ ] **Step 7: Verify**

Run: `fvm flutter test && fvm flutter analyze && fvm dart format --set-exit-if-changed .`
Expected: all pass, `No issues found!`

- [ ] **Step 8: Commit** — `chore: scaffold Flutter 3.50.1 project with toolchain and lints`

---

### Task 2: AppException and Dio error mapping

**Files:**
- Create: `lib/core/error/app_exception.dart`
- Test: `test/core/error/app_exception_test.dart`

**Interfaces:**
- Produces:
  - `sealed class AppException implements Exception`, with subclasses `NetworkException()`, `ServerException(int? statusCode)`, `NotFoundException()`, `ParsingException([Object? cause])` and `UnknownException([Object? cause])`. All have `const` constructors where possible.
  - `extension DioExceptionMapper on DioException { AppException toAppException(); }`

- [ ] **Step 1: Write failing tests** (one per mapping, using `DioException(requestOptions: RequestOptions(), type: …, response: Response(requestOptions: RequestOptions(), statusCode: …))`):
  - `connectionTimeout`, `sendTimeout`, `receiveTimeout`, `connectionError` → `isA<NetworkException>()`
  - `badResponse` + 404 → `isA<NotFoundException>()`
  - `badResponse` + 500 → `isA<ServerException>().having((e) => e.statusCode, 'statusCode', 500)`
  - `unknown` with `error: const SocketException('x')` → `isA<NetworkException>()`
  - `unknown` with any other error, `cancel` and `badCertificate` → `isA<UnknownException>()`

- [ ] **Step 2: Run, expect FAIL** — `fvm flutter test test/core/error/` → undefined names.

- [ ] **Step 3: Implement** with an exhaustive `switch` over `type`.

- [ ] **Step 4: Run, expect PASS.**

- [ ] **Step 5: Commit** — `feat(core): add sealed AppException with Dio error mapping`

---

### Task 3: Dio provider and API guard

**Files:**
- Create: `lib/core/network/dio_provider.dart`, `lib/core/network/guard_api_call.dart`
- Test: `test/core/network/dio_provider_test.dart`, `test/core/network/guard_api_call_test.dart`

**Interfaces:**
- Consumes: `Env.baseUrl`, `DioExceptionMapper`.
- Produces:
  - `@Riverpod(keepAlive: true) Dio dio(Ref ref)` → `dioProvider`. It sets baseUrl, connect 10 s, receive 15 s and `Accept: application/json`, and adds `LogInterceptor` only when `kDebugMode`.
  - `Future<T> guardApiCall<T>(Future<T> Function() call)`. This is the **single place** that converts failures: `DioException` → `toAppException()`; `TypeError`, `FormatException` and `CheckedFromJsonException` → `ParsingException(e)`; an `AppException` is rethrown unchanged.

- [ ] **Step 1: Write failing tests**
  - dio: `ProviderContainer.test(retry: (_, _) => null)`, then `container.read(dioProvider).options` should have `baseUrl == Env.baseUrl`, `connectTimeout == const Duration(seconds: 10)`, `receiveTimeout == const Duration(seconds: 15)`.
  - guard: returns the value on success; a `DioException` 404 throws `NotFoundException`; `throw TypeError()` throws `ParsingException`; `throw const FormatException()` throws `ParsingException`; `throw const NetworkException()` is rethrown as-is.

- [ ] **Step 2: Run, expect FAIL.**
- [ ] **Step 3: Implement both; run `fvm dart run build_runner build -d`.**
- [ ] **Step 4: Run, expect PASS.**
- [ ] **Step 5: Commit** — `feat(core): add Dio provider and guardApiCall error boundary`

---

### Task 4: AppPreferences

**Files:**
- Create: `lib/core/storage/app_preferences.dart`
- Test: `test/core/storage/app_preferences_test.dart`

**Interfaces:**
- Produces:
  - `class AppPreferences { AppPreferences(SharedPreferencesAsync prefs); Future<String?> getThemeMode(); Future<void> setThemeMode(String value); }`. The key `'theme_mode'` is a private constant. It stores primitives only; mapping to domain/Flutter types happens in repositories.
  - `@Riverpod(keepAlive: true) AppPreferences appPreferences(Ref ref)` → `appPreferencesProvider`, which returns `AppPreferences(SharedPreferencesAsync())`. `main()` overrides it in Task 9.

- [ ] **Step 1: Write failing tests.** In `setUp`, set `SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty()`. Then: `getThemeMode()` returns `null` initially; after `setThemeMode('dark')`, `getThemeMode()` returns `'dark'`.
- [ ] **Step 2: Run, expect FAIL.**
- [ ] **Step 3: Implement; run build_runner.**
- [ ] **Step 4: Run, expect PASS.**
- [ ] **Step 5: Commit** — `feat(core): add AppPreferences wrapper over SharedPreferencesAsync`

---

### Task 5: Posts domain and data layer

**Files:**
- Create: `lib/features/posts/domain/entities/post.dart`, `.../domain/repositories/posts_repository.dart`, `.../data/models/post_dto.dart`, `.../data/datasources/posts_remote_data_source.dart`, `.../data/repositories/posts_repository_impl.dart`
- Test: `test/features/posts/data/post_dto_test.dart`, `.../posts_remote_data_source_test.dart`, `.../posts_repository_impl_test.dart`

**Interfaces:**
- Consumes: `dioProvider`, `guardApiCall`, `AppException` subtypes.
- Produces:
  - `@freezed abstract class Post with _$Post { const factory Post({required int id, required int userId, required String title, required String body}) = _Post; }` (no JSON)
  - `abstract interface class PostsRepository { Future<List<Post>> getPosts(); Future<Post> getPost(int id); }`
  - `PostDto` (Freezed + `fromJson`, same four fields) with `Post toEntity()`
  - `class PostsRemoteDataSource { PostsRemoteDataSource(Dio dio); Future<List<PostDto>> fetchPosts(); Future<PostDto> fetchPost(int id); }`. Both wrap their body in `guardApiCall`. Paths are `/posts` and `/posts/$id`.
  - `class PostsRepositoryImpl implements PostsRepository { PostsRepositoryImpl(PostsRemoteDataSource remote); }`
  - Providers (in the data files): `postsRemoteDataSourceProvider`, and `@riverpod PostsRepository postsRepository(Ref ref)` → `postsRepositoryProvider` (typed as the domain interface).

- [ ] **Step 1: Write failing tests** (mock `Dio` with mocktail and stub `dio.get<dynamic>(path)`):
  - DTO: `PostDto.fromJson({'id': 1, 'userId': 2, 'title': 't', 'body': 'b'}).toEntity() == const Post(id: 1, userId: 2, title: 't', body: 'b')`.
  - `fetchPosts` returns 2 DTOs from a 2-item JSON list.
  - **Review Focus #2:** `fetchPosts` with response data `{'not': 'a list'}` throws `ParsingException`; `fetchPost` with `{'id': 'x'}` (ill-typed) throws `ParsingException`.
  - **Review Focus #1:** `fetchPost(999)` when Dio throws `badResponse` with 404 throws `NotFoundException`.
  - `fetchPosts` when Dio throws `connectionError` throws `NetworkException`.
  - Repository: `getPosts()` maps DTOs to entities; it propagates `AppException` unchanged (mock the data source).

- [ ] **Step 2: Run, expect FAIL.**
- [ ] **Step 3: Implement; run build_runner.** Verify that `domain/` has no `package:flutter`, `package:dio` or `json_annotation` imports: `grep -rE "package:(flutter|dio|json_annotation)" lib/features/posts/domain` returns nothing (Freezed's `freezed_annotation` is allowed).
- [ ] **Step 4: Run, expect PASS.**
- [ ] **Step 5: Commit** — `feat(posts): add domain entities and data layer for JSONPlaceholder`

---

### Task 6: Localization, error messages, shared widgets, test helper

**Files:**
- Create: `l10n.yaml`, `lib/l10n/app_en.arb`, `lib/l10n/app_es.arb`, `lib/l10n/l10n.dart`, `lib/shared/widgets/{loading_view,error_view,empty_view}.dart`, `test/helpers/pump_app.dart`
- Test: `test/l10n/l10n_test.dart`, `test/shared/widgets/error_view_test.dart`

**Interfaces:**
- Consumes: `AppException` subtypes.
- Produces:
  - `l10n.yaml`: `arb-dir: lib/l10n`, `template-arb-file: app_en.arb`, `output-localization-file: app_localizations.dart`, `nullable-getter: false` (generated into `lib/l10n/`).
  - ARB keys (EN/ES copy is the builder's choice except the pinned values): `appTitle`, `postsTitle` (**EN "Posts", ES "Publicaciones"**), `postDetailTitle`, `retry` (**EN "Retry", ES "Reintentar"**), `emptyPosts`, `errorNetwork`, `errorServer` (placeholder `{statusCode}`), `errorNotFound`, `errorParsing`, `errorUnknown`, `pageNotFound`, `themeSystem`, `themeLight`, `themeDark`, `themeMenuTooltip`.
  - `lib/l10n/l10n.dart`: re-exports `app_localizations.dart`; `extension AppLocalizationsX on BuildContext { AppLocalizations get l10n; }`; `String errorMessage(Object error, AppLocalizations l10n)` uses an exhaustive switch on `AppException`, and any non-`AppException` maps to `errorUnknown`.
  - `LoadingView()`, `ErrorView({required String message, required VoidCallback onRetry})` (shows the message and a button labeled `l10n.retry`), `EmptyView({required String message})`.
  - `extension PumpApp on WidgetTester { Future<void> pumpApp(Widget widget, {List<Override> overrides = const [], Locale locale = const Locale('en')}); }` wraps the widget in `ProviderScope(retry: (_, _) => null, overrides: …)` + `MaterialApp(locale:, localizationsDelegates:, supportedLocales:, home: widget)`.

- [ ] **Step 1: Write failing tests**
  - `errorMessage(const NotFoundException(), AppLocalizationsEn())` equals `AppLocalizationsEn().errorNotFound`; same for each subtype; `errorMessage(Exception('x'), …)` equals `errorUnknown`; `ServerException(503)` message contains `'503'`.
  - `ErrorView`: `pumpApp(ErrorView(message: 'boom', onRetry: cb))` shows `'boom'` and `'Retry'`; tapping `'Retry'` calls `cb` once. With `locale: Locale('es')` it shows `'Reintentar'`.
- [ ] **Step 2: Run, expect FAIL.**
- [ ] **Step 3: Implement; run `fvm flutter gen-l10n`** (or `pub get`) and confirm `lib/l10n/app_localizations.dart` exists.
- [ ] **Step 4: Run, expect PASS.**
- [ ] **Step 5: Commit** — `feat(l10n): add EN/ES localization, error messages and shared state views`

---

### Task 7: Posts presentation

**Files:**
- Create: `lib/features/posts/presentation/providers/posts_providers.dart`, `.../screens/posts_screen.dart`, `.../screens/post_detail_screen.dart`, `.../widgets/post_tile.dart`, `lib/app/router.dart` (only `AppRoutes` for now)
- Test: `test/features/posts/presentation/posts_providers_test.dart`, `.../posts_screen_test.dart`, `.../post_detail_screen_test.dart`

**Interfaces:**
- Consumes: `postsRepositoryProvider`, `Post`, `errorMessage`, shared views, `pumpApp`.
- Produces:
  - `@riverpod Future<List<Post>> postsList(Ref ref)` → `postsListProvider`; `@riverpod Future<Post> postDetail(Ref ref, int id)` → `postDetailProvider(id)`.
  - `PostsScreen()` (ConsumerWidget): AppBar title `l10n.postsTitle`; the AppBar `actions` slot is left for Task 8. It uses `switch` on the `AsyncValue`: data → `RefreshIndicator(onRefresh: () => ref.refresh(postsListProvider.future))` + `ListView` of `PostTile`, or `EmptyView(l10n.emptyPosts)` when the list is empty; error → `ErrorView(errorMessage(e, l10n), onRetry: () => ref.invalidate(postsListProvider))`; loading → `LoadingView`.
  - `PostTile({required Post post, required VoidCallback onTap})`. In `PostsScreen`, `onTap` calls `context.push(AppRoutes.postDetailPath(post.id))`. `AppRoutes` is defined in Task 9; for now import `lib/app/router.dart` and create `AppRoutes` there with `static const posts = '/'`, `static const postDetail = '/posts/:id'` and `static String postDetailPath(int id) => '/posts/$id'`.
  - `PostDetailScreen({required int postId})` with the same three states, showing title and body.

- [ ] **Step 1: Write failing tests** (mocktail `MockPostsRepository`, overridden via `postsRepositoryProvider.overrideWithValue`):
  - Provider: `ProviderContainer.test(retry: (_, _) => null, overrides: …)`. `postsListProvider.future` completes with the repo's list; when the repo throws `NetworkException`, the future `throwsA(isA<NetworkException>())`.
  - Screen loading: the repo returns a never-completing `Completer` future, so `LoadingView` is found.
  - Screen error → retry: the first call throws `NetworkException`, then `errorNetwork` text + `'Retry'` show; the second call returns `[post]`; tap Retry + `pumpAndSettle`, then the post title shows; `verify(() => repo.getPosts()).called(2)`.
  - **Review Focus #4:** the repo returns `[]`, so `AppLocalizationsEn().emptyPosts` text shows.
  - Detail: shows title and body of `getPost(1)`. **Review Focus #1:** `getPost(999)` throws `NotFoundException`, so `errorNotFound` text shows.
- [ ] **Step 2: Run, expect FAIL.**
- [ ] **Step 3: Implement; run build_runner.** Check that `presentation/` has no `package:dio` / `core/storage` imports.
- [ ] **Step 4: Run, expect PASS.**
- [ ] **Step 5: Commit** — `feat(posts): add posts list and detail screens with loading/error/empty states`

---

### Task 8: Settings — persisted theme mode

**Files:**
- Create: `lib/features/settings/data/settings_repository.dart`, `.../presentation/theme_mode_controller.dart`, `.../presentation/widgets/theme_mode_menu_button.dart`
- Modify: `lib/features/posts/presentation/screens/posts_screen.dart` (add `ThemeModeMenuButton` to AppBar actions)
- Test: `test/features/settings/settings_repository_test.dart`, `.../theme_mode_controller_test.dart`, `.../theme_mode_menu_button_test.dart`

**Interfaces:**
- Consumes: `AppPreferences`, `appPreferencesProvider`.
- Produces:
  - `class SettingsRepository { SettingsRepository(AppPreferences prefs); Future<ThemeMode> getThemeMode(); Future<void> setThemeMode(ThemeMode mode); }`. It persists `ThemeMode.name`; `null` or an unknown value becomes `ThemeMode.system`. Provider: `settingsRepositoryProvider`.
  - `@Riverpod(keepAlive: true) ThemeMode initialThemeMode(Ref ref) => ThemeMode.system;` (overridden in `main()` with the loaded value).
  - `@Riverpod(keepAlive: true) class ThemeModeController extends _$ThemeModeController`: `ThemeMode build() => ref.watch(initialThemeModeProvider);` plus `Future<void> setThemeMode(ThemeMode mode)`, which updates `state` first and then persists through the repository → `themeModeControllerProvider`.
  - `ThemeModeMenuButton()`: a `PopupMenuButton<ThemeMode>` with tooltip `l10n.themeMenuTooltip` and three items (`themeSystem/Light/Dark`) that calls `setThemeMode`.

- [ ] **Step 1: Write failing tests** (mock `AppPreferences`):
  - Repo: `'dark'` stored gives `ThemeMode.dark`; `null` gives `system`. **Review Focus #5:** `'purple'` gives `system`. `setThemeMode(ThemeMode.light)` calls `prefs.setThemeMode('light')`.
  - Controller: initial state equals the `initialThemeModeProvider` override (`ThemeMode.dark`); after `setThemeMode(ThemeMode.light)`, state is `light` and `verify(() => repo.setThemeMode(ThemeMode.light)).called(1)`.
  - Menu: tap the button (by tooltip), tap `'Dark'`, and the controller state is `ThemeMode.dark`.
- [ ] **Step 2: Run, expect FAIL.**
- [ ] **Step 3: Implement; run build_runner.**
- [ ] **Step 4: Run, expect PASS** — including the Task 7 screen tests unchanged (the controller reads `settingsRepositoryProvider` lazily inside `setThemeMode`, so screens need no extra override).
- [ ] **Step 5: Commit** — `feat(settings): persist theme mode via SettingsRepository and Riverpod controller`

---

### Task 9: App shell — theme, router, main

**Files:**
- Create: `lib/app/theme.dart`, `lib/app/app.dart`
- Modify: `lib/app/router.dart` (add router), `lib/main.dart`
- Test: `test/app/app_test.dart`, `test/app/router_test.dart`

**Interfaces:**
- Consumes: everything above.
- Produces:
  - `abstract final class AppTheme { static ThemeData get light; static ThemeData get dark; }` (Material 3, `ColorScheme.fromSeed`).
  - `@Riverpod(keepAlive: true) GoRouter router(Ref ref)` → `routerProvider`. Routes: `/` → `PostsScreen`; `/posts/:id` → `PostDetailScreen(postId)` if `int.tryParse` succeeds, otherwise `NotFoundView`. `errorBuilder` → `NotFoundView`. `NotFoundView` (private to `router.dart` or in `shared/widgets/`) shows `l10n.pageNotFound`.
  - `App()` (ConsumerWidget): `MaterialApp.router(routerConfig: ref.watch(routerProvider), theme: AppTheme.light, darkTheme: AppTheme.dark, themeMode: ref.watch(themeModeControllerProvider), localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, onGenerateTitle: (c) => c.l10n.appTitle)`.
  - `main()`: `ensureInitialized`; `prefs = AppPreferences(SharedPreferencesAsync())`; `themeMode = await SettingsRepository(prefs).getThemeMode()`; `runApp(ProviderScope(retry: (_, _) => null, overrides: [appPreferencesProvider.overrideWithValue(prefs), initialThemeModeProvider.overrideWithValue(themeMode)], child: const App()))`.

- [ ] **Step 1: Write failing tests** (pump `ProviderScope(retry:…, overrides: [postsRepositoryProvider…, settingsRepositoryProvider…], child: const App())`):
  - Boot: `'Posts'` and a post title are shown.
  - Locale: `tester.platformDispatcher.localesTestValue = [const Locale('es')]`, so `'Publicaciones'` is shown (reset in `addTearDown`).
  - Navigation: tap a post title, then the detail body text is shown.
  - Theme wiring: with the `initialThemeModeProvider` override set to `ThemeMode.dark`, `tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode == ThemeMode.dark`.
  - **Review Focus #3:** `container.read(routerProvider).go('/posts/abc')`, then `AppLocalizationsEn().pageNotFound` is shown; the same for `go('/nope')`.
- [ ] **Step 2: Run, expect FAIL.**
- [ ] **Step 3: Implement; run build_runner.**
- [ ] **Step 4: Run the full suite, expect PASS** — `fvm flutter test`.
- [ ] **Step 5: Manual smoke** — `fvm flutter run --dart-define-from-file=config/dev.json` on an iOS simulator or Android emulator: the list loads; airplane mode + Retry shows the network error and then recovers; tapping opens the detail; choosing Dark persists across a cold restart; the device language set to Spanish shows Spanish UI. If no simulator is available, say so explicitly in the task report.
- [ ] **Step 6: Commit** — `feat(app): wire router, themes, localization and startup preferences`

---

### Task 10: CI and README

**Files:**
- Create: `.github/workflows/ci.yml`, `README.md` (replace the `flutter create` default)

**Interfaces:**
- Consumes: the commands from the Global Constraints.

- [ ] **Step 1: Write `ci.yml`.** Trigger on push and pull_request to `main`. A single `ubuntu-latest` job with these steps: checkout; `echo "FLUTTER_VERSION=$(jq -r .flutter .fvmrc)" >> "$GITHUB_ENV"`; `subosito/flutter-action@v2` with `flutter-version: ${{ env.FLUTTER_VERSION }}`, `channel: stable`, `cache: true`; `flutter pub get`; `dart run build_runner build -d`; `git diff --exit-code` (generated files must be up to date); `dart format --set-exit-if-changed .`; `flutter analyze`; `flutter test`.

- [ ] **Step 2: Write `README.md`** with these sections:
  - Overview
  - Requirements (fvm, Flutter 3.50.1)
  - Getting started (`fvm install`, `pub get`, `build_runner`, `run --dart-define-from-file=config/dev.json`)
  - Architecture (layer diagram, dependency rules, "domain is optional" rule with the posts vs. settings examples, "no UseCase by default" rule)
  - State & DI with Riverpod (provider naming, keepAlive policy, retry disabled and why, overriding in tests)
  - Error handling (`AppException` and `guardApiCall` → `errorMessage`)
  - Localization (adding a string to both ARBs)
  - Preferences (the `AppPreferences` → repository → controller pattern)
  - Testing (`pumpApp`, `ProviderContainer.test`, mocktail)
  - How to add a new feature (step-by-step checklist)
  - Renaming the project
  - Lint and dependency notes, including any conflict fallbacks applied in Task 1

- [ ] **Step 3: Verify locally with the CI sequence.**

Run: `fvm flutter pub get && fvm dart run build_runner build -d && git diff --exit-code && fvm dart format --set-exit-if-changed . && fvm flutter analyze && fvm flutter test`
Expected: every command exits 0.

- [ ] **Step 4: Commit** — `ci: add GitHub Actions workflow; docs: add README with architecture and conventions`
