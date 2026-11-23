/// Route paths used across the app.
///
/// Kept apart from `router.dart` so features can link to routes without
/// importing the router (which imports the features' screens).
abstract final class AppRoutes {
  static const posts = '/';
  static const postDetail = '/posts/:id';

  static String postDetailPath(int id) => '/posts/$id';
}
